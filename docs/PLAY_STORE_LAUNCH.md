# Launching SignoVoice on Google Play — step by step

## 0. Before you start (blockers)
- [ ] Google Play **developer account** ($25 one-time). *Personal accounts created after Nov 2023 must run a **closed test with ≥12 testers for 14 days** before Production access* — start this early.
- [ ] Upload keystore + signed `.aab` (see `docs/EXTERNAL_SETUP.md` → "Building the Play Store bundle" / "Build the .aab on GitHub").
- [ ] `google-services.json` in the build (Firebase sign-in) and **Play App Signing SHA-1/SHA-256 added to Firebase** after the first upload.
- [ ] Backend deployed (`docs/PAYMENTS_SETUP.md`, `docs/LIVEKIT_SETUP.md`) and `API_BASE_URL` in `config/prod.json`. `ENABLE_RAZORPAY` **false**.
- [ ] Public **privacy policy URL** (you have a `Signovoice-privacy-policy` repo — publish it with GitHub Pages and use that URL; it must mention camera, microphone, account data, analytics/crash data, purchases, account deletion).

## 1. Create the app (Play Console → Create app)
Name **SignoVoice — Breaking Barriers** · Default language English (India) · App · **Free** (subscriptions are in-app) · accept declarations.
Package is fixed by the build: `com.anirudhzalki.signovoice`.

## 2. App content (Policy → App content) — answers matched to this app
| Section | Answer |
|---|---|
| Privacy policy | your public URL |
| Ads | **No ads** |
| App access | Some features need login → give a **test account** (email + password, e.g. a reviewer user you create in Firebase Auth); mention guest mode works without login |
| Target audience | **13+** (or 18+ if you prefer); not designed for children |
| Content rating (IARC questionnaire) | Utility/communication; no violence, gambling, user-generated public content → expect **Everyone** |
| News / COVID / Government / Financial | No / No / No / No (it sells a subscription, but it is not a financial-services app) |
| Health | Not a medical app |
| Data safety | see below |
| Account deletion | Yes — in-app (Profile → Settings → Delete account) **and** give a web URL/instructions (the privacy-policy page can host them) |

**Data safety form** (what the app really does):
- *Collected & encrypted in transit:* **Email, name, user ID** (account), **Purchase history** (subscription status), **Crash logs & diagnostics** (Crashlytics), **App interactions** (Firebase Analytics), **Device/other IDs** (Firebase installation id, push token).
- *Camera & microphone:* used for sign recognition (processed **on device**, not sent) and for live interpreter calls (streamed to the other participant via LiveKit). Declare **Audio** and **Video** as *collected, not shared, optional (needed only for calls)*, purpose *App functionality*.
- Not sold. Data can be deleted on request (account deletion).
- Permissions in the manifest: INTERNET, ACCESS_NETWORK_STATE, CAMERA, RECORD_AUDIO, MODIFY_AUDIO_SETTINGS, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED — all explained by the above (RECEIVE_BOOT_COMPLETED re-schedules reminders).

## 3. Store listing (Grow → Store presence → Main store listing)
- **Short description (≤80):** `Sign language ↔ text & voice, live interpreters and lessons — on your phone.`
- **Full description (≤4000):** what it does (Sign → text/voice with on-device AI, Voice → sign, live interpreter video calls, lessons & practice, dictionary), languages (English, हिन्दी, ಕನ್ನಡ), accessibility, Free vs Premium (₹75/month or ₹200/6 months, 1-month free trial, cancel anytime in Play), honest limits ("recognition supports a limited vocabulary and works best in good lighting").
- **App icon:** `assets/store/play_icon_512.png` (512×512, already in the repo).
- **Feature graphic:** 1024×500 (create in Canva: blue #3157D5 background, two-hands logo, tagline "Breaking Barriers").
- **Phone screenshots:** at least 2, ideally 6–8 (1080×1920): Home, Sign→Text, Voice→Sign, Live interpreter, Learn, Premium. Take them from a real device with the production build.
- Category **Communication** (or Education) · contact email · website (optional).

## 4. Subscriptions (Monetize with Play)
Follow `docs/PAYMENTS_SETUP.md` → "Google Play": `signovoice_premium_monthly` ₹75 and `signovoice_premium_6months` ₹200, each with a 1-month free-trial offer. Subscriptions can only be created after an `.aab` with the billing permission has been uploaded. Link the **service account** for server verification and set up **RTDN**.

## 5. Release path (do in this order)
1. **Internal testing** → upload `.aab`, add yourself + testers (email list) → install from the opt-in link → test sign-in, payment with *license testers*, calls.
2. **Closed testing** (required for new personal accounts): ≥12 testers opted in for **14 consecutive days**; keep the app updated.
3. **Production** → *Apply for production access* (answer the short questionnaire) → Create release → upload the same/newer `.aab` → release notes → **Send for review**. First review usually takes a few days (up to ~7).
4. Staged rollout (e.g. 20% → 100%) and watch **Android vitals** and **Crashlytics**.

## 6. Pre-submission checklist
- [ ] versionCode higher than any earlier upload; release build tested on a real phone (camera + hand landmarks only work on device).
- [ ] Sign-in works from the **Play-installed** build (SHA from Play App Signing in Firebase).
- [ ] Subscription test purchase succeeds and Premium unlocks only after backend verification.
- [ ] Privacy policy URL, deletion URL, test account all filled in. No placeholder text ("lorem", test keys) anywhere. Razorpay disabled.
- [ ] Recognition limits are stated honestly in the listing (no medical/guaranteed-accuracy claims).
