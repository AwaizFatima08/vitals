"""Builds the LiveHealthy Vitals pages for https://livehealthy.homilabs.org/.

Pages are flat at the site root and fully self-contained (inline CSS, logo
as a data: URI) — the first LiveHealthy deploy 404'd on subdirectories.
The shared stylesheet is taken from the existing LiveHealthy site so the
whole family looks the same.

Run from the repo root: python3 scripts/build_website.py
Outputs to website/ (upload those files to the site root).
"""
import base64, io, re
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SIBLING = Path('/mnt/storage/projects/live_healthy/website')
OUT = ROOT / 'website'
EFFECTIVE = '25 September 2026'
EMAIL = 'info@homilabs.org'

css = re.search(r'<style>(.*?)</style>', (SIBLING / 'privacy-policy.html').read_text(), re.S).group(1)
buf = io.BytesIO()
Image.open(ROOT / 'store/graphics/app_icon_clean.png').resize((128, 128), Image.LANCZOS).save(buf, 'PNG', optimize=True)
logo = 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()

def page(filename, title, description, body):
    html = f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} — LiveHealthy Vitals</title>
<meta name="description" content="{description}">
<link rel="icon" href="{logo}">
<style>{css}</style>
</head>
<body>

<header class="site">
  <div class="wrap">
    <img class="logo" src="{logo}" alt="">
    <a class="brand" href="index.html">LiveHealthy Vitals</a>
    <nav>
      <a href="index.html">Home</a>
      <a href="vitals-privacy-policy.html">Privacy</a>
      <a href="vitals-terms-and-conditions.html">Terms</a>
      <a href="vitals-deleteaccount.html">Delete Account</a>
    </nav>
  </div>
</header>

<main>
{body}
</main>

<footer class="site">
  <div class="wrap">
    <span>&copy; <span id="year"></span> HomiLabs. All rights reserved.</span>
    <nav>
      <a href="index.html">Home</a>
      <a href="vitals-privacy-policy.html">Privacy</a>
      <a href="vitals-terms-and-conditions.html">Terms</a>
      <a href="vitals-deleteaccount.html">Delete Account</a>
    </nav>
  </div>
</footer>
<script>document.getElementById('year').textContent = new Date().getFullYear();</script>
</body>
</html>
'''
    (OUT / filename).write_text(html)
    print('wrote', filename, len(html), 'bytes')

PRIVACY = f'''  <h1>Privacy Policy</h1>
  <p class="meta">Effective date: {EFFECTIVE} · Applies to LiveHealthy Vitals (Android).</p>

  <p>LiveHealthy Vitals is developed by HomiLabs ("we", "us"). It is part of the LiveHealthy
    family of apps and uses the same LiveHealthy account as LiveHealthy-Medicine Reminder. This
    policy explains what the app collects, how it's used, and the choices you have.</p>

  <h2>1. Who this applies to</h2>
  <p>LiveHealthy Vitals is for adults who want to keep a record of vital signs they measure at
    home — for themselves, or for a family member they help look after. One account can manage
    several patient profiles.</p>

  <h2>2. Information we collect</h2>
  <h3>Account information</h3>
  <p>Name, email address and a password (handled by Firebase Authentication — we never see or
    store your password ourselves), and your preferred language.</p>

  <h3>Health information you enter</h3>
  <ul>
    <li>Patient profiles: name, relationship to you, and (optionally) height, used to calculate BMI</li>
    <li>Readings you type in: blood pressure (systolic/diastolic), oxygen saturation (SpO2),
      pulse, weight and blood glucose — with the time taken, the glucose context (fasting,
      before/after a meal, random), and any short note you add</li>
    <li>Reminder settings you choose to switch on (which vital, which patient, what time)</li>
  </ul>
  <p>The app does not measure anything itself and does not connect to Bluetooth devices. It
    only stores values you enter.</p>

  <h3>What we don't collect</h3>
  <p>No advertising identifiers, no third-party analytics or advertising SDKs, no location,
    contacts, camera, microphone or messages.</p>

  <h2>3. How we use this information</h2>
  <ul>
    <li>To show your readings, charts and reference-range colour flags</li>
    <li>To sync your data across your own signed-in devices and across LiveHealthy apps that
      share your account</li>
    <li>To let caregivers you explicitly add to a patient see and log that patient's readings</li>
    <li>To schedule the optional daily reminders you switch on (scheduled on your device)</li>
  </ul>
  <p>We do not use your health data for advertising, and we do not sell it.</p>

  <h2>4. Where your data is stored</h2>
  <p>Data is stored in Google Firebase (Cloud Firestore) and encrypted in transit. Access is
    enforced at the database level: a patient's readings can only be read by the account holder
    and caregivers explicitly added to that patient — not by other users, and not by us as a
    matter of routine.</p>

  <h2>5. Sharing</h2>
  <p>We do not sell, rent or share your personal or health information with third parties for
    their own purposes. The only sharing is with caregivers you add to a patient's profile, which
    is under your control. Our infrastructure providers (Google Firebase) process data on our
    behalf to run the service.</p>

  <h2>6. Data retention and deletion</h2>
  <p>Data is kept for as long as your account exists. You can edit or delete individual readings
    at any time, and delete your whole account from inside the app or from the web — see our
    <a href="vitals-deleteaccount.html">Delete Account</a> page. Because the LiveHealthy account
    is shared, deleting it removes your data from all LiveHealthy apps.</p>

  <h2>7. Children's privacy</h2>
  <p>The app is meant to be set up and operated by an adult. It is not directed at children, and
    we do not knowingly collect information directly from children. The colour flags use adult
    reference ranges.</p>

  <h2>8. Your rights</h2>
  <p>You can review, correct and delete your information within the app at any time, and ask us
    about your data using the contact below.</p>

  <h2>9. Changes to this policy</h2>
  <p>If this policy changes we'll update the effective date above.</p>

  <h2>10. Contact us</h2>
  <p>Questions about this policy or your data: <a href="mailto:{EMAIL}">{EMAIL}</a></p>
