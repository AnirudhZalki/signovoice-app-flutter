# External configuration required

The app compiles and runs without any of this: it starts in **guest mode** and every feature that needs an external service tells the person plainly that it is not set up. Nothing is faked. To turn the features on you need the following.

| Feature | What you must provide | Where it goes |
|---|---|---|
| Accounts (email, Google, phone OTP), sync, push, crash reports | A **Firebase project** with Authentication (Email/Password, Google, Phone), Firestore, Storage, Analytics, Crashlytics, Cloud Messaging. Add the Android app `com.anirudhzalki.signovoice` with your release **and** debug SHA-1/SHA-256. | `android/app/google-services.json` (git-ignored). The Gradle plugins are applied automatically when the file exists. |
| Google Sign-In | The **web client ID** from Firebase console → Authentication → Google | `--dart-define GOOGLE_SERVER_CLIENT_ID=…` |
| Security rules | Deploy `firestore.rules` and `storage.rules` (`firebase deploy --only firestore:rules,storage`) | Firebase CLI |
| Subscriptions | A Google Play Console app with **subscription products** `signovoice_premium_monthly` and `signovoice_premium_yearly`, each with a base plan and a **free-trial offer of 1 month** (Play decides eligibility). Upload a signed build to an internal testing track and add license testers. | Product IDs are configurable: `IAP_MONTHLY_ID`, `IAP_YEARLY_ID` |
| Purchase verification / entitlement | The backend in `docs/BACKEND_CONTRACT.md` (`/v1/subscriptions/verify`, `/v1/subscription`, `/v1/subscriptions/restore`) + Play Developer API service account + Real-time developer notifications | `--dart-define API_BASE_URL=https://…` |
| Advanced AI translation (premium) | `POST /v1/translate` on your backend | same `API_BASE_URL` |
| Live interpreters | Interpreter endpoints on the backend + a **LiveKit** server (Cloud or self-hosted) and token minting | `API_BASE_URL`, `LIVEKIT_URL=wss://…` |
| Online recognition (optional) | An inference service accepting hand-landmark JSON | `REMOTE_RECOGNITION_URL` |
| More sign videos / thousands of signs | Licensed sign clips + a dictionary pack (`GET /v1/dictionary`) or add clips to `assets/videos/` and re-run `python3 tools/content/build_dictionary.py` | — |
| Legal | Counsel-reviewed **Privacy Policy** and **Terms** published on a public URL (Play Console requires one). The in-app text (`lib/features/profile/presentation/legal/legal_content.dart`) is a plain-language draft that reflects what the app actually does. | `PRIVACY_POLICY_URL`, `TERMS_URL`, `SUPPORT_EMAIL` |
| Release signing | An upload keystore | `android/key.properties` (git-ignored) with `storeFile`, `storePassword`, `keyAlias`, `keyPassword` |
| Play Console declarations | Data safety form (camera, microphone, account info, purchase info, diagnostics — see the privacy screen for accurate answers), target audience, ads = none, content rating | Play Console |

## Build & run

```bash
flutter pub get
flutter gen-l10n
# development
flutter run --dart-define-from-file=config/dev.json      # copy config/dev.example.json first
# release App Bundle for Google Play
flutter build appbundle --release --dart-define-from-file=config/prod.json
```
`config/*.local.json` and `config/prod.json` should not be committed if they contain anything you consider private (none of the values are secrets, but keep them out of public forks).

## Versioning
`pubspec.yaml` `version: MAJOR.MINOR.PATCH+BUILD` → Android `versionName` / `versionCode`. Increase `BUILD` for every Play upload.

## Target SDK
`compileSdk 36`, `targetSdk 36`, `minSdk 24` (from Flutter 3.47 defaults; MediaPipe Tasks and ONNX Runtime need ≥ 24). Re-check Google Play's current target-API requirement before each release.

## Things to verify on a real device before publishing
1. **Hand-landmark mirroring.** The model was trained on a *horizontally mirrored* webcam feed. The app mirrors x by default (`Settings → Translation → Mirror hand input`). Confirm on a phone that signing "Hello"/"Yes" is recognised with both cameras; flip the toggle if not.
2. **Recognition quality.** The bundled model has 9 classes trained on 30 sequences each from one signer — expect limited accuracy for other people. See `tools/` and the legacy repo's `collect_data.py`/`train.py` to retrain with more signers, then replace `assets/models/*.onnx` and `labels.json` (label order **must** match training).
3. **Free trial + purchase flow** with a license-tester account.
4. **Interpreter call** end-to-end with two devices.

## Building the Play Store bundle (.aab)
1. `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. `cp android/key.properties.example android/key.properties` and fill it in (git-ignored).
3. `cp config/prod.example.json config/prod.json` and fill in `API_BASE_URL` etc. Keep `ENABLE_RAZORPAY` false for Play.
4. Bump the number after `+` in `pubspec.yaml` `version:` for every upload.
5. `flutter build appbundle --release --dart-define-from-file=config/prod.json`
6. Output: `build/app/outputs/bundle/release/app-release.aab` — upload it in Play Console (internal testing first).
   Without `key.properties` the bundle build now stops with an error instead of debug-signing.

### Build the .aab on GitHub (no local Android setup)
Actions → **Build release AAB** → *Run workflow* (set versionCode higher than your last Play upload). Download `…-aab` from the run's **Artifacts**.
Add these repo secrets first (Settings → Secrets and variables → Actions):
- `UPLOAD_KEYSTORE_BASE64` — `base64 -w0 upload-keystore.jks` (create the keystore with the `keytool` command above)
- `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` (usually `upload`)
- `GOOGLE_SERVICES_JSON_BASE64` — `base64 -w0 google-services.json` (optional; without it sign-in is off)
- `PROD_CONFIG_JSON` — the contents of your `config/prod.json` (optional; `API_BASE_URL`, `LIVEKIT_URL`, …)
