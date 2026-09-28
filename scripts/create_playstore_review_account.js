// Creates (or refreshes) the Google Play review account for LiveHealthy: Vitals,
// pre-filled with realistic demo data so a reviewer immediately sees charts,
// BMI and colour flags instead of an empty app.
//
//   cd scripts && npm install && node create_playstore_review_account.js
//   node create_playstore_review_account.js --reset-password   # rotate password
//
// Requires secrets/firebase-admin-service-account.json (gitignored).
// Writes credentials to secrets/playstore_review_account.txt (gitignored, 0600).
//
// Deliberately a SEPARATE account from Medicine Reminder's reviewer
// (playstore-reviewer@homilabs.org): that app's script rotates its password
// on every run, which would silently break credentials already entered in
// this app's Play Console. Here, re-running KEEPS the password (read back
// from the credentials file) and only refreshes the demo data, unless
// --reset-password is given.

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const ROOT = path.join(__dirname, '..');
const CREDS_PATH = path.join(ROOT, 'secrets/playstore_review_account.txt');
admin.initializeApp({
  credential: admin.credential.cert(require(path.join(ROOT, 'secrets/firebase-admin-service-account.json'))),
});
const auth = admin.auth();
const db = admin.firestore();
const { Timestamp, FieldValue } = admin.firestore;

const EMAIL = 'playstore-reviewer-vitals@homilabs.org';
const DISPLAY_NAME = 'Play Store Reviewer';
const RESET = process.argv.includes('--reset-password');

function newPassword() {
  return crypto.randomBytes(18).toString('base64').replace(/[^A-Za-z0-9]/g, '').slice(0, 16);
}

function existingPassword() {
  if (!fs.existsSync(CREDS_PATH)) return null;
  const m = fs.readFileSync(CREDS_PATH, 'utf8').match(/^Password:\s+(\S+)$/m);
  return m ? m[1] : null;
}

// Deterministic pseudo-random so every refresh produces the same-looking data.
function rng(seed) {
  let s = seed;
  return () => ((s = (s * 1103515245 + 12345) % 2147483648) / 2147483648);
}

async function ensurePatient(uid, { name, relationship, heightCm }) {
  const snap = await db.collection('patients').where('ownerUid', '==', uid).get();
  const found = snap.docs.find((d) => d.data().relationship === relationship);
  const data = {
    name,
    ownerUid: uid,
    memberUids: [uid],
    photoUrl: null,
    relationship,
    heightCm,
  };
  if (found) {
    await found.ref.set(data, { merge: true });
    return found.id;
  }
  const ref = await db.collection('patients').add({ ...data, createdAt: FieldValue.serverTimestamp() });
  return ref.id;
}

async function replaceReadings(patientId, readings) {
  const col = db.collection('patients').doc(patientId).collection('vitalReadings');
  const old = await col.get();
  let batch = db.batch();
  let n = 0;
  const flush = async () => {
    if (n) await batch.commit();
    batch = db.batch();
    n = 0;
  };
  for (const d of old.docs) {
    batch.delete(d.ref);
    if (++n === 400) await flush();
  }
  for (const r of readings) {
    batch.set(col.doc(), r);
    if (++n === 400) await flush();
  }
  await flush();
}

function selfReadings(uid) {
  const rand = rng(42);
  const out = [];
  const now = new Date();
  const base = { note: '', createdByUid: uid, createdAt: Timestamp.now() };
  for (let day = 29; day >= 0; day--) {
    const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - day, 8, Math.floor(rand() * 40));
    if (d > now) d.setTime(now.getTime() - 60 * 60 * 1000); // today's reading can't be in the future
    const at = Timestamp.fromDate(d);
    const trend = day < 10 ? -5 : 0; // BP improving over the last ten days
    out.push({ ...base, type: 'bloodPressure', systolic: 126 + Math.floor(rand() * 16) + trend,
      diastolic: 79 + Math.floor(rand() * 9) + Math.round(trend / 2), measuredAt: at,
      note: day === 3 ? 'after morning walk' : '' });
    out.push({ ...base, type: 'pulse', value: 66 + Math.floor(rand() * 16), measuredAt: at });
    out.push({ ...base, type: 'spo2', value: 95 + Math.floor(rand() * 4), measuredAt: at });
    out.push({ ...base, type: 'glucose', value: 90 + Math.floor(rand() * 24), glucoseContext: 'fasting',
      measuredAt: Timestamp.fromDate(new Date(d.getTime() - 30 * 60 * 1000)) });
    if (day % 3 === 0) {
      out.push({ ...base, type: 'glucose', value: 128 + Math.floor(rand() * 30), glucoseContext: 'afterMeal',
        measuredAt: Timestamp.fromDate(new Date(d.getTime() + 5 * 60 * 60 * 1000 < now.getTime()
          ? d.getTime() + 5 * 60 * 60 * 1000 : d.getTime())) });
      out.push({ ...base, type: 'weight', value: Math.round((79.2 - (29 - day) * 0.05 + rand() * 0.4) * 10) / 10,
        measuredAt: at });
    }
  }
  return out;
}