'''

TERMS = f'''  <h1>Terms &amp; Conditions</h1>
  <p class="meta">Effective date: {EFFECTIVE} · Applies to LiveHealthy Vitals (Android).</p>

  <div class="callout danger">
    <strong>Not a medical device.</strong> LiveHealthy Vitals is a logbook for readings you take
    with your own devices. The colour flags compare a reading with general adult reference ranges
    <em>for information only</em> — they are not a diagnosis and not medical advice, and the
    ranges may not suit children, pregnancy, athletes, or people on certain medicines. Always
    follow your doctor's advice. In an emergency, contact emergency services directly — do not
    rely on this app.
  </div>

  <h2>1. Acceptance of these terms</h2>
  <p>By creating an account or using the app you agree to these terms. If you set it up for
    someone else, you confirm you're authorized to enter and manage their information.</p>

  <h2>2. What the app does</h2>
  <p>LiveHealthy Vitals lets you log blood pressure, SpO2, pulse, weight and blood glucose,
    calculates BMI from weight and height, shows history charts, flags readings against general
    reference ranges, and can send optional daily reminders to check a vital.</p>

  <h2>3. Your responsibilities</h2>
  <ul>
    <li>Enter readings accurately; the app can only reflect what it's told.</li>
    <li>Use a reliable, correctly used measuring device.</li>
    <li>Keep your account credentials private.</li>
    <li>Discuss your readings — and anything a flag suggests — with a qualified clinician.</li>
  </ul>

  <h2>4. Accounts and access</h2>
  <p>Your LiveHealthy account is shared across LiveHealthy apps. You're responsible for activity
    under it. Adding a caregiver to a patient shares that patient's data with them.</p>

  <h2>5. Acceptable use</h2>
  <p>Don't store information about someone without authorization, disrupt the service, or
    reverse-engineer the app beyond what applicable law permits.</p>

  <h2>6. Availability and reminders</h2>
  <p>Reminders are delivered by your phone's operating system and may be delayed or blocked by
    battery optimisation or notification settings. We aim for a reliable service but can't
    guarantee uninterrupted availability.</p>

  <h2>7. Intellectual property</h2>
  <p>The LiveHealthy name, branding and app are owned by HomiLabs. The data you enter remains
    yours.</p>

  <h2>8. Disclaimers and limitation of liability</h2>
  <p>The app is provided "as is", without warranty of any kind, to the extent permitted by law.
    HomiLabs is not liable for indirect, incidental or consequential damages arising from use of
    the app, including decisions made on the basis of a reading or flag.</p>

  <h2>9. Termination</h2>
  <p>You can stop using the app and <a href="vitals-deleteaccount.html">delete your account</a>
    at any time. We may suspend access for use that violates these terms.</p>

  <h2>10. Changes</h2>
  <p>If these terms change we'll update the effective date above.</p>

  <h2>11. Governing law</h2>
  <p>These terms are governed by the laws of Pakistan, unless a mandatory consumer-protection law
    of your country provides otherwise.</p>

  <h2>12. Contact us</h2>
  <p><a href="mailto:{EMAIL}">{EMAIL}</a></p>
