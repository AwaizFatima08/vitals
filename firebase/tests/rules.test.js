// Firestore security-rules tests for the shared LiveHealthy project.
// Run: cd firebase/tests && npm test   (starts the Firestore emulator)
//
// Covers the new Vitals rules AND re-checks the existing Medicine Reminder
// rules, since both apps share one rules file.

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  setDoc,
  Timestamp,
  updateDoc,
  where,
} from 'firebase/firestore';

let env;
const ALICE = 'alice'; // owner of patient p1
const BOB = 'bob'; // co-caregiver of p1
const EVE = 'eve'; // unrelated user

const bp = (overrides = {}) => ({
  type: 'bloodPressure',
  systolic: 128,
  diastolic: 82,
  measuredAt: Timestamp.now(),
  note: '',
  createdByUid: ALICE,
  createdAt: Timestamp.now(),
  ...overrides,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-livehealthy',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8085,
    },
  });
});

after(async () => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'patients/p1'), { name: 'Ammi', ownerUid: ALICE, memberUids: [ALICE, BOB], relationship: 'mother' });
    await setDoc(doc(db, 'patients/p1/vitalReadings/r1'), bp());
    await setDoc(doc(db, 'patients/p1/medicines/m1'), { name: 'Metformin', isActive: true });
    await setDoc(doc(db, 'users/alice'), { displayName: 'Alice', email: 'a@x.com' });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

describe('vitalReadings', () => {
  test('owner and co-caregiver can read', async () => {
    await assertSucceeds(getDoc(doc(as(ALICE), 'patients/p1/vitalReadings/r1')));
    await assertSucceeds(getDoc(doc(as(BOB), 'patients/p1/vitalReadings/r1')));
  });

  test('outsider and signed-out users cannot read', async () => {
    await assertFails(getDoc(doc(as(EVE), 'patients/p1/vitalReadings/r1')));
    await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'patients/p1/vitalReadings/r1')));
  });

  test('the app query (type == X order by measuredAt desc) is allowed for members', async () => {
    const q = query(
      collection(as(BOB), 'patients/p1/vitalReadings'),
      where('type', '==', 'bloodPressure'),
      orderBy('measuredAt', 'desc'),
    );
    await assertSucceeds(getDocs(q));
  });

  test('member can create a valid reading of each type', async () => {
    const db = as(ALICE);
    const base = { measuredAt: Timestamp.now(), note: '', createdByUid: ALICE, createdAt: Timestamp.now() };
    await assertSucceeds(addDoc(collection(db, 'patients/p1/vitalReadings'), bp()));
    await assertSucceeds(addDoc(collection(db, 'patients/p1/vitalReadings'), { ...base, type: 'spo2', value: 97 }));
    await assertSucceeds(addDoc(collection(db, 'patients/p1/vitalReadings'), { ...base, type: 'pulse', value: 72 }));
    await assertSucceeds(addDoc(collection(db, 'patients/p1/vitalReadings'), { ...base, type: 'weight', value: 72.4 }));
    await assertSucceeds(
      addDoc(collection(db, 'patients/p1/vitalReadings'), { ...base, type: 'glucose', value: 104, glucoseContext: 'fasting' }),
    );
  });

  test('cannot create a reading attributed to someone else', async () => {
    await assertFails(addDoc(collection(as(BOB), 'patients/p1/vitalReadings'), bp({ createdByUid: ALICE })));
  });

  test('outsider cannot create', async () => {
    await assertFails(addDoc(collection(as(EVE), 'patients/p1/vitalReadings'), bp({ createdByUid: EVE })));
  });

  test('implausible or malformed readings are rejected', async () => {
    const col = collection(as(ALICE), 'patients/p1/vitalReadings');
    await assertFails(addDoc(col, bp({ systolic: 1200 })));
    await assertFails(addDoc(col, bp({ diastolic: 'eighty' })));
    await assertFails(addDoc(col, bp({ type: 'temperature' })));
    await assertFails(addDoc(col, bp({ measuredAt: 'yesterday' })));
    await assertFails(addDoc(col, bp({ note: 'x'.repeat(201) })));
    await assertFails(
      addDoc(col, { type: 'glucose', value: 104, measuredAt: Timestamp.now(), createdByUid: ALICE }), // no context
    );
    await assertFails(
      addDoc(col, { type: 'spo2', value: 101, measuredAt: Timestamp.now(), createdByUid: ALICE }),
    );
  });

  test('co-caregiver can edit, but not rewrite the author', async () => {
    const ref = doc(as(BOB), 'patients/p1/vitalReadings/r1');
    await assertSucceeds(updateDoc(ref, { systolic: 135, note: 'after walk' }));
    await assertFails(updateDoc(ref, { createdByUid: BOB }));
  });

  test('member can delete; outsider cannot', async () => {
    await assertFails(deleteDoc(doc(as(EVE), 'patients/p1/vitalReadings/r1')));
    await assertSucceeds(deleteDoc(doc(as(BOB), 'patients/p1/vitalReadings/r1')));
  });
});

