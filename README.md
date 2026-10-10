# SignoVoice — Breaking Barriers

*One Gesture. One Voice. One Connection.*

An AI-assisted accessibility app that helps sign-language users and people who don't sign communicate — Flutter, Material 3, Android-first (`com.anirudhzalki.signovoiceapp`).

| | |
|---|---|
| **Sign → Text / Sign → Voice** | Live camera → on-device MediaPipe hand landmarks → ONNX LSTM → smoothing → gloss → sentence → text / speech |
| **Voice → Sign** | Speech-to-text (or typing) → dictionary lookup → sign videos, unmatched words flagged honestly |
| **Live Interpreter** | Request a human interpreter; video/audio/chat over LiveKit; rating + issue reporting |
| **Learn / Practice / Dictionary** | 135 signs in 12 topics, lessons, camera practice with XP · streak · badges, searchable in English/Hindi/Kannada |
| **Premium** | 1-month free trial → auto-renewing subscription via Google Play Billing, **verified server-side** before anything unlocks |
| **Privacy & access** | Video never leaves the device; guest mode; history/progress/account deletion; dynamic text, high contrast, reduced motion, screen-reader semantics; English · हिन्दी · ಕನ್ನಡ |

## What is real, and what needs your services

Everything that can run locally does. Anything needing an external service **reports "not set up"** instead of pretending — see [docs/EXTERNAL_SETUP.md](docs/EXTERNAL_SETUP.md) for the exact list (Firebase project, Play Console products, backend, LiveKit, keystore). The backend API the app expects is specified in [docs/BACKEND_CONTRACT.md](docs/BACKEND_CONTRACT.md), and `firestore.rules` / `storage.rules` are included.

**Model honesty.** The bundled `assets/models/sign_language_model.onnx` (from the original SignoVoice-Z repo) recognises **9 signs** (A, B, C, Hello, I love you, No, Please, Thanks, Yes) and was trained on 30 sequences per class from one signer. It works as a real on-device engine, but expect limited accuracy for other people. The original `onnx_server.py` had the label order wrong; the app uses the order verified against the model (`assets/models/labels.json`, pinned by a test). Improving accuracy means retraining with more data and swapping the file — no code change.

## Architecture

```
lib/
  core/          config (dart-define), errors, theme (Material 3 light/dark/high-contrast), routing (GoRouter + session guards), services
  shared/        design-system widgets, camera session, l10n helpers
  features/
    auth/  profile/  home/  history/  notifications/
    sign_translation/   domain (engine interface, buffer, smoother, gloss, sentence) · data (ONNX, remote, MediaPipe) · presentation
    voice_translation/  dictionary/  learning/  practice/
    interpreter/        subscription/
  l10n/          generated ARBs (source of truth: tools/l10n/strings/*.txt)
```
Clean Architecture per feature (`data / domain / presentation`), Riverpod 3 for state, repository interfaces in front of Firebase / HTTP / LiveKit / billing so each can be swapped or faked. Key seams:

- `SignRecognitionEngine` → `LocalOnnxRecognitionEngine`, `RemoteRecognitionEngine`, `UnavailableRecognitionEngine` (never fabricates output). Chosen by `ModelRepository`.
- `TranslationEngine` → rule-based (local) with an optional remote AI engine for Premium, falling back automatically.
- `BillingService` (Google Play/StoreKit) → `PurchaseFlowController` → `SubscriptionRepository.verifyPurchase` → `Entitlement` (derived from dates by `TrialPolicy`, so a stale "trial" can't outlive its end).
- `CallService` → `LiveKitCallService`; `InterpreterRepository` → HTTP.
- `SignAssetRepository` → bundled pack + optional cached remote pack (scales to thousands of signs).

## Develop

```bash
flutter pub get
python3 tools/l10n/build_arb.py && flutter gen-l10n      # after editing tools/l10n/strings/*.txt
flutter analyze && flutter test                           # 138 tests
flutter run --dart-define-from-file=config/dev.json       # see config/dev.example.json
python3 tools/content/build_dictionary.py                 # rebuild the sign dictionary
python3 tools/icons/generate_icons.py                     # legacy launcher icons + Play icon
```
Strings: add `key | English | Hindi | Kannada` lines to `tools/l10n/strings/*.txt`; CI fails if generated ARBs are stale. There are no hard-coded user-facing strings in widgets.

## Testing
`test/` — unit tests (validators, routing guards, recognition pipeline, sentence builder, smoothing, model parsing, dictionary/search/text→sign, progress rules, trial/entitlement policy, purchase flow incl. verification failure and restore, notification planner, history, account deletion ordering), controller pipeline tests with fakes, and **widget tests** (guest journey, all tabs, Hindi/Kannada, dark mode, 2× text, tap-target and label guidelines, and a smoke test opening every screen in light/dark at 1.6× text). `integration_test/` holds the on-device journey; camera/purchase/interpreter steps are manual (see [docs/QA_CHECKLIST.md](docs/QA_CHECKLIST.md)).

## Legacy repo findings
See [docs/MIGRATION_PLAN.md](docs/MIGRATION_PLAN.md): label-order bug in the old server, and **SMTP credentials committed in the old repo's `.env` — rotate them and purge history.**
