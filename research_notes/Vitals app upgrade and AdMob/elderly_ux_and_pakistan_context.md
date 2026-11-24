# Elderly UX, ads and the Pakistan / South Asia context for LiveHealthy: Vitals

Research date: 24 Nov 2026. About 18 search/fetch calls. Several full texts (PMC, IDF Atlas country page) blocked automated fetching (reCAPTCHA / redirect loop), so some figures come from search-result extracts of those pages or from news reports quoting them. This is flagged where it applies. Items marked "[standard reference, not re-fetched]" are long-standing published standards cited from their stable primary URLs. They were not re-read in this session.

## Q1. Usability guidelines for older adults on mobile health apps (targets, fonts, contrast, navigation, onboarding, errors, cognitive load, notifications, voice, trust; WCAG 2.2, Android)

### Takeaway
The literature agrees on large, well-spaced, clearly labelled buttons, high contrast, shallow navigation and explicit feedback. It is thin on text entry, button feedback and font type, and it gives few hard numbers. The concrete numbers come from platform standards: Android 48x48dp targets with 8dp spacing, WCAG 2.2 24x24 CSS px minimum (AA), 44x44 (AAA, older-adult friendly), 4.5:1 text contrast, and testing at Android 14+'s 200% nonlinear font scale.

### Cited Findings
- Systematic review (JMIR mHealth uHealth 2023, Gomez-Hernandez et al.) of usability-tested design guidelines for users over 60, published 2010–2021. Guidelines focus heavily on visual and haptic issues (high contrast, button type, button size). Textual interface elements (ease of text entry, button feedback, font type) are largely neglected. — [JMIR mHealth uHealth 2023;11:e43186](https://mhealth.jmir.org/2023/1/e43186)
- A 2021 JMIR mHealth systematic review of interface and persuasive-feature recommendations for older users' mHealth apps notes that adoption and use are often low because of inappropriate design. — [PMC8510293](https://pmc.ncbi.nlm.nih.gov/articles/PMC8510293)
- Font-size systematic review (Hou, Anicetus & He, Frontiers in Psychology, Aug 2022). Older adults preferred larger fonts, but beyond a critical size readability declines (more scrolling, broken line flow). The authors propose visual angle in arcminutes as a uniform font-size metric. I could not retrieve their exact recommended minimum. — [Frontiers in Psychology 2022, 10.3389/fpsyg.2022.931646](https://www.frontiersin.org/articles/10.3389/fpsyg.2022.931646/full)
- Age-friendly design systematic review (Amouzadeh et al., 2025): 1,556 records screened, 132 included. It calls for research on AI-driven personalisation, long-term usability studies and culturally inclusive apps, which is a gap relevant to Urdu-speaking users. — [PMC12350549](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12350549/)
- Android: interactive elements should be at least 48x48dp, with at least 8dp between them. The touch target can extend beyond the visible icon through padding. — [Android Accessibility Help: Touch target size](https://support.google.com/accessibility/android/answer/7101858)
- Android: system text scaling only affects text sized in sp. Fixed-height containers clip enlarged text, so use a minimum height (at least 48dp) that can grow. — [Android Accessibility Help: Text scaling](https://support.google.com/accessibility/android/answer/12159181)
- Android 14 introduced nonlinear font scaling up to 200%. Large text scales at a lower rate than small text. Flutter recommends testing the UI at the maximum 200% setting. — [Flutter breaking change: Android 14 nonlinear text scaling](https://docs.flutter.dev/release/breaking-changes/android-14-nonlinear-text-scaling-migration)
- WCAG 2.2 SC 2.5.8 Target Size (Minimum, AA): targets at least 24x24 CSS px, or adequately spaced. SC 2.5.5 Target Size (Enhanced, AAA): 44x44 CSS px. SC 1.4.3 Contrast (Minimum): 4.5:1 for normal text, 3:1 for large text. SC 1.4.11 Non-text Contrast: 3:1 for UI components and graphical objects such as chart lines and flag chips. SC 1.4.1 Use of Color: colour must not be the only means of conveying information. SC 3.3.1/3.3.3 Error Identification and Suggestion. SC 3.3.7 Redundant Entry and 3.3.8 Accessible Authentication (new in 2.2). [standard reference, not re-fetched] — [W3C WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- W3C WAI's older-users material maps age-related changes (vision, dexterity, hearing, cognition) onto existing WCAG criteria rather than a separate standard. [standard reference, not re-fetched] — [W3C WAI: Older Users and Web Accessibility](https://www.w3.org/WAI/older-users/)

### Inferences
- The app already covers the main evidence-backed items: large keypad, large text, text labels on colour flags (meets WCAG 1.4.1), and 1.3x font adjustments. The remaining gaps are probably these:
  - Test at the 200% nonlinear scale, not just 1.3x.
  - Check 3:1 non-text contrast on chart lines, reference bands and amber flags. Amber on white often fails.
  - Raise primary actions toward 56–64dp and well beyond 44px AAA.
  - Add explicit save confirmation with an undo, instead of silent saves or modal "are you sure" dialogs.
  - Keep navigation one to two levels deep, with a persistent "Add reading" action.
  - Make TalkBack labels read the value with its unit and status, e.g. "Blood pressure 150 over 95, high, amber".
- The literature neglects text entry and button feedback, and logging readings is exactly that. So the existing custom keypad, with visible feedback on each digit press, haptics and range-plausibility warnings (e.g. "Did you mean 120?" for 1200), is where the app can add real value.
- Notifications and voice input: I found no usable cited evidence this session (see Gaps). General practice suggests one clear reminder per scheduled measurement, in plain words, with the action in the notification itself.

### Gaps
- No numeric minimum font size (pt/sp) for older adults could be extracted from Hou et al. 2022, because the PMC full text was blocked. The Gomez-Hernandez 2023 guideline table could not be fetched either.
- No cited evidence found this session on notification design, voice input or trust signals specifically for older mHealth users.
- The 48dp figure is Google's general guidance, not an older-adult-specific value. Older-adult studies are often quoted at 9–19 mm, but I did not verify any source for that.

## Q2. How older users experience in-app ads, and the least harmful formats

### Takeaway
There is no rigorous study of older adults and accidental in-app ad taps. The indirect evidence is consistent: older adults find blended (native) ads harder to spot, mobile adds cognitive load, and older users rarely click ads on purpose. Google's own AdMob rules already prohibit the placements most likely to trap older users. For a health logbook for the elderly, the least harmful options are no ads on data-entry and alert screens, a clearly labelled static banner away from controls, and rewarded or opt-in formats rather than interstitials.

### Cited Findings
- Saryazdi, Hou & Chambers (CogSci 2020): both younger and older adults were less accurate and slower at detecting native ads than traditional ads. Older adults had greater difficulty detecting native ads on webpages. There was no age difference with audio. — [CogSci 2020 paper](https://escholarship.org/uc/item/54h18974)
- Boston University / Digital Journalism (2021): more motivated readers recognised native ads more often, but motivation did not compensate for the extra cognitive effort of mobile. Growth in mobile news use has been driven mainly by older and lower-income adults. — [BU research summary](https://bu.edu/com/research/native-advertising-in-a-mobile-era)
- FTC-commissioned study (CHI 2018): consumers cannot always tell ads and paid content from unpaid content. More salient label placement helped. — [Unpaywall record 10.1145/3170427.3188533](https://unpaywall.org/10.1145%2F3170427.3188533)
- Industry survey (Pontiflex/Harris, 2010; self-reported and dated): about 47% of mobile ad clicks were judged accidental. — [PocketGamer.biz](https://www.pocketgamer.biz/news/27018/almost-half-of-all-clicks-on-mobile-ads-are-accidental/)
- App Annie/Button survey (2017): 49% of baby boomers rarely click a mobile ad deliberately, and 24% never do. — [eMarketer](https://www.emarketer.com/content/b23d8933-4f9b-4850-a9cd-71d3005c6f23)
- Academic work on detecting accidental clicks from dwell time notes that accidental clicks are more likely in mobile apps. — [arXiv 1804.06912](https://arxiv.org/pdf/1804.06912)
- AdMob banner policy. Google names banners placed close to buttons or navigation as one of the biggest causes of accidental clicks. Banners must not overlap content or move as the user scrolls, which is a policy violation. — [AdMob: banner ad guidance](https://support.google.com/admob/answer/6275345); [AdMob blog: banner implementation guidance](https://blog.google/products/admob/admob-banner-ad-implementation-guidance/)
- AdMob interstitial policy and best practices:
  - Interstitials only at logical breaks between content.
  - Not on app open or exit, and not unexpectedly mid-task.
  - At most one interstitial per two user actions, and this includes the Back button.
  - Close buttons must not overlap or sit next to the ad.
  - A launch interstitial needs a splash/preload pattern.
  - Non-compliance can lead to invalid activity or ad serving being disabled.
  — [AdMob interstitial policy](https://support.google.com/admob/answer/6201362); [Interstitial best practices](https://support.google.com/admob/answer/6066980); [AdMob blog: splash pages](https://blog.google/products/admob/using-splash-pages-to-avoid-unexpected-launch-interstitials/)

### Inferences
- The elderly audience combines tremor or low dexterity, large font scaling (which pushes content toward the edges) and weaker native-ad detection. That makes accidental taps and "is this part of the app?" confusion more likely than the general-population figures above suggest.
- Medical-looking ads (supplements, "cure diabetes" products) next to red flags could be mistaken for the app's own recommendation. This is a trust and liability risk. Use AdMob category blocking for health/pharma/supplement categories, show no ads on reading-entry, flag-result or alert screens, and never use native ad formats styled like app cards.
- Least harmful formats, in order:
  1. No ads, with a paid "remove ads" unlock.
  2. Rewarded, opt-in ads, e.g. "watch an ad to unlock a PDF report for the doctor".
  3. A single fixed adaptive banner on the history/chart screen, separated from controls by more than 8dp plus a clear "Ad / اشتہار" label.
  4. Interstitials are the most harmful and should be avoided.
- Older users typically do not click ads on purpose (boomer survey above). Ad revenue per elderly user will be low, and much of it may come from accidental clicks that Google can classify as invalid.

### Gaps
- No peer-reviewed study found that measures older adults' accidental tap rates on in-app ads, or ad confusion in health apps specifically.
- No data found on AdMob eCPM for Pakistan or for health apps.

## Q3. Pakistan market context: disease burden, devices, connectivity, sharing, language, caregivers, devices/units, payments, pricing

### Takeaway
Pakistan has the world's highest adult diabetes prevalence (IDF Atlas 2025: 31.4% age-standardised, 34.5M adults), and about 42% of adults aged 30–79 have hypertension, with only 12% controlled. The phone base is overwhelmingly Android (about 92% of mobile) and spread widely across Android 11–16. WhatsApp reaches about 92M users. Mobile speeds have improved (32 Mbps median). Google Play payment in Pakistan is the main monetisation friction: cards plus carrier billing, which was disrupted in 2022, and I found no evidence that JazzCash or Easypaisa wallets work in Play.

### Cited Findings
**Disease burden**
- IDF Diabetes Atlas, 11th edition (2025), Pakistan country page, data year 2024:
  - 31.4% age-standardised diabetes prevalence among adults aged 20–79, the highest in the world, rising to 34.2% by 2050.
  - About 34.5M adults with diabetes, projected 70.2M by 2050. This is the fourth-highest number of adults with diabetes worldwide.
  - Figures were taken from the search extract, because the page itself redirect-looped.
  — [IDF Diabetes Atlas: Pakistan](https://diabetesatlas.org/data-by-location/country/pakistan)
- Several Pakistani outlets report 30.8% instead. The discrepancy is unexplained; it may be crude vs age-standardised or a different data release. — [The News](https://thenews.com.pk/print/1299445-pakistan-ranks-first-globally-in-diabetes-prevalence); [Gulf News](https://gulfnews.com/world/china-india-pakistan-us-bangladesh-egypt-iran-philippines-saudi-arabia-top-20-diabetes-hotspots-1.500365153); [ProPakistani, Apr 2025](https://propakistani.pk/2025/04/09/pakistan-tops-global-diabetes-rankings/)
- Press coverage of the same Atlas: 26.9% of adults have undiagnosed diabetes (Pakistan fifth globally). Annual diabetes spending is about US$2.7B, or about US$79 per patient, among the lowest worldwide. — [ARY News](https://arynews.tv/34-5-million-people-in-pakistan-are-living-with-diabetes); [Pakistan Observer](https://pakobserver.net/idf-report-reveals-diabetes-prevalence-in-pakistan/)
- WHO Global Hypertension Report 2025 (as reported):
  - 42% of Pakistani adults aged 30–79 have hypertension, about 38.6M people.
  - Only 12% have it controlled.
  - Pakistan has no national BP control target and no updated hypertension guidelines.
  — [The News](https://www.thenews.com.pk/latest/1345934-nearly-42pc-pakistanis-hypertensive-only-12pc-control-it-who)
- About 70% of people with hypertension are unaware of it (experts, May 2025). Hypertension is linked to about 400,000 deaths a year. — [UrduPoint](https://www.urdupoint.com/en/pakistan/70-of-pakistanis-with-hypertension-unaware-o-1980771.html); [Arab News](https://www.arabnews.pk/node/2643921)
- The National Diabetes Survey of Pakistan 2016–17 (about 10,800 adults) found 46.2% hypertension prevalence. There is no recent nationally representative hypertension survey; the last full one is more than 20 years old. — [Challenges of managing hypertension in Pakistan, review](https://pmc.ncbi.nlm.nih.gov/articles/PMC10268336)

**Digital and device base**
- DataReportal "Digital 2027: Pakistan" (published 5 Nov 2026; data Oct/end-2026):
  - 149M internet users, 57.3% penetration, up 1.6% year on year.
  - 207M mobile connections (79.4% of the population), of which 79.8% are broadband (3G/4G/5G).
  - 94.1M social media identities (36.1%).
  - Median mobile download speed 32.01 Mbps (Ookla), up 31.7% in the year to Aug 2026. Median fixed speed 18.49 Mbps.
  - Social media identities are 39.4% female and 60.6% male. Facebook's adult ad audience is 81% male.
  — [DataReportal Digital 2027 Pakistan](https://datareportal.com/reports/digital-2027-pakistan)
- StatCounter, Pakistan, mobile/tablet/console OS, June 2026: Android 91.6%, iOS 8.3%. — [StatCounter OS share Pakistan](https://gs.statcounter.com/os-market-share/mobile-tablet-console/pakistan)
- StatCounter Android version share, Pakistan, July 2026: Android 13 18.2%, 11 15.0%, 15 13.2%, 16 11.9%, 12 11.5%, 14 9.9%. The rest (Android 10 and older) was not itemised in the extract. — [StatCounter Android versions Pakistan](https://gs.statcounter.com/android-version-market-share/mobile-tablet/pakistan)
- PTA-sourced figures (Aug 2025): Facebook 101.6M, YouTube 96.6M, WhatsApp 91.7M active users. — [Samaa TV](https://adminpanel.samaa.tv/2087338556-social-media-users-in-pakistan-cross-51-6m-facebook-most-popular); [Daily Times tag page](https://dailytimes.com.pk/tag/51-6-million/)
- PTA, Nov 2026: about 96M YouTube users, and about 100M TikTok accounts. — [ProPakistani, 3 Nov 2026](https://propakistani.pk/2026/11/03/pakistan-tops-world-in-watching-youtube-videos-pta/)
- WhatsApp has had nationwide disruptions in Pakistan (e.g. July 2024), which PTA called technical. — [Geo](https://www.geo.tv/latest/555612-ongoing-whatsapp-disruption-in-pakistan-likely-technical-glitch-says-pta); [ProPakistani](https://propakistani.pk/2024/07/21/confirmed-whatsapp-not-working-properly-for-millions-of-pakistanis/)

**Language**
- Roman-txt (MobileHCI 2017, 346k messages from 116 mostly student users): Roman Urdu is the most widely adopted texting style in Pakistan. Many participants were not comfortable in English, and poor Urdu keyboards were a driver. — [Roman-txt (Flinders)](https://researchnow.flinders.edu.au/en/publications/roman-txt-forms-and-functions-of-roman-urdu-texting/)
- Early phones could not send Urdu script, so transliteration to Latin script became the habit. — [The World / PRI, 2013](https://theworld.org/stories/2013/08/14/will-pakistans-urdu-script-be-lost-texting-translation)

**Home devices**
- Glucometers sold in Pakistan include:
  - Accu-Chek Instant S (Roche Pakistan) and Accu-Chek Guide (endorsed locally by Wasim Akram).
  - OneTouch Ultra and Abbott Precision Xtra.
  - Sinocare Safe AQ Voice, Beurer GL 50 Evo.
  - Budget meters: Certeza GL-110 about Rs 2,000, LifeChek about Rs 600.
  — [Healthwire Accu-Chek Instant S](https://healthwire.pk/pharmacy/medicine/accu-instant-meter); [ProPakistani](https://propakistani.pk/?p=379938); [Ubuy OneTouch](https://www.ubuy.com.pk/en/brand/one-touch-ultra); [Healthwire Sinocare](https://healthwire.pk/pharmacy/medicine/sinocare-safe-aq-voice-glucometer); [Oladoc Certeza](https://oladoc.com/pharmacy/medicine/certeza-glucometer-gl-110); [Beurer Pakistan](https://beurer.pk/shop/category/blood-glucose-monitors)

**Payments**
- Google Play carrier billing listed for Jazz, Telenor Pakistan, Ufone and Zong. — [ProPakistani how-to](https://propakistani.pk/how-to/how-to-buy-apps-from-playstore-using-your-mobile-number/); [Phoneworld (Jazz DCB)](https://www.phoneworld.com.pk/jazz-offers-customers-direct-carrier-billing-for-purchases-on-google-play/)
- In 2022 the State Bank of Pakistan revoked DCB for mobile operators, leaving about US$34M owed. Google said that from 1 Dec 2022 Pakistani users could pay only by credit/debit card until other methods returned. The finance ministry later agreed to clear payments and a Play suspension was averted. Current DCB status is unverified. — [The News](https://thenews.com.pk/print/1014814-dcb-crisis-google-changes-payment-mechanism-to-purchase-apps); [The News](https://thenews.com.pk/latest/1015641-finance-ministry-agrees-to-pay-google-on-aminul-haqs-advice); [Pakistan Observer](https://pakobserver.net/pakistanis-can-make-play-store-purchases-via-credit-debit-cards-from-dec-1-confirms-google/)
- Google's accepted-payment-methods page says methods vary by country. — [Google Play Help](https://support.google.com/googleplay/answer/2651410?hl=en)
- JazzCash and Easypaisa wallets appear as payment methods through Xsolla, a third-party game payments provider, not Google Play. JazzCash Mastercard debit cards can be added to Google Wallet, and a card can then be used in Play like any debit card. — [Xsolla blog](https://xsolla.com/blog/introducing-new-alternative-payment-methods-in-pakistan); [PakWheels forum on Google Wallet launch](https://www.pakwheels.com/forums/t/google-wallet-finally-launched-in-pakistan/3017076)

### Inferences
- The app's target condition set (BP plus glucose) matches the two largest chronic-disease burdens in the country. Very high undiagnosed and uncontrolled rates suggest that "regular home logging plus a shareable summary for the doctor" is a genuine need.
- minSdk: about 85%+ of Pakistani Android traffic is on Android 11 or newer, but a tail on 10 and older exists (not quantified). Keep minSdk at or below 26–28 if possible, and keep the APK/AAB small. Low-RAM devices and Android Go were not quantified here.
- 32 Mbps median mobile speed means connectivity is less of a barrier than before. Data cost and patchy rural coverage still argue for offline-first logging with background sync.
- WhatsApp is the obvious sharing channel: about 92M users, and families coordinate on it. A "Share summary to WhatsApp" action (image or PDF through the Android share sheet, not a WhatsApp API) fits local behaviour. Disruptions argue for keeping generic share or PDF as a fallback.
- Language: Urdu script (Nastaliq) is right for formal app UI. Users, especially younger family caregivers, may search and type in Roman Urdu. Play store listing keywords and any free-text notes should accept Roman Urdu, e.g. "sugar", "BP", "sugar check".
- Units: in Pakistani clinical practice and on local glucometers, glucose is overwhelmingly reported in mg/dL. This is a strong expectation, but NOT verified by a source this session. Default to mg/dL for the Pakistan locale and keep mmol/L for diaspora users (UK caregivers).
- Monetisation: card-only Play payment for many users (low card penetration, an unverified current DCB state) suggests:
  - low conversion on paid tiers, and one-time unlocks priced low;
  - diaspora children paying from abroad (UK/Gulf/North America cards) as a promising payer segment, though no source found for this.
- The ad-reach skew (Facebook ad audience 81% male) means elderly women may be under-reached through social ads. Organic routes (family referral, WhatsApp sharing) matter.

### Gaps
- No source found this session for:
  - Android Go or low-RAM device share in Pakistan;
  - mobile data prices (PKR per GB);
  - smartphone ownership among adults over 60;
  - Urdu literacy rates vs Roman Urdu preference among older adults;
  - caregiver dynamics with children abroad (diaspora size, remote health management studies);
  - home BP monitor brand share (Omron and others not verified);
  - mg/dL vs mmol/L usage;
  - current DCB availability;
  - typical prices of premium health apps in the Pakistan Play store.
- Fetching the PTA Annual Report 2025 (https://www.pta.gov.pk/assets/media/Annual Report 2025-25 Nov 25.pdf) would probably fill teledensity, broadband and data-price gaps. It was not fetched in this session.
- WHO hypertension numbers come from press coverage, not the WHO country profile itself.

## Q4. Local regulation relevant to a logbook app (DRAP, PMDC, telehealth)

### Takeaway
DRAP regulates medical devices under the Medical Devices Rules 2017, and the device definition includes software. No DRAP guidance specifically classifying standalone software or apps was found. A logbook that only records user-entered values and compares them with general reference ranges is probably low-risk, but that is not confirmed. Avoid diagnostic or treatment claims, and get local regulatory advice before adding anything like insulin-dose suggestions.

### Cited Findings
- DRAP regulates medical devices under the Medical Devices Rules, 2017, made under the DRAP Act 2012. The rules were amended through April 2022, and there is a later amendment, S.R.O. 1049(I)/2025. — [DRAP Medical Devices Rules 2017 (updated to Apr 2022), PDF](https://www.dra.gov.pk/wp-content/uploads/2022/10/Medical-Devices-Rules-2017-updated-upto-april-2022-2.pdf)
- The definition of medical device includes "software" intended for human use for medical purposes. Classification is risk-based, with rules written for invasive and non-invasive devices; no software-specific rules were surfaced. — [RegDesk Pakistan summary (third party)](https://www.regdesk.co/resource-library/pakistan); [meddeviceguide (third party)](https://meddeviceguide.com/blog/pakistan-drap-medical-device-registration-classification-import-licensing-guide)
- DRAP launched an e-service portal for medical device licensing and registration on 21 July 2025. — [US ITA market intelligence](https://www.trade.gov/market-intelligence/pakistan-lauches-online-portal-medical-device-registration-part-its-digital)
- For comparison (not Pakistani law): Singapore's HSA does not regulate software as a medical device when its output is based solely on established clinical guidelines. — referenced in search results for [RAPS Asia-Pacific roundup](https://www.raps.org/resource/asia-pacific-roundup-drap-publishes-guidance-on-tr.html) (source attribution of this HSA point not verified)

### Inferences
- Keep store copy and in-app text as a "logbook / record-keeping" tool with "general adult reference ranges, not a diagnosis; consult your doctor". The app's existing flag-text approach fits this.
- If v1.1 adds clinician-facing features (doctor portal, e-consults), PMDC registration and telemedicine rules would become relevant. These were not researched here.

### Gaps
- Not found:
  - DRAP guidance specific to software as a medical device or mobile apps;
  - the content of S.R.O. 1049(I)/2025;
  - PMDC or federal/provincial telehealth guidance (for example, any Sehat Kahani-era telemedicine rules);
  - Pakistan's Personal Data Protection Bill status in 2026, which would matter for health data in Firestore.