describe('vitalReminders', () => {
  const reminder = { patientId: 'p1', type: 'glucose', enabled: true, hour: 7, minute: 0 };

  test('user manages only their own reminders', async () => {
    await assertSucceeds(setDoc(doc(as(ALICE), 'users/alice/vitalReminders/p1_glucose'), reminder));
    await assertSucceeds(getDoc(doc(as(ALICE), 'users/alice/vitalReminders/p1_glucose')));
    await assertFails(setDoc(doc(as(EVE), 'users/alice/vitalReminders/p1_glucose'), reminder));
    await assertFails(getDoc(doc(as(EVE), 'users/alice/vitalReminders/p1_glucose')));
  });

  test('invalid reminder shapes are rejected', async () => {
    const ref = doc(as(ALICE), 'users/alice/vitalReminders/p1_glucose');
    await assertFails(setDoc(ref, { ...reminder, hour: 24 }));
    await assertFails(setDoc(ref, { ...reminder, minute: 7.5 }));
    await assertFails(setDoc(ref, { ...reminder, type: 'mood' }));
  });

  test('user can delete their reminders (account deletion)', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'users/alice/vitalReminders/p1_glucose'), reminder),
    );
    await assertSucceeds(deleteDoc(doc(as(ALICE), 'users/alice/vitalReminders/p1_glucose')));
  });
});

describe('shared patient rules (Medicine Reminder + Vitals)', () => {
  test('member list query works (the query both apps run at sign-in)', async () => {
    const q = query(collection(as(BOB), 'patients'), where('memberUids', 'array-contains', BOB));
    await assertSucceeds(getDocs(q));
  });

  test('member can set height (Vitals) without touching other fields', async () => {
    await assertSucceeds(updateDoc(doc(as(BOB), 'patients/p1'), { heightCm: 158 }));
  });

  test('outsider cannot update a patient', async () => {
    await assertFails(updateDoc(doc(as(EVE), 'patients/p1'), { heightCm: 158 }));
  });

  test('Medicine Reminder medicines still readable by members only', async () => {
    await assertSucceeds(getDoc(doc(as(BOB), 'patients/p1/medicines/m1')));
    await assertFails(getDoc(doc(as(EVE), 'patients/p1/medicines/m1')));
  });

  test('only the owner can delete the patient', async () => {
    await assertFails(deleteDoc(doc(as(BOB), 'patients/p1')));
    await assertSucceeds(deleteDoc(doc(as(ALICE), 'patients/p1')));
  });

  test('users can only read their own profile', async () => {
    await assertSucceeds(getDoc(doc(as(ALICE), 'users/alice')));
    await assertFails(getDoc(doc(as(EVE), 'users/alice')));
  });
});
