# Competitor apps and user reviews: home vital-sign loggers on Google Play (for LiveHealthy: Vitals v1.1)

Method note: Google Play listing data (installs, rating, review count, "Contains ads" / "In-app purchases" flags, last update, description text, and the 3 "most relevant" reviews Play shows) was pulled directly from play.google.com detail pages on **24 Nov 2026** (US storefront, `hl=en&gl=us`). AppBrain returned HTTP 403, so no third-party ad-network or revenue data was collected. Play shows install *bands* (e.g. "1M+"), not exact counts. Review quotes are short excerpts; review dates are as shown on Play. The "Contains ads" flag comes from a text match on the scraped page. For mySugr and MyTherapy it is unexpected and should be checked by hand.

## Q1. Which apps lead the category, and what do they offer (installs, rating, features, export, sync, languages, multi-user)?

### Takeaway
The manual-entry BP/glucose logbook category is led by a few long-running indie apps: "Blood Pressure / My Heart" (10M+), SmartBP, MyDiary and mEL Studio (each 1M+). Next come OEM device apps (OMRON connect 1M+, MedM 100K+) and diabetes platforms (mySugr 5M+, BeatO 1M+ in India). Most leading indie loggers already ship multi-profile/family support, PDF + CSV export, tags/context and reminders. **Combined BP + glucose + SpO2 + weight in one app with Urdu UI is rare.** The only Urdu-first competitor found (Khayal by ISRA) had 1+ installs.

### Cited Findings

**Comparison table (Play data as of 24 Nov 2026 unless noted)**

| App (developer) | Installs | Rating (reviews) | Ads / IAP | Last update | Key features relevant to Vitals |
|---|---|---|---|---|---|
| Blood Pressure / "My Heart" (Klimaszewski Szymon) | 10M+ | 4.3 (56.9K) | Ads + IAP | 19 Nov 2026 | BP, pulse, weight, SpO2; tags; 2025 AHA/ACC, ESH, ESC, JNC7 classification; 7/28/90-day charts; PDF report + spreadsheet export; **family profiles**; Health Connect sync; Google Drive auto-backup; camera "scan your monitor" OCR; guided breathing; export to ChatGPT/Claude/Gemini (free for 7 days of data) |
| SmartBP (evolvemedsys) | 1M+ | 4.0 (7.72K) | Ads + IAP | 24 Nov 2026 | BP, pulse, weight, auto MAP/pulse pressure/BMI; **family/caregiver profiles**; Bluetooth cuffs + Health Connect; SmartBP Cloud cross-device; CSV import/export; PDF reports; medication schedule |
| Blood Pressure Log – MyDiary (Blip Software) | 1M+ | 4.5 (13.7K) | Ads + IAP | **1 Sep 2023** (stale) | BP, weight, glucose, SpO2; Word/Excel/CSV/XML export; CSV import |
| Blood Pressure Log: BP Tracker (mEL Studio) | 1M+ | 4.2 (8.92K) | Ads + IAP | 16 Nov 2026 | BP, pulse, weight; tags; 16 charts (9 free); custom ranges; file backup; **PDF/XLS export is Premium-only** |
| Blood Pressure Diary (MedM) | 100K+ | 4.5 (3.13K) | IAP, no ads flag | 6 Oct 2026 | Manual or Bluetooth from 200+ BP monitors; BP, HR, SpO2, respiration, weight; optional cloud; **family/caregiver data sharing is Premium** |
| OMRON connect (Omron Healthcare) | 1M+ | 4.6 (123K) | IAP, no ads flag | 19 Nov 2026 | Auto Bluetooth sync from OMRON devices only; share with doctor/caregiver/family; premium reports and medication tracking |
| mySugr (Roche) | 5M+ | 4.5 (145K) | IAP (ads flag seen, verify) | 10 Nov 2026 | Glucose, meals, meds, BP integration; Accu-Chek sync; **PDF/Excel reports are PRO** (free with Accu-Chek meters or paid subscription) |
| Diabetes:M (Sirma Medical) | 500K+ | 3.8 (24.1K) | Ads + IAP | 7 Oct 2026 | Glucose, insulin, food DB, bolus advisor; CE Class I; **2 extra profiles, BT meters, sync and no ads are Premium** |
| Diabetes – Blood Sugar Tracker (Klimaszewski Szymon) | 500K+ | 4.4 (10.5K) | Ads + IAP | 6 Nov 2026 | Glucose + weight; custom tags; PDF/CSV/XML export; **multiple user profiles**; reminders; BLE meters Premium |
| Glucose tracker – Diabetic sugar (mEL Studio) | 1M+ | 4.5 (7K) | Ads + IAP | 13 Oct 2026 | Glucose, A1C calc, BP, insulin, food |
| Glucose Buddy (Azumio) | 500K+ | **1.8** (14.5K) | Ads + IAP | **15 Jul 2024** | Glucose/meds/meals; reports and no-ads behind Premium |
| Blood Sugar & BP Tracker (Oxylab Studio) | 1M+ | 4.4 (11.6K) | Ads only | 17 Jun 2026 | Combined BP + glucose (fasting/before/after meal); reminders; offline |
| BeatO (India) | 1M+ | 4.3 (46.2K) | — | 31 Oct 2026 | Diabetes platform tied to BeatO glucometer + strips; coaching; HbA1c |
| MyTherapy (smartpatient) | 5M+ | 4.5 (243K) | IAP (ads flag seen, verify) | 16 Nov 2026 | Med reminders + BP, SpO2, glucose, weight journal; **family profiles** |
| Khayal by ISRA (Pakistan) | **1+** | none yet | IAP | 19 Nov 2026 | **Urdu/English voice logging**, large text, caregiver linking, missed-dose alerts, SOS, WhatsApp weekly AI summary |

