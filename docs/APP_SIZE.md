# App size — why it is 350 MB and how to get it down

## Why 350 MB
Assets are tiny (**3.4 MB**: models, 5 short videos, fonts, dictionary). The size is **compiled native code**, and a **debug APK** (or a *universal* release APK) contains it **four times** (arm64, arm32, x86, x86_64), unshrunk, plus debug data. `flutter run` / `flutter build apk --debug` is never what users download.
The heavy native parts in this app: MediaPipe hand tracking (+ its 7.5 MB `hand_landmarker.task`), WebRTC for live calls, ONNX Runtime, LiteRT/TensorFlow Lite, the Flutter engine, Firebase/Google libraries.

## Build the small versions (what to ship)
| Goal | Command (PowerShell, from the project folder) | Result |
|---|---|---|
| **Google Play** (users download only their phone's slice) | `flutter build appbundle --release --target-platform android-arm,android-arm64 --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/prod.json` | `.aab`; Play shows the per-phone download size |
| **APK to share directly** (one file per CPU) | `flutter build apk --release --split-per-abi --target-platform android-arm64 --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/razorpay.json` | `app-arm64-v8a-release.apk` — works on virtually every phone made since 2017 |
Keep `build/symbols` (needed to read obfuscated crash reports). The GitHub workflow "Build release AAB" already uses these flags.

## Measure it (do this before and after every change)
- Locally: `python tools/size/apk_report.py build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (also accepts an `.aab`). Shows download vs installed size per category (MediaPipe, ONNX, WebRTC, Dart code, assets…) and the 20 biggest files.
- On GitHub: Actions → **App size report** → Run workflow → open the run's *Summary*.
Send me that output and I will tell you exactly which item to remove first. I could not build or measure inside my sandbox (no Android SDK), so any size figure I could give you would be a guess.

## Realistic expectation
A release arm64 build with every feature on is typically **well under half** of 350 MB, but the **35–50 MB** target needs the largest duplicate removed:

1. **Two recognition engines are bundled.** ONNX Runtime (`flutter_onnxruntime`, old 9-sign model) and LiteRT (`flutter_litert`, new 419-sign transformer). Only one is needed. The ONNX one is the current fallback because `assets/models/signovoice_model_labels.txt` is not in the repo yet. **When the label file exists (or after training with `docs/TRAINING.md`) remove ONNX:** delete `flutter_onnxruntime` from `pubspec.yaml`, `assets/models/sign_language_model.onnx`, `assets/models/labels.json`, `lib/features/sign_translation/data/local_onnx_recognition_engine.dart` and its use in `model_repository.dart`, remove the `ai.onnxruntime` ProGuard rule, run `flutter pub get`. This typically saves the ONNX native library (one of the biggest items) — I will do it for you the moment the labels are in.
2. x86 / x86_64 are already excluded from Play/APK builds above (`--target-platform`).
3. Dart code is obfuscated and symbols split (`--obfuscate --split-debug-info`), native symbols kept small (`SYMBOL_TABLE`), R8 + resource shrinking are on.
4. Further, only if measurement says they matter: drop unused Firebase pieces (`cloud_firestore`/`firebase_storage`/`firebase_messaging` if the features aren't needed), fetch the 5 sign videos on demand instead of bundling them.
