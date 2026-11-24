# Adding Google AdMob to LiveHealthy: Vitals: rules, risks, economics (research notes, 24 Nov 2026)

Scope: Flutter Android health app (Play category Medical; Health apps declaration "Diseases and conditions management" + "Nutrition and weight management"; 18+; not Designed for Families; users mostly in Pakistan, many elderly or caregivers). Today: no ads, Data safety says no sharing and no advertising ID. All pages were fetched or searched on 24 Nov 2026 unless marked otherwise. A few items below come from my prior knowledge and are marked "UNVERIFIED" in the Gaps sections. Check them before relying on them.

## 1. AdMob and Google Publisher policies for health apps (personalization, sensitive categories, health data in ad requests, NPA, RDP)

### Takeaway
Google's publisher rules say a publisher may not use Google ad code to target personalized ads on sensitive information, and health or medical information is the named example, including data from apps aimed at a health-related group. The app must never put vitals, conditions or other health-derived values into ad requests (keywords, custom targeting, content URLs) or send PII. The safest approach for a Medical-category app is non-personalized ads, or at least passing no health signals, plus Restricted Data Processing for US-state users.

### Cited Findings
- AdMob publishers "must comply with our online AdSense Program policies". Google "reserve[s] the right to disable ad serving to your app and/or disable your AdMob account at any time". — [AdMob program policies index](https://support.google.com/admob/answer/6128543)
- Google Publisher Policies/Restrictions: publishers may not use Google's products or ad code to target personalized ads based on sensitive information. "Health or medical history or information" is the example, including data from sites or apps that market to a specific health-related group. — [Google Publisher Policies](https://support.google.com/publisherpolicies/answer/10437486)
- The same page says publishers must "not pass any information to Google that Google could use or recognize as personally identifiable information." — [Google Publisher Policies](https://support.google.com/publisherpolicies/answer/10437486)
- Google's personalized-ads policy (advertiser side) lists Health among the sensitive interest categories with targeting restrictions. Advertiser-curated audiences "cannot be used if promoting in sensitive interest categories". Google's predefined audiences automatically exclude sensitive user signals. — [Google Ads personalized advertising policy](https://support.google.com/adspolicy/answer/143465)
- The same policy forbids sharing PII with Google through data segment tags, combining PII with pseudonymous data, and sending precise location without consent. A personalization opt-out signal (`allow_ad_personalization_signals`) exists. — [Google Ads personalized advertising policy](https://support.google.com/adspolicy/answer/143465)
- AdMob behavioral policies: publishers may not click their own ads ("Testing your own ads by clicking on them is not allowed") and should use test ads. Google analyzes all clicks and impressions for invalid activity. Duplicate accounts get flagged. Ads may not appear in apps that pay or reward users for viewing or clicking ads. — [AdMob behavioral policies](https://support.google.com/admob/answer/2753860)
- Restricted Data Processing (US states): when an RDP signal is present, AdMob "won't serve ads based on a user's prior behavior" and sends non-personalized requests to bidders. RDP can be set for US-state traffic or globally, through a CMP (Google's Privacy & messaging, third-party or in-house) using IAB GPP signals. Google recommends GPP over the IAB US Privacy String, which IAB deprecated in January 2024. Under "US states regulations" in Privacy & messaging you can also choose which third-party buyers are allowed. Service-provider terms took effect 1 January 2023. — [AdMob RDP / US state regulations help](https://support.google.com/admob/answer/9561022)

### Inferences
- A Medical-category vitals app with diabetes and BP users is the kind of "app marketing to a health-related group" the publisher policy describes. The owner should never pass condition names (for example "diabetes" or "hypertension"), readings, or screen names that reveal conditions as `keywords`, `contentUrl` or custom targeting in `AdRequest`.
- The most conservative setup is non-personalized ads for all users: AdMob → Privacy & messaging / blocking controls, or per-request NPA. The flag name is an unverified item (see Gaps). Expect a lower eCPM than personalized ads. Personalized ads driven by Google's own non-sensitive signals are not clearly forbidden, but the app must not add any health signals.
- Use the AdMob category blocking controls (sensitive categories) to keep out ads that would be inappropriate or alarming for elderly patients (for example dating or gambling) or that look like medical advice. This is a product choice, not a confirmed policy requirement.

### Gaps
- I did not find a single Google page that says "medical apps must use NPA". The rule is the targeting restriction above. AdMob's own page on "requests for non-personalized ads" was not fetched.
- UNVERIFIED: in google_mobile_ads, NPA is requested with `AdRequest(nonPersonalizedAds: true)`, and child or under-age tags and the max content rating are set through `MobileAds.instance.updateRequestConfiguration(RequestConfiguration(...))`. Check this in the plugin API docs at https://pub.dev/documentation/google_mobile_ads/latest/.
- How the Flutter plugin sets RDP (on Android it is a network-extras "rdp" key, or relying on GPP from UMP) was not confirmed.

## 2. Ad placement policies: banners, interstitials, app-open, rewarded; best practice for elderly users

### Takeaway
Banners must not sit right next to buttons or navigation, float over content, or move while scrolling. Interstitials are banned on app load and exit, after every action (Back included), straight after another interstitial, and when they pop up while the user is busy with a task such as filling a form. For a vitals logger, the "Save reading" flow is exactly that kind of task. Rewarded and opt-in formats are exempt from Play's unexpected-interstitial rule.

### Cited Findings
- Banners: "banner ads should not be placed immediately next to interactive elements and app content" (navigation buttons, menu bars, chat boxes, galleries). An ad between interactive content and navigation controls invites accidental taps. Ads must not float over content or scrolling menus, or move while the user scrolls ("is against policy"). Google may disable ad serving for apps whose ads overlap content. — [AdMob: banner placement / accidental clicks](https://support.google.com/admob/answer/6275345)
- Interstitials, disallowed: on app load or exit; "after every user action, including but not limited to clicks, swipes, etc." (Back button included); "immediately after another interstitial"; placement that "interferes with navigating or interacting with the app's core content"; ads that "suddenly appear when a user is focused on a task at hand" (examples: filling out a form, reading); and ads that appear just after new content loads because of latency. — [AdMob: Disallowed interstitial implementations](https://support.google.com/admob/answer/6201362)
- Interstitial guidance: place them at "natural app transition points". Warning against "surprising users, presenting the users with too many ads, or obstructing their use of the app". "Ads should never be the primary focus of the app." — [AdMob interstitial guidance](https://support.google.com/admob/answer/6066980)
- Google Play Ads policy: unexpected full-screen interstitials are not allowed, including ones before a splash screen and at content start. "Full screen interstitial ads of all formats that are not closeable after 15 seconds are not allowed." Opt-in interstitials, rewarded ads and banners are exempt from that rule. Ads may not imitate app UI or system notifications. Users can't be forced to click an ad or share data before using the app. Ads must not appear on exit or on the lockscreen. "Made for Ads": repeated interstitials after user actions are a violation. The Advertising ID may be used only for advertising and analytics, and users' opt-outs must be honored. Ads must match the app's content rating. — [Google Play Ads policy](https://support.google.com/googleplay/android-developer/answer/9857753)

### Inferences
- An interstitial right after "Save reading" falls in a grey zone, since it sits close to "focused on a task" and "after a user action". With elderly users it also risks blocking the confirmation of a high BP or glucose reading. Recommended: no interstitials in log or save flows. If used at all, only at a true natural break (for example leaving the history or report screen), with a frequency cap such as at most once every few minutes and a few per day, and never right after another one.
- App-open ads would clash with Play's "before a splash screen / unexpected" rule if done badly, and with a medical app's need to open fast. Not recommended for this audience.
- Banners: put an anchored adaptive banner only on browse screens (history, charts), with clear spacing from the Save/FAB and the bottom navigation. Never put one on the reading-entry form or the emergency or alert screens. Elderly users with less precise taps raise the accidental-click risk, and AdMob can disable serving if accidental clicks are excessive.
- Rewarded ads are opt-in and policy-friendly, but a vitals app has few natural "rewards". A possible use is unlocking a PDF report export for a day. This is a product idea, not sourced.
- Native ads styled like reading cards could break the rule against ads that imitate app UI. They need a clear "Ad" label and a visually distinct style.

### Gaps
- No Google document specific to elderly users was found. The recommendations above are inferences from the accidental-click policy.
- AdMob's own app-open ad placement guidance and its rewarded-ad policy pages were not fetched.

## 3. Google Play changes: Ads declaration, Data safety, AD_ID permission, Health apps policy, Families

### Takeaway
Adding the Mobile Ads SDK changes the Data safety form from "no data shared" to declaring at least: Device or other IDs (advertising ID, app set ID), App interactions, Diagnostics, and approximate location derived from IP. All are collected and shared with Google for advertising, analytics and fraud prevention, encrypted in transit. The Ads declaration in App content must flip to "Contains ads", and the store listing will show "Contains ads". Apps targeting API 33+ need the AD_ID permission, which play-services-ads merges in automatically. Health data itself must stay out of ads.

### Cited Findings
- Google's Play disclosure for the Mobile Ads SDK lists data it collects and shares automatically for advertising, analytics and fraud prevention: IP address (may be used to estimate general location), user product interactions (app launches, taps, video views), diagnostics (launch time, hang rate, energy use), and device and account identifiers (Android advertising ID, app set ID, other identifiers). All of it is encrypted in transit with TLS. The guidance is written for SDK 25.5.0, and disclosures should be updated whenever the SDK is updated. Optional features such as advanced reporting may collect more. Ad ID collection can be turned off in the manifest. "Limited Ads" may disable sending the ad ID. — [Google Mobile Ads SDK: Play Data safety disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure)
- Data safety definitions: "collect" includes data sent off the device by SDKs. "Sharing" is a transfer to a third party, including through SDKs. An SDK that builds advertising profiles across multiple customers is not a service provider and must be declared as sharing. Building ad profiles can't count as ephemeral processing. The Android Advertising ID is declared under "Device or other IDs". Pseudonymous data must still be disclosed. The developer is responsible for SDK data. — [Play Console: Data safety section help](https://support.google.com/googleplay/android-developer/answer/10787469)
- Advertising ID policy: apps targeting Android 13 (API 33)+ must declare `com.google.android.gms.permission.AD_ID`. SDKs such as play-services-ads declare it in their library manifest, so it merges in by default. Deleted IDs return zeros. App Set ID is recommended for analytics and fraud. The advertising ID must be used in place of other device identifiers for advertising. — [Play Console: Advertising ID](https://support.google.com/googleplay/android-developer/answer/6048248)
- Play Ads policy: ads are part of the app and must follow Restricted Content and the app's content rating. Apps aimed at children must follow the Families ads rules. — [Google Play Ads policy](https://support.google.com/googleplay/android-developer/answer/9857753)
- Health Content and Services policy: health apps must complete the Health apps declaration and have a privacy policy covering personal and sensitive data. No unnecessary permissions. Non-medical-device apps need a disclaimer and a reminder to consult a professional. The page itself does not address ads or the sale of health data. — [Play: Health Content and Services](https://support.google.com/googleplay/android-developer/answer/16679511)
- Health Connect data is personal and sensitive user data under the User Data policy. A policy preview says transfer, sharing or licensed use must be only for providing core features and "may not be extended for any other purpose", with advertising and marketing as examples. Apps that use personal and sensitive data to serve ads must follow the Ads policy. The effective date of the preview wording was not confirmed. — [Play policy preview](https://support.google.com/googleplay/android-developer/answer/13996823); [Play User Data / Health Connect](https://support.google.com/googleplay/android-developer/answer/12991134)

### Inferences
- New Data safety answers: Data collected = yes, Data shared = yes. Types: Device or other IDs; App activity → App interactions; App info and performance → Diagnostics (and crash logs if applicable); Location → Approximate location (IP-derived). Check this against the SDK page at submission time. Purposes: Advertising or marketing, Analytics, Fraud prevention/security. The health info the app keeps stays "collected, not shared" (or whatever it is today). The form and privacy policy should say plainly that health readings are never shared with ad partners.
- The "Contains ads" label and the new data-sharing lines may lower trust and conversion among health users. This is a product risk, not a measured figure.
- If the app ever reads Health Connect data, that data must not feed ads in any way. Keep the ad SDK fully separate from the readings layer.
- Families policy does not apply, since the target audience is 18+ and the app is not in Designed for Families. Still set the max ad content rating to G or PG for this audience. This is a recommendation.
- Changing the Ads declaration and Data safety form triggers a new app review. Submit them together with the release that adds the SDK.

### Gaps
- The Play Console "Ads" declaration help page (App content → Ads) was not fetched. The "Contains ads" label behavior is from my general knowledge and is UNVERIFIED.
- The current Health Connect "prohibited uses" list was not retrieved directly.
- I found no explicit Play rule that bans ads in Medical-category apps. None appears in the policies I fetched.

## 4. Consent: UMP / IAB TCF v2.2 for EEA/UK/CH, US states, Pakistan, privacy options entry point

### Takeaway
Use Google's UMP SDK, exposed in google_mobile_ads as `ConsentInformation` / `ConsentForm`. Call `requestConsentInfoUpdate` on every launch, then `loadAndShowConsentFormIfRequired`, check `canRequestAds()` before any ad request, and show a "Privacy options" button in Settings when `getPrivacyOptionsRequirementStatus()` returns required. In AdMob Privacy & messaging, set up the GDPR (TCF) message for EEA/UK/CH and the US states message (GPP/RDP). Pakistan has no enacted general data protection law as of late 2026. Only PECA applies.

### Cited Findings
- Flutter UMP flow: call `ConsentInformation.instance.requestConsentInfoUpdate(params, onSuccess, onError)` every launch and don't rely on cached status. In success, call `ConsentForm.loadAndShowConsentFormIfRequired`. Check `getPrivacyOptionsRequirementStatus()` against `PrivacyOptionsRequirementStatus.required` and, if required, show a visible UI element that calls `ConsentForm.showPrivacyOptionsForm`. `canRequestAds()` "always returns false until you have called requestConsentInfoUpdate()". Check it both after the form and right after the update, guarded by a boolean. On error, the previous session's status is used. Testing: `ConsentDebugSettings(testIdentifiers: [...], debugGeography: DebugGeography.debugGeographyEea)`. Use `reset()` only in testing. — [AdMob Flutter: Privacy / UMP](https://developers.google.com/admob/flutter/privacy)
- US states: RDP and GPP via CMP. The US Privacy String was deprecated by IAB in January 2024. — [AdMob RDP help](https://support.google.com/admob/answer/9561022)
- Pakistan: secondary sources dated through 2026 agree the Personal Data Protection Bill (2023 version and a newer 2025 MoITT draft) is not enacted. They differ on its stage: cleared by Cabinet and awaiting Parliament, or stuck in Parliament (Dec 2025). PECA 2016 and its 2025 amendments create criminal liability for unauthorized disclosure of personal data. — [The Friday Times, 11 Dec 2025](https://www.thefridaytimes.com/11-Dec-2025/data-privacy-peril-pakistan-s-legal-vacuum-consequences); [DLA Piper Data Protection Laws of the World: Pakistan](https://www.dlapiperdataprotection.com/index.html?t=law&c=PK); [Pakcec 2026 guide](https://pakcec.com/data-protection-law-pakistan/); [RecordingLaw 2026 guide](https://www.recordinglaw.com/world-laws/world-data-privacy-laws/pakistan-data-privacy-laws/)
- Conflict: Wikipedia describes a "National Commission for Personal Data Protection" as active. Other sources say no independent data protection authority exists. — [Wikipedia: NCPDP](https://en.wikipedia.org/wiki/National_Commission_for_Personal_Data_Protection), contradicted by [DLA Piper](https://www.dlapiperdataprotection.com/index.html?t=law&c=PK)

### Inferences
- Even though the users are mostly in Pakistan, Play distribution is global. Any EEA/UK/CH or US-state user triggers the GDPR/TCF and US-state obligations, so set up UMP for every user. It shows nothing where it isn't required.
- Order: run the UMP flow first, then `MobileAds.instance.initialize()`, and only load ads when `canRequestAds()` is true. Google's Flutter quick-start page does not state this order (see section 7). This is standard Google sample practice.
- Pakistan's pending bill has, in its drafts, treated health data as sensitive. That part is unverified. Building to GDPR-level practice (no health data to ad partners) future-proofs the app.

### Gaps
- Google's AdMob help page on the TCF v2.2 requirement (Google-certified CMP required for EEA/UK since 16 Jan 2024; Switzerland added later) was not fetched. The requirement is well known, but its exact dates are UNVERIFIED here.
- The current list of US states covered by AdMob's US states message was not retrieved.

## 5. Privacy policy text changes

### Takeaway
The privacy policy must add a "Advertising" section. It should name Google AdMob as a third party; list the data the SDK collects (advertising ID or app set ID, IP / approximate location, app interactions, diagnostics) and its purposes (ads, analytics, fraud prevention); explain consent and opt-out (UMP privacy options, Android ad ID reset or delete); state that health readings are never shared with advertisers or used for ad targeting; and link Google's partner-sites policy.

### Cited Findings
- Data that the SDK collects and shares must be disclosed, and the developer is responsible for it. — [Play Data safety help](https://support.google.com/googleplay/android-developer/answer/10787469); [Mobile Ads SDK Play disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure)
- Health apps must have a privacy policy covering how they access, collect, use and share personal and sensitive data. — [Play: Health Content and Services](https://support.google.com/googleplay/android-developer/answer/16679511)
- Location used for ads must be disclosed in the privacy policy. The ad ID may be used only for advertising and analytics, and opt-outs must be honored. — [Google Play Ads policy](https://support.google.com/googleplay/android-developer/answer/9857753)
- When there is no ad ID, a persistent identifier may be used only with a privacy policy, in line with the DDA and privacy laws. — [Play: Advertising ID](https://support.google.com/googleplay/android-developer/answer/6048248)

### Inferences
- Suggested additions: (a) "We show ads through Google AdMob." (b) A data list matching the Data safety form. (c) "Your blood pressure, glucose, SpO2, pulse and weight readings are never sent to Google AdMob or any advertiser and are not used to choose ads." (d) Ads are non-personalized or contextual, if NPA is chosen. (e) How to change consent ("Privacy options" in Settings) and how to reset the Android ad ID. (f) Link to https://policies.google.com/technologies/partner-sites (URL not fetched). (g) If a "Remove ads" purchase exists, explain that ad SDK requests stop after purchase.

### Gaps
- No authoritative template was fetched. The wording above is a suggestion and should be reviewed against the current policy on livehealthy.homilabs.org.

## 6. Economics: Pakistan eCPMs, revenue per DAU, "remove ads" IAP, mediation

### Takeaway
Pakistan is a Tier-3 ad market. Illustrative 2026 benchmarks: rewarded about $2–3, interstitial $1–2, app-open $0.6–1.2, native $0.4–0.8, adaptive banner about $0.08–0.14 eCPM. Anecdotally, Pakistani banners often fall below $0.15. All of these are estimates, not measured AdMob averages. A banner-only health app in Pakistan will likely earn well under one US cent per DAU per day. Ads only pay off at large scale.

### Cited Findings
- Tier-3 eCPM, labeled "illustrative" and "not measured averages" (June 2026, Pakistan named as a Tier-3 example): rewarded video $2.00–3.00; interstitial $1.00–2.00; app-open $0.60–1.20; native $0.40–0.80; MREC $0.25–0.50; anchored adaptive banner $0.08–0.14; fixed 320×50 $0.06–0.10. Tier 3 is 0.05–0.18× US rates. US health & fitness ARPDAU is given as $0.05–0.12. The only Tier-3 ARPDAU is a worked example (puzzle game, 75% Tier 3 ≈ $0.019). — [RevenueLab AdMob eCPM benchmarks 2026](https://www.revenuelab.fyi/blog/admob-ecpm-benchmarks-2026) (ESTIMATE)
- A Flutter developer's 2026 write-up (anecdotal) reports Pakistani banner eCPM regularly below $0.15. I could not open the full article (HTTP 403), so this comes only from the search snippet. — [ottomancoder, Medium 2026](https://ottomancoder.medium.com/flutter-app-monetization-admob-vs-applovin-max-in-2026-with-real-numbers-from-south-asian-b428eee10196) (ANECDOTAL)
- A blog list gives Pakistan as "$0.29" with an undefined metric. Low reliability. — [SR Zone](https://www.thesrzone.com/2024/01/admob-ecpm-rates-by-country.html) (LOW QUALITY, 2024/25)
- Format order by eCPM: Rewarded Video > Interstitial > Splash > Native > Banner (games-focused, H1 2025). — [TopOn H1 2025 report](https://mores.toponad.com/reports/TopOn%20Global%20Mobile%20Games%20Monetization%20Report%20_%202025%20H1.pdf)
- Google lowered minimum prices for paid apps and in-app products in new markets, including Pakistan, in March 2021 (older). The exact PKR floor isn't stated. — [Android Developers Blog, Mar 2021](https://android-developers.googleblog.com/2021/03/sub-dollar-pricing-expansion-in-20.html). In 2014 the minimum was Rs 105 (historical). — [ProPakistani 2014](https://propakistani.pk/2014/02/07/google-starts-showing-pakistani-currency-for-apps-on-play-store/amp/)

### Inferences (all estimates)
- Worked example: 1,000 DAU in Pakistan, banner only, about 3 banner impressions per session, about 1.5 sessions per day, at about $0.10 eCPM. That is 4,500 impressions × $0.10 / 1000 ≈ $0.45 a day, about $14 a month, or about $0.00045 per DAU per day. Adding one capped interstitial per DAU per day at about $1.5 eCPM adds about $1.50 a day. Even then the total is only about $50–60 a month per 1,000 DAU. NPA, low fill and the 1.5–2.5% overall consent and fill loss would push this lower.
- A "Remove ads" one-time purchase priced roughly in the low hundreds of PKR could beat ad revenue for engaged caregivers, but conversion rates in Pakistan are unknown. Google Play's service fee (typically 15% for the first $1M a year, not fetched) applies. Restore and entitlement checks should run before the ad SDK initializes, so paying users never load ads or see a consent prompt.
- Mediation (AdMob mediation, or AppLovin MAX / ironSource as the mediator) adds network competition and usually helps fill and eCPM in low-tier markets. Each added network means another SDK in the Data safety form, the app-ads.txt file and the consent setup (more "shared" lines). For a small health app, start with AdMob only.
- Reputational and trust cost: elderly or patient users may read ads (especially health-product ads) as endorsements. Block unproven-supplement and medical-product categories where AdMob allows.

### Gaps
- No primary AdMob figures for Pakistan. Google does not publish country eCPMs. The owner's own AdMob reports after launch are the only real data.
- No published Pakistani "remove ads" conversion rate or the current Play PKR price floor was found. Check the Play Console pricing screen.
- Appodeal, ironSource, Business of Apps and Maf.ad country reports were not retrieved within the tool budget.

## 7. Flutter implementation: plugin, manifest, test IDs, adaptive/native, UMP order, app-ads.txt

### Takeaway
Use google_mobile_ads 9.2.0 (latest on pub.dev, published about late Oct 2026). Google's quick start requires Flutter 3.38.1+. Add the App ID meta-data to AndroidManifest, run UMP, then call `MobileAds.instance.initialize()`, then load ads. Host app-ads.txt at the root of the developer website listed on Play. AdMob crawls it within 24 hours, and the file establishes that the developer is an authorized seller.

### Cited Findings
- google_mobile_ads is at 9.2.0 (`^9.2.0`), "published 33 days ago" as of 24 Nov 2026. It supports banner, interstitial, rewarded and native. The pub.dev page does not list the minimum Android SDK. — [pub.dev google_mobile_ads](https://pub.dev/packages/google_mobile_ads)
- Quick start prerequisites: Flutter 3.38.1 or higher, the latest Android Studio, and an AdMob app ID. Add `<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-…~…"/>` inside `<application>`. Call `MobileAds.instance.initialize()` before loading ads. The Future completes on finish or after 30 s. The page does not state minSdk, compileSdk or Gradle versions, or consent ordering. — [AdMob Flutter quick start](https://developers.google.com/admob/flutter/quick-start)
- UMP API in the plugin: see section 4. — [AdMob Flutter privacy](https://developers.google.com/admob/flutter/privacy)
- app-ads.txt follows the IAB Tech Lab Authorized Sellers for Apps spec and is how app ownership is established. It goes at the root of the domain of the developer website on the Play listing (for example example.com/app-ads.txt). The crawler checks http and https, not "www." or "m.", and follows redirects. The line format is `google.com, pub-XXXXXXXXXXXXXXXX, DIRECT`. Every other mediated network's line must be added too. Verification takes up to 24 h. Firebase Hosting is suggested if the root can't host the file. — [AdMob: app-ads.txt](https://support.google.com/admob/answer/9363762)
- Use test ads during development. Clicking your own live ads is invalid activity. — [AdMob behavioral policies](https://support.google.com/admob/answer/2753860)
- The AD_ID permission merges from play-services-ads. — [Play: Advertising ID](https://support.google.com/googleplay/android-developer/answer/6048248)

### Inferences
- The domain matters. If the Play listing's developer website is `livehealthy.homilabs.org`, the crawler looks for `https://livehealthy.homilabs.org/app-ads.txt`, not `homilabs.org`, because it uses the hostname. If the listing points to homilabs.org, host it there. Check the Play listing contact URL. The file is ready to set up as soon as the AdMob app is linked to the Play listing.
- Architecture: put all ad code behind one service interface (initialize, consent, load banner, show interstitial) gated by an `isAdFree` entitlement. Keep the readings and repository layers with no dependency on the ad SDK, so no health value can reach an `AdRequest`.
- For Flutter adaptive banners, use the anchored adaptive size from `AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width)` (method name UNVERIFIED). Native ads in google_mobile_ads support `NativeTemplateStyle` with small and medium templates (UNVERIFIED), which avoids writing platform factories.

### Gaps
- UNVERIFIED (not fetched this session, from prior knowledge; check https://developers.google.com/admob/flutter/test-ads): Google's Android sample test unit IDs use publisher `ca-app-pub-3940256099942544`, for example adaptive banner `/9214589741`, interstitial `/1033173712`, rewarded `/5224354917`, native `/2247696110`, app open `/9257395921`. The test App ID is `ca-app-pub-3940256099942544~3347511713`.
- UNVERIFIED: the minimum Android SDK for the current Google Mobile Ads SDK (believed to be minSdk 23 since SDK 24.x) and the compileSdk / AGP requirements for plugin 9.x. Check the plugin CHANGELOG and https://developers.google.com/admob/android/quick-start.
- The Play Console "Ads" declaration steps were not fetched.
