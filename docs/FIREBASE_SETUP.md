# Firebase setup (matches the "Add Firebase to your Android app" screen)

1. **Register app** — Firebase console → your project → *Add app → Android*.
   - **Android package name:** `com.anirudhzalki.signovoiceapp` (must match exactly; it is `applicationId` in `android/app/build.gradle.kts`).
   - **App nickname:** `SignoVoice` (optional).
   - **Debug signing certificate SHA-1:** required for Google Sign-In and phone auth. Get it with
     `cd android && ./gradlew signingReport` (use the `debug` variant), or
     `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`.
     Later add the **release** keystore SHA-1 **and SHA-256**, and the **Play App Signing** SHA-1/256 from Play Console → *Setup → App signing*.
   - Click **Register app**.
2. **Download config file** — download `google-services.json` and put it at `android/app/google-services.json`. It is git-ignored; do not commit it.
3. **Add Firebase SDK** — *skip*. The Gradle plugin and FlutterFire packages are already wired: the build applies `com.google.gms.google-services` automatically when the JSON file exists.
4. **Next → Continue to console.**
5. In the console enable:
   - *Authentication → Sign-in method*: **Email/Password**, **Google**, **Phone**. For Google, copy the **Web client ID** (Google provider details) and build with `--dart-define=GOOGLE_SERVER_CLIENT_ID=<that id>`.
   - *Firestore Database* (production mode), then deploy rules: `firebase deploy --only firestore:rules,storage` (rules are in `firestore.rules`, `storage.rules`).
   - *Cloud Messaging* is optional (local reminders work without it).
6. Run: `flutter run --dart-define-from-file=config/dev.json` (copy `config/dev.example.json`).

Without `google-services.json` the app still runs: sign-in buttons show "This service isn't set up yet" and guest mode works.

## Google sign-in checklist (if the button shows an error)
In debug builds the error text ends with `[debug] …` telling you the cause:
- `notConfigured` / "firebase not configured": `android/app/google-services.json` is missing or for another package. The old web projects in the other repos (`inclusisignbyzynoxgeni`) are a different Firebase project and cannot be reused.
- `google clientConfigurationError` / developer error: the **SHA-1/SHA-256** of the key you signed with is not on the Firebase Android app, or the Google provider is not enabled. Add them, then **re-download** `google-services.json` (it must now contain an `oauth_client` of type 3 = web client).
- No `GOOGLE_SERVER_CLIENT_ID` needed when that web client is in `google-services.json`; otherwise pass the Web client ID with `--dart-define`.
- Email/password and phone also need their provider enabled; phone additionally needs SHA-256 and Play Integrity/reCAPTCHA set up.