Sources for table rows:
- My Heart — [Play](https://play.google.com/store/apps/details?id=com.szyk.myheart)
- SmartBP — [Play](https://play.google.com/store/apps/details?id=com.smartbloodpressure)
- MyDiary — [Play](https://play.google.com/store/apps/details?id=com.zlamanit.blood.pressure)
- mEL BP — [Play](https://play.google.com/store/apps/details?id=melstudio.mpresssure)
- MedM BP — [Play](https://play.google.com/store/apps/details?id=com.medm.medmbp.diary)
- OMRON — [Play](https://play.google.com/store/apps/details?id=com.omronhealthcare.omronconnect)
- mySugr — [Play](https://play.google.com/store/apps/details?id=com.mysugr.android.companion)
- Diabetes:M — [Play](https://play.google.com/store/apps/details?id=com.mydiabetes)
- Szyk Diabetes — [Play](https://play.google.com/store/apps/details?id=com.szyk.diabetes)
- mEL sugar — [Play](https://play.google.com/store/apps/details?id=melstudio.msugar)
- Glucose Buddy — [Play](https://play.google.com/store/apps/details?id=com.skyhealth.glucosebuddyfree)
- Oxylab — [Play](https://play.google.com/store/apps/details?id=com.blood.sugar.pressure.monitor.app)
- BeatO — [Play](https://play.google.com/store/apps/details?id=com.healtharx.beato)
- MyTherapy — [Play](https://play.google.com/store/apps/details?id=eu.smartpatient.mytherapy)
- Khayal — [Play](https://play.google.com/store/apps/details?id=app.isra.android)

Other findings:
- Other ad-supported combined BP/sugar trackers with high installs: "Blood Pressure Log App" by DevGeniuses (500K+, ads, updated 12 Nov 2026) — [Play](https://play.google.com/store/apps/details?id=com.bloodpressure.monitor.heart.rate.bptracker); "Blood Sugar Care: BP Monitor" (1M+, rating 3.0, 1.2K reviews) — [Play](https://play.google.com/store/apps/details?id=com.bp.blood.sugar.bloodtracker.app)
- A Sept 2026 caregiver-oriented roundup lists OMRON connect, Withings, SmartBP (multiple profiles; PDF/CSV), iHealth MyVitals (CSV/XLS/PDF for 30/90 days/custom), Apple Health and Samsung Health Monitor. It notes iHealth gives family "no live access to new readings", only file sharing — [Caring Village, updated 26 Sep 2026](https://caringvillage.com/blog/caregiver-tech/best-blood-pressure-app/)
- That roundup lists Withings+ at $99.50/year and SmartBP Premium at $39.99/year (US App Store) — [Caring Village](https://caringvillage.com/blog/caregiver-tech/best-blood-pressure-app/)
- Many "best BP app 2026" listicles are written by app vendors ranking themselves first (BreathNow, Cardilog, SmartVitals), so they are weak evidence — [search results: breathnow.app, cardilog.app, mydigirecords.ai](https://www.breathnow.app/post/free-blood-pressure-apps-for-android)
- Samsung Health (built into Galaxy phones) shows 1B+ installs — [Play](https://play.google.com/store/apps/details?id=com.sec.android.app.shealth)
- The Play search results for "blood pressure tracker" are crowded with dozens of look-alike apps (e.g. `com.bloodpressure.log`, `com.bp.log`, `ai.shen.bpdiary`, `com.cardilog.bloodpressure`) — [Play search](https://play.google.com/store/search?q=blood+pressure+tracker&c=apps)

### Inferences
- Vitals' v1.0 feature set (multi-vital, tags/context for glucose, 7/30/90 charts, colour flags, multiple profiles, reminders) is roughly at parity with the top indie loggers. **It is not a differentiator on features alone, except for the Urdu UI and the BP + glucose + SpO2 + weight combination in one app.** Of the top indie loggers, only My Heart and MyDiary cover SpO2 alongside BP, and MyDiary is stale.
- Klimaszewski Szymon runs separate BP (10M+) and Diabetes (500K+) apps. This suggests split apps get more search visibility, but users then juggle two apps. One reviewer runs both side by side to see "both BP & BS" ([Play](https://play.google.com/store/apps/details?id=com.szyk.diabetes)).
- Languages: listings did not expose a language list. No major competitor was found advertising an Urdu UI.

### Gaps
- Exact install counts, country splits (Pakistan/India) and revenue: AppBrain blocked, and Sensor Tower/AppFigures need login.
- In-app language lists for each app were not visible in scraped listings.
- Qardio's Android app ID could not be found (the search hit an unrelated app), so it is not covered.

## Q2. How does each competitor make money (ad formats and placement, premium tiers, remove-ads price, subscription vs one-time)?

### Takeaway
The dominant model is **freemium with ads plus a subscription (sometimes a lifetime option) that removes ads and unlocks export, extra charts, cloud sync or extra profiles**. Several apps put **PDF/CSV export or extra family profiles behind the paywall**, and reviews show this drives anger. Device makers (OMRON, MedM, BeatO, mySugr) mostly avoid ads and earn from hardware, strips or premium. Ad-only clones get the harshest reviews about full-screen ads.

### Cited Findings
- My Heart: Premium removes all ads and unlocks extra analytics plus 30 days of AI-export. A 2022 reviewer said the app began requiring "$2.99 a month or $25 something" after years of being "free with annoying ads" — [Play](https://play.google.com/store/apps/details?id=com.szyk.myheart)
- SmartBP: a 17 Nov 2026 reviewer complains of a "hidden/faded 'X'" on marketing screens leading to a $54/year price. Another (5 Nov 2026) "can't get past ads" at launch and found the subscription too costly "when there are free alternatives". A third (22 Nov 2026) regrets buying the **lifetime membership** because of crashes — [Play](https://play.google.com/store/apps/details?id=com.smartbloodpressure). Caring Village lists Premium at $39.99/yr on the US App Store — [Caring Village](https://caringvillage.com/blog/caregiver-tech/best-blood-pressure-app/) (the two prices conflict, likely different storefronts or dates)
- mEL Studio BP: free tier has 9 of 16 charts. **PDF/XLS export is Premium**. A 2018 reviewer "paid to get rid of ads" and was happy. A 2024 reviewer paid "the full amount" and found the PDF export "hopeless" — [Play](https://play.google.com/store/apps/details?id=melstudio.mpresssure)
- MyDiary: a 2019 reviewer called the ads "not bad" and "went ad-less" after the doctor liked the reports — [Play](https://play.google.com/store/apps/details?id=com.zlamanit.blood.pressure)
- MedM: freemium. **Premium** gets ecosystem sync (Health Connect, Apple Health, Garmin, Fitbit), **sharing data with family/caregivers**, and reminder/threshold notifications — [Play](https://play.google.com/store/apps/details?id=com.medm.medmbp.diary)
- Diabetes:M Premium subscription covers no ads, Bluetooth meters, **2 additional profiles**, sync and pattern analysis. A 2021 reviewer was angry that a one-time no-ads purchase was replaced by a monthly charge — [Play](https://play.google.com/store/apps/details?id=com.mydiabetes)
- mySugr: PRO by monthly/yearly subscription, or free with Accu-Chek/ReliOn meters. PDF/Excel reports and reminders are PRO. A 2021 reviewer "bought the app when it was a one time fee", then it moved to subscription — [Play](https://play.google.com/store/apps/details?id=com.mysugr.android.companion)
- Glucose Buddy: Premium covers no ads, A1C, custom tags and report date ranges. A 2024 reviewer says after a major update the free version "will not generate reports" and refuses to pay "$20/month". Rating is now 1.8 — [Play](https://play.google.com/store/apps/details?id=com.skyhealth.glucosebuddyfree)
- Szyk Diabetes: core features free, BLE meter sync Premium — [Play](https://play.google.com/store/apps/details?id=com.szyk.diabetes)
- OMRON connect: free app, premium for deeper insights, medication tracking and detailed reports — [Play](https://play.google.com/store/apps/details?id=com.omronhealthcare.omronconnect); 30-day free trial — [Caring Village](https://caringvillage.com/blog/caregiver-tech/best-blood-pressure-app/)
- Oxylab "Blood Sugar & BP Tracker" (ads only, no IAP): reviews say "ads always covering the screen" (1 Nov 2026), "nigh on impossible due to the ads" (25 Sep 2026) and "make you watch countless ads" (3 Nov 2026) — [Play](https://play.google.com/store/apps/details?id=com.blood.sugar.pressure.monitor.app)
- Blood Sugar Care: BP Monitor: "fake app and too much ads" (2 Aug 2026) — [Play](https://play.google.com/store/apps/details?id=com.bp.blood.sugar.bloodtracker.app)
- BeatO's revenue is tied to glucometer strips. Reviewers accuse it of selling strips that fail so users "use multiple strips" (Sept 2026) — [Play](https://play.google.com/store/apps/details?id=com.healtharx.beato)
- On the iOS side, small apps market "no ads, no subscription" and one-time prices (e.g. "$4.99 forever") as a selling point. A MetaFilter commenter praised a free BP app with no ads that could export — [MetaFilter](https://ask.metafilter.com/359931/What-is-the-best-app-to-track-blood-pressure); [App Store search results summary](https://apps.apple.com/us/app/id6762027357)

### Inferences
- Users accept moderate ads in a logbook when there is a fair remove-ads option (MyDiary, mEL 2018 reviews). Ratings collapse when free features (logging, reports) are **taken away** after the fact (My Heart 2022, Glucose Buddy 2024, Diabetes:M, mySugr). Vitals should not gate anything that v1.0 users already have for free.
- Full-screen and launch-time ads that block the logging flow are the single most toxic pattern (Oxylab, SmartBP launch screens). For an elderly audience, a small banner off the entry screen plus an optional one-time "remove ads" is the low-risk pattern. This is an inference, not measured data.
- A one-time lifetime unlock is a known option (SmartBP has one). Users who paid one-time and were later pushed to subscription are vocal detractors.

### Gaps
- Exact AdMob formats and placements per app (banner vs interstitial positions) could not be verified without installing the apps. Only review descriptions are available.
- Exact remove-ads / premium prices in PKR or INR on Play were not visible in the scraped listings. The "per item" IAP ranges did not render.

## Q3. What do users repeatedly praise and complain about?

### Takeaway
**Praise:** fast entry ("input my numbers quickly, save and close"), doctor-ready reports, graphs and patterns, easy editing, notes. **Complaints:** data loss on phone change or no backup/restore, intrusive or blocking ads, paywalls added later or around export, broken device or Health Connect sync, features half-done (SpO2 entered but not charted, no pulse averages), crashes, and misleading "measures BP with your finger" claims.

### Cited Findings
**Praise**
- "I can input my numbers quickly, save and close"; reports shared with the doctor save handwriting (2018) — [MyDiary Play](https://play.google.com/store/apps/details?id=com.zlamanit.blood.pressure)
- Switched from a "cumber some" spreadsheet; easy to use (Aug 2026) — [MedM Play](https://play.google.com/store/apps/details?id=com.medm.medmbp.diary)
- Detailed graphs show patterns; "easy to edit if you make a mistake" (Oct–Nov 2026) — [mEL sugar Play](https://play.google.com/store/apps/details?id=melstudio.msugar)
- Notes help when discussing readings with the doctor (Apr 2026) — [Szyk Diabetes Play](https://play.google.com/store/apps/details?id=com.szyk.diabetes)
- Fast developer support, e.g. an email reply within hours (2018) — [mEL BP Play](https://play.google.com/store/apps/details?id=melstudio.mpresssure); SmartBP fixed a blocking bug "within a few hours" (Nov 2026) — [SmartBP Play](https://play.google.com/store/apps/details?id=com.smartbloodpressure)

**Complaints**
- **Data loss / migration:** "when I changed my phone, I could not restore from backup and lost my data"; also asks for automated Google Drive backups (19 Nov 2026) — [My Heart Play](https://play.google.com/store/apps/details?id=com.szyk.myheart). "Wish there was a (easy) way to transfer the data to a new phone" (2019) — [MyDiary Play](https://play.google.com/store/apps/details?id=com.zlamanit.blood.pressure). "Every time I switch phones, it pisses me off… implement the sync… or let us import the files" (2024) — [Glucose Buddy Play](https://play.google.com/store/apps/details?id=com.skyhealth.glucosebuddyfree)
- **Ads blocking use:** see Oxylab and SmartBP quotes in Q2 — [Oxylab Play](https://play.google.com/store/apps/details?id=com.blood.sugar.pressure.monitor.app); [SmartBP Play](https://play.google.com/store/apps/details?id=com.smartbloodpressure)
- **Paywalls on core features:** My Heart 2022, Glucose Buddy 2024, Diabetes:M 2021, mySugr 2021 (see Q2)
- **Sync reliability:** SmartBP "Health Connect syncing is unreliable, and readings don't always transfer" (22 Nov 2026) — [SmartBP Play](https://play.google.com/store/apps/details?id=com.smartbloodpressure). Diabetes:M stopped pulling from OneTouch Verio (Jan 2026) — [Diabetes:M Play](https://play.google.com/store/apps/details?id=com.mydiabetes). OMRON "can't find my monitor" while Samsung Health syncs it (2018); recurring popups and an unclosable dialog (Oct 2025) — [OMRON Play](https://play.google.com/store/apps/details?id=com.omronhealthcare.omronconnect). My Heart's Google Fit import drops heart rate (2022) — [My Heart Play](https://play.google.com/store/apps/details?id=com.szyk.myheart)
- **Incomplete vitals:** SpO2 can be entered "but it doesn't show up anywhere" (2020) — [MyDiary Play](https://play.google.com/store/apps/details?id=com.zlamanit.blood.pressure). No averages/graphs for heart rate (Aug 2026) — [MedM Play](https://play.google.com/store/apps/details?id=com.medm.medmbp.diary). A mySugr user wants pulse/BP in reports (2019) — [mySugr Play](https://play.google.com/store/apps/details?id=com.mysugr.android.companion)
- **Poor export quality:** PDF days run right-to-left and the data selection is confusing (2024); "the way how it looks when exported could be much better" (2022) — [mEL BP Play](https://play.google.com/store/apps/details?id=melstudio.mpresssure)
- **Missing interpretation:** a user wants to be told "if the average is good or not" and to set their own brackets (2022) — [mEL BP Play](https://play.google.com/store/apps/details?id=melstudio.mpresssure)
- **Misleading measurement claims:** users expected the app to measure glucose or BP with a finger on the screen and felt misled (Sept–Nov 2026) — [Oxylab Play](https://play.google.com/store/apps/details?id=com.blood.sugar.pressure.monitor.app); [Blood Sugar Care Play](https://play.google.com/store/apps/details?id=com.bp.blood.sugar.bloodtracker.app)
- **Health Connect requested:** "would love it to connect to health connect" (Oct 2026) — [mEL sugar Play](https://play.google.com/store/apps/details?id=melstudio.msugar)
- **Edit/UX bugs:** can't edit after entry; edits erased entries (2019) — [Glucose Buddy Play](https://play.google.com/store/apps/details?id=com.skyhealth.glucosebuddyfree)

### Inferences
- The top request across apps is **reliable backup/restore and phone migration**. Vitals' Firebase account sync may already address this, and it is worth stating loudly in the store listing ("change phones, keep your readings").
- Clear "not a measuring device" wording and honest screenshots matter. Fake "finger scan" apps poison user trust in the category.
- A plain-language interpretation of averages (e.g. "your 30-day average is in the amber range") is requested and fits Vitals' existing green/amber/red flags.

### Gaps
- Reddit threads (r/hypertension, r/diabetes, r/CaregiverSupport) did not surface in search, so community sentiment beyond Play reviews is thin.
- Only Play's 3 "most relevant" reviews per app were captured, so frequencies are qualitative, not counted.

## Q4. Which features are table stakes vs differentiators in 2025–2026?

### Takeaway
**Table stakes:** manual quick entry, colour-coded categories, charts with 7/30/90-day ranges, tags/notes, reminders, PDF report for the doctor, CSV export, backup, multi-profile. **Emerging differentiators:** Health Connect sync, camera OCR of the monitor display, voice entry, auto cloud backup and restore, caregiver *live* sharing and alerts, selectable guidelines (AHA 2025 / ESH / ESC), AI summaries or exports, and local language plus large-text UI.

### Cited Findings
- My Heart (10M+) now advertises 2025 AHA/ACC classification, camera scan of the monitor, guided breathing, Health Connect, Drive auto-backup, family profiles and AI-tool export — [Play](https://play.google.com/store/apps/details?id=com.szyk.myheart)
- SmartBP advertises Bluetooth + Health Connect, cloud cross-device sync, family profiles, MAP/pulse pressure and "smart reminders that recognize when a reading has already been logged" — [Play](https://play.google.com/store/apps/details?id=com.smartbloodpressure)
- Blood Snap offers manual, **voice**, and **photo "Quick Log Scan"** of BP monitors, glucometers and scales, plus a monthly table view — [Play](https://play.google.com/store/apps/details?id=com.bloodsnap.app) (100+ installs, 3.3 rating)
- BP Log (Masum Apps) markets Health Connect import from the cuff's app plus a doctor report — [Play](https://play.google.com/store/apps/details?id=com.bp.log)
- Khayal offers Urdu/English voice, caregiver alerts on missed doses, SOS, and a WhatsApp weekly caregiver summary — [Play](https://play.google.com/store/apps/details?id=app.isra.android)
- iHealth offers export for 30 days / 90 days / custom ranges as CSV/XLS/PDF. Its family sharing is file-only, with no live access — [Caring Village](https://caringvillage.com/blog/caregiver-tech/best-blood-pressure-app/)
- OMRON connect shares readings with "doctor, caregiver, or family" and sends alerts for notable changes — [Play](https://play.google.com/store/apps/details?id=com.omronhealthcare.omronconnect)

### Inferences
- For Vitals v1.1, the likely highest-value additions: (1) PDF doctor report + CSV export, free and not paywalled, if not already present; (2) Health Connect read/write for BP, glucose, SpO2, weight and HR; (3) camera OCR of the BP-monitor display (on-device ML Kit); (4) caregiver alerts when a family member's reading is red, which goes beyond file sharing; (5) "explain my average" text in Urdu/English.
- Vitals' multi-profile family model under one account is already table stakes. *Linked accounts*, where a caregiver sees the parent's own phone entries, would be the differentiator (OMRON, MedM Premium and Khayal do this).

### Gaps
- No usage or retention data on which features actually drive installs. The feature lists are marketing claims from listings.

## Q5. Are there apps for South Asia / Urdu / Hindi speakers or elderly users, and how did they do?

### Takeaway
South-Asia-specific traction is mostly **India's device-plus-coaching platforms (BeatO 1M+, HealthifyMe 10M+ diet/fitness)**. Pakistan has telehealth apps (Marham, Oladoc) but no notable Urdu vitals logbook. The one Urdu-first, elderly-friendly vitals and caregiver app found, **Khayal by ISRA, is brand new (1+ installs, Nov 2026)**. The space is effectively open, and the risk is discoverability, not competition.

### Cited Findings
- Khayal by ISRA: Urdu/English voice, "Large, clear text and simple screens", caregiver linking, 1+ installs, updated 19 Nov 2026 — [Play](https://play.google.com/store/apps/details?id=app.isra.android)
- BeatO describes itself as "India's leading diabetes app", with 1M+ installs, 4.3 rating and 46.2K reviews. Complaints focus on strip failures and battery drain — [Play](https://play.google.com/store/apps/details?id=com.healtharx.beato)
- HealthifyMe (India) has 10M+ installs and is diet/fitness focused, claiming 40M users — [Play](https://play.google.com/store/apps/details?id=com.healthifyme.basic)
- A 2022 ProPakistani article called mySugr "Pakistan's first diabetes data management app", aimed at replacing paper sugar logs — [ProPakistani](https://propakistani.pk/2022/01/19/mysugr-is-pakistans-first-diabetes-data-management-app/)
- Meri Shifa (Aga Khan Development Network, Pakistan, 2021) is an AKDN health project. Its features as a vitals diary could not be confirmed — [AKDN](https://www.akdn.org/project/meri-shifa)
- Pakistani telehealth apps surfaced in Play search for "Marham": Marham (`controllers.marham.marhammed`) and Oladoc (`com.mediconnect.oladoc`). These are doctor-booking apps, not logbooks — [Play search](https://play.google.com/store/search?q=Marham&c=apps&gl=pk)
- Play search for "urdu blood pressure" (PK storefront) returned only generic English BP apps and MedM, with no Urdu-localised logbook — [Play search](https://play.google.com/store/search?q=urdu+blood+pressure&c=apps&gl=pk)
- Family Medicine Tracker (MSPK Creations) targets "Caring for parents? Share profiles with siblings", with 100+ installs — [Play](https://play.google.com/store/apps/details?id=com.mspk.medicineintaketracker)

### Inferences
- Vitals' Urdu + caregiver positioning has little direct competition on Play. Store-listing localisation (an Urdu listing, Urdu screenshots, and keywords like "شوگر", "بلڈ پریشر") is likely more important than new features for Pakistan growth. This is inferred from search results, not measured.
- India's winners monetise through hardware and services, not ads. For a Pakistan-first, no-device logbook, ads plus a cheap one-time remove-ads unlock is plausible, but Pakistan ad eCPMs are low, so expect modest ad revenue. eCPM figures were not researched here.

### Gaps
- No install or rating data for Meri Shifa, and no Pakistan-specific top-charts data for the Health & Fitness/Medical categories.
- Hindi-localised BP/sugar loggers: the Play search for Hindi returned generic English clones only, and no Hindi-first app was identified.
- No Pakistan/India review data on ad tolerance specifically among elderly users.
