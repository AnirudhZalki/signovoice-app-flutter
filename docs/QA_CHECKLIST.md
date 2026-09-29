# Final QA — status and what remains

Legend: ✅ verified in this repo (automated) · 🔶 implemented, needs a real device/account/service to verify · ❌ could not be done here

| Area | Status | Evidence / what remains |
|---|---|---|
| `flutter analyze` | ✅ | 0 issues |
| Unit + widget tests | ✅ | 138 passing (`flutter test`) |
| Compilation of Dart code | ✅ | analyzer + test runs compile the whole app |
| **Android build (`flutter build apk/appbundle`)** | ❌ | **Not run.** The build sandbox has no Android SDK (`dl.google.com` blocked). Gradle files, manifest and resources are written to current Flutter 3.47 / AGP 9 defaults but unbuilt — run `flutter build appbundle --release` (CI job `android-build` does a debug build). The two Firebase Gradle plugin versions in `android/build.gradle.kts` (google-services 4.4.3, crashlytics 3.0.4) could not be verified offline; they are only resolved when `google-services.json` exists. |
| Navigation | ✅ | guard rules unit-tested; all tabs + every screen opened in widget tests |
| Authentication | 🔶 | guest mode ✅; email/Google/phone need a Firebase project (`google-services.json`, SHA-1, Google client id) |
| Camera permissions | 🔶 | explanation-first `PermissionCard` flow implemented; verify system dialogs on device |
| Microphone permissions | 🔶 | same for Voice → Sign / calls |
| Sign recognition integration | ✅/🔶 | pipeline proven with a fake engine; ONNX engine + MediaPipe source compile against the real plugin APIs but were **not executed on a device**. The label order was verified by running the shipped ONNX on the training data (Python). Check mirroring (Settings › Translation) on a phone. |
| Sign → Text / Sign → Voice | 🔶 | logic ✅ (controller tests); camera UI needs a device |
| Voice → Sign | ✅ (typed) / 🔶 (speech) | text→sign covered; device speech recogniser needs a phone |
| Learning / Practice / Dictionary / History | ✅ | domain + widget tests; practice camera needs a device |
| Interpreter | ✅ (state machine) / 🔶 (media) | request→poll→connect→chat→end tested with fakes; needs backend + LiveKit + 2 devices |
| Subscription UI, trial logic, restore, entitlement | ✅ | policy + purchase-flow tests (verification failure never unlocks; restore; expiry) |
| Real purchases | 🔶 | needs Play Console products + license tester + backend verification endpoint |
| Logout / account deletion | ✅ | ordering tested (recent-login and offline failures keep local data) |
| Dark mode / localisation (en, hi, kn) | ✅ | widget tests |
| Accessibility | ✅/🔶 | tap-target + label guidelines pass on Home; 2× text, reduced motion, semantics implemented. Do a TalkBack pass on a device. |
| Offline / error states | ✅ | offline banner, retry states, camera/model/billing/AI unavailable states rendered in tests |
| Notifications | ✅ (planning) / 🔶 (delivery) | planner tested; verify OS delivery + boot rescheduling on device |
| Performance | 🔶 | frame throttling (~16 fps to detector, inference every 350 ms with in-flight guard, native background thread) implemented; profile on a mid-range phone |

## Manual device checklist
1. Fresh install → onboarding → guest → profile → home. Rotate, switch dark mode, set text size to largest.
2. Sign → Text with front and back camera: deny camera (explanation appears), allow, sign Hello/Yes/No/Please/Thanks/I love you/A/B/C; toggle *Mirror hand input* if left/right seem swapped; pause/resume, flip, flash, speak, copy, share, save, clear.
3. Airplane mode: on-device recognition still works; interpreter/AI/online show the offline messages.
4. Voice → Sign: deny mic (typing still works), allow, speak *"Where is the hospital?"*.
5. Practice each of the 9 signs; confirm XP/streak/badges; Learn lessons; bookmark; dictionary search in Hindi/Kannada.
6. Premium: with a license-tester account start the trial, kill the app mid-verification (purchase must re-deliver and verify), cancel in Play (status → cancelled with end date), restore on a second device, let it expire.
7. Interpreter: request → accept (backend) → video call both ways → chat → end → rate → report.
8. Settings → Privacy: clear history, reset progress, request server deletion, delete account (with and without recent login).
9. TalkBack: traverse Home, Sign → Text, Practice result, Subscription; confirm every control is announced with a label and state.