'''

DELETE = f'''  <h1>Delete Your Account</h1>
  <p class="meta">Applies to: LiveHealthy Vitals (and your LiveHealthy account, which is shared with
    LiveHealthy-Medicine Reminder)</p>

  <p>You can delete your LiveHealthy account and its data from inside the app, or from this page
    without signing in.</p>

  <div class="callout">
    <strong>One account, all LiveHealthy apps.</strong> LiveHealthy Vitals and LiveHealthy-Medicine
    Reminder use the same account. Deleting it from either app deletes it everywhere.
  </div>

  <h2>Option 1 — From inside the app</h2>
  <ol>
    <li>Open LiveHealthy Vitals and go to <strong>Settings</strong> (bottom bar).</li>
    <li>Tap <strong>Delete my account</strong> and read what will be removed.</li>
    <li>Confirm, then re-enter your password (a standard security step).</li>
  </ol>
  <p>Deletion happens immediately and cannot be undone.</p>

  <h2>Option 2 — From the web, without the app</h2>
  <p>Email <a href="mailto:{EMAIL}?subject=Delete%20my%20LiveHealthy%20account">{EMAIL}</a> with
    the subject "Delete my LiveHealthy account", from (or mentioning) the email address your account
    is registered under, and the app name (LiveHealthy Vitals). We'll verify the request, complete
    deletion within 30 days, and confirm by email.</p>

  <h2>What gets deleted</h2>
  <ul>
    <li>Your account (name, email, language preference) and your reminder settings</li>
    <li>Every patient profile you solely manage, with all of its vital readings — and, because the
      account is shared, any LiveHealthy-Medicine Reminder medicines, schedules, dose history and
      purchase records for those patients</li>
  </ul>

  <h2>What isn't deleted</h2>
  <ul>
    <li>A patient you share with another caregiver stays with them — you're removed from it, but
      their access and that patient's data remain, since it isn't yours alone to delete.</li>
  </ul>
  <p>We keep no copies after deletion, apart from routine encrypted infrastructure backups that
    expire on the provider's normal schedule.</p>

  <h2>Questions</h2>
  <p><a href="mailto:{EMAIL}">{EMAIL}</a></p>
'''

OUT.mkdir(exist_ok=True)
page('vitals-privacy-policy.html', 'Privacy Policy', 'Privacy Policy for LiveHealthy Vitals.', PRIVACY)
page('vitals-terms-and-conditions.html', 'Terms & Conditions', 'Terms and Conditions for LiveHealthy Vitals.', TERMS)
page('vitals-deleteaccount.html', 'Delete Your Account', 'How to delete your LiveHealthy account and data from LiveHealthy Vitals.', DELETE)

# Updated family landing page: flip the Vitals card to "Available" with links.
index = (SIBLING / 'index.html').read_text()
old_card = re.search(r'<div class="app-card">\s*<span class="badge soon">In development</span>\s*<h3>LiveHealthy-Vitals</h3>.*?</div>', index, re.S)
assert old_card, 'Vitals card not found in sibling index.html'
new_card = '''<div class="app-card">
    <span class="badge live">Available now</span>
    <h3>LiveHealthy Vitals</h3>
    <p>Log blood pressure, oxygen, pulse, weight and blood sugar with a big, simple keypad —
      with charts, BMI, and gentle optional reminders, for yourself or a family member.</p>
    <a class="btn outline" href="#">View on Play Store</a>
    <p style="margin:12px 0 0;font-size:0.85rem">
      <a href="vitals-privacy-policy.html">Privacy</a> ·
      <a href="vitals-terms-and-conditions.html">Terms</a> ·
      <a href="vitals-deleteaccount.html">Delete account</a></p>
  </div>'''
(OUT / 'index.html').write_text(index.replace(old_card.group(0), new_card))
print('wrote index.html (Vitals card now "Available now")')