function familyReadings(uid) {
  const rand = rng(7);
  const out = [];
  const now = new Date();
  const base = { note: '', createdByUid: uid, createdAt: Timestamp.now() };
  for (let day = 13; day >= 1; day--) {
    const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - day, 9, Math.floor(rand() * 30));
    const at = Timestamp.fromDate(d);
    out.push({ ...base, type: 'bloodPressure', systolic: 138 + Math.floor(rand() * 14),
      diastolic: 84 + Math.floor(rand() * 8), measuredAt: at });
    out.push({ ...base, type: 'glucose', value: 104 + Math.floor(rand() * 26), glucoseContext: 'fasting',
      measuredAt: at, note: day === 2 ? 'felt dizzy' : '' });
  }
  return out;
}

async function main() {
  let password = RESET ? null : existingPassword();
  let rotated = false;

  let user;
  try {
    user = await auth.getUserByEmail(EMAIL);
    if (!password) {
      password = newPassword();
      rotated = true;
    }
    await auth.updateUser(user.uid, { password, emailVerified: true, displayName: DISPLAY_NAME, disabled: false });
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    password = password || newPassword();
    rotated = true;
    user = await auth.createUser({ email: EMAIL, password, displayName: DISPLAY_NAME, emailVerified: true });
  }
  const uid = user.uid;

  const selfId = await ensurePatient(uid, { name: DISPLAY_NAME, relationship: 'self', heightCm: 172 });
  const mumId = await ensurePatient(uid, { name: 'Ammi (demo)', relationship: 'mother', heightCm: 158 });

  await db.collection('users').doc(uid).set({
    displayName: DISPLAY_NAME,
    email: EMAIL,
    preferredLanguage: 'en',
    activePatientId: selfId,
    createdAt: FieldValue.serverTimestamp(),
  }, { merge: true });

  const self = selfReadings(uid);
  const mum = familyReadings(uid);
  await replaceReadings(selfId, self);
  await replaceReadings(mumId, mum);

  // Reminders start off (the app's default); clear any a reviewer switched on.
  const reminders = await db.collection('users').doc(uid).collection('vitalReminders').get();
  await Promise.all(reminders.docs.map((d) => d.ref.delete()));

  fs.writeFileSync(CREDS_PATH, `Google Play review account — LiveHealthy: Vitals
Firebase project: live-healthy-medreminder (shared LiveHealthy account system)

Email:    ${EMAIL}
Password: ${password}
uid:      ${uid}

Demo data (refreshed ${new Date().toISOString()}):
- "${DISPLAY_NAME}" (self, height 172 cm): ${self.length} readings over 30 days (BP, pulse,
  SpO2, fasting + after-meal glucose, weight) so charts, BMI and colour flags are populated.
- "Ammi (demo)" (mother, 158 cm): ${mum.length} readings over 2 weeks (BP, glucose). Switch
  patients via the name at the top of the Vitals tab.
- All reminders off (app default).

Re-run scripts/create_playstore_review_account.js to refresh the demo data (the password
is kept). Add --reset-password to rotate it, then update Play Console.

Paste into Play Console > App content > App access > "All or some functionality is
restricted" > Add new instructions:
  Name: Review account
  Username: ${EMAIL}
  Password: (above)
  Any other information: Sign in with "Already use a LiveHealthy app? Sign in" at the bottom
  of the first screen. Demo readings are pre-loaded; tap any vital to see its history chart,
  or "+" to log a new reading. This app is informational only and does not measure anything.
`);
  fs.chmodSync(CREDS_PATH, 0o600);

  console.log(`Account ready: ${EMAIL} (uid ${uid})`);
  console.log(rotated ? 'Password: NEW (see credentials file)' : 'Password: unchanged');
  console.log(`Seeded ${self.length} + ${mum.length} readings. Credentials: secrets/playstore_review_account.txt`);
}

main().then(() => process.exit(0)).catch((err) => {
  console.error(err);
  process.exit(1);
});
