# AdMob — LiveHealthy: Vitals

Account: the HomiLabs AdMob account (publisher `pub-2087846699268567`, signed in as
homilabs.smc@gmail.com). These IDs aren't secret: the App ID ships inside the APK.

| What | ID | Created |
|---|---|---|
| App (Android, linked to Google Play `com.homilabs.livehealthy_vitals`) | `ca-app-pub-2087846699268567~7523537181` | 2026-11-24 |
| Banner — "Vitals - History banner" (AdMob only, no third-party partner bidding) | `ca-app-pub-2087846699268567/4316201171` | 2026-11-24 |

Status at creation: the app is verified; AdMob's app review is "Getting ready" (usually 2–3
days), and ad serving is limited until it's approved. New ad units can take up to an hour to
serve.

Debug builds must use Google's **test** ad unit IDs, never the real ones above. Clicking your
own live ads can get the AdMob account suspended.

## app-ads.txt
AdMob checks `app-ads.txt` on the developer website from the Play listing:
https://livehealthy.homilabs.org/. Upload this one-line file to that site's root (Hostinger),
next to index.html:

```
google.com, pub-2087846699268567, DIRECT, f08c47fec0942fa0
```

The same line is already live at https://homilabs.org/app-ads.txt for the other HomiLabs apps.
