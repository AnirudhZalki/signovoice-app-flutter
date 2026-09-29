# SignoVoice — Phase 1 findings & rebuild plan

## 1. What exists today (inspected: `AnirudhZalki/Signovoice-Z`, 1188 files)

| Area | Finding |
|---|---|
| Stack | Python/Streamlit (`app.py`, 1983 lines), FastAPI ONNX server (`onnx_server.py`), Node static server, HTML/JS web UI. **No Flutter code, no Android project, no Firebase, no LiveKit, no payments, no auth.** |
| Model | `sign_language_model.onnx` (767 KB, opset 13): LSTM×3 → Dense → Softmax. Input `lstm_input` `[N, 30, 63]` float32, output `[N, 9]`. |
| Features | 30 frames × 63 values = **one hand, 21 MediaPipe Hands landmarks × (x, y, z)**, normalised image coordinates, zeros when no hand. |
| Classes | A, B, C, Hello, I love You, No, Please, Thanks, Yes (9). |
| Training data | `MP_Data/<class>/<n>.npy`, 30 sequences per class, `train.py` / `collect_data.py`. |
| Sign videos | `hello.mp4`, `A.mp4`, `B.mp4`, `c.mp4`, `Thank you.mp4` (+ 4 short webm; `working_app.mp4` is a 134-byte stub). ~48 MB total. |
| Other | Booking e-mail via SMTP, AI meeting summary (rule-based), gTTS, SpeechRecognition. |

### Bugs / risks found
1. **Label-order bug.** Running the shipped ONNX on the training data shows the model's output order is *alphabetical* (`A,B,C,Hello,I love You,No,Please,Thanks,Yes` — `train.py` used `os.listdir`). `onnx_server.py` uses `A,B,C,Hello,Thanks,I Love You,Yes,No,Please`, which **mislabels 5 of 9 classes**. The Flutter app uses the verified order in `assets/models/labels.json`.
2. **Secrets committed.** `.env` (SMTP credentials) is committed in the original repo. Not copied. **Rotate that password and purge it from history.**
3. **Tiny dataset** (30 sequences/class, single signer) — on-device accuracy will be limited. Confidence thresholds + smoothing are built in; retrain via `tools/`.
4. `web_model/` is a Teachable Machine image model with different labels — unused.
5. Privacy copy said no data collected while the server received camera frames; the new app documents what is processed.

## 2. Target architecture
Flutter + Material 3, Clean Architecture (`data/domain/presentation` per feature), Riverpod, GoRouter, Firebase (behind repository interfaces), `in_app_purchase` (Google Play Billing) with server verification, LiveKit behind `CallService`.

Recognition pipeline (**on-device, no camera frames leave the phone**):

```
CameraImage → HandLandmarkExtractor (MediaPipe Hands, 21×3) → 30-frame window
  → SignRecognitionEngine (ONNX Runtime, existing model) → TemporalSmoother
  → GlossProcessor → SentenceBuilder → TranslationEngine → TTS / History
```
`SignRecognitionEngine` implementations: `LocalOnnxRecognitionEngine` (real), `RemoteRecognitionEngine` (server, future), `UnavailableRecognitionEngine` (explicit "model unavailable" state). **No fake predictions in production code.** A test-only fake lives under `test/`.

## 3. External configuration required (cannot be faked)
Firebase project + `google-services.json`; Google Play app + subscription products (`signovoice_premium_monthly/yearly` with a 1-month free-trial offer); backend URL for purchase verification (Google Play Developer API) and AI translation; LiveKit server + token endpoint; sign video/illustration assets beyond the 5 existing clips; release keystore.

## 4. Phases → status
| # | Phase | Status |
|---|---|---|
| 1 | Inspect legacy project | done (this document) |
| 2–3 | Architecture + design system | done |
| 4–5 | Auth, home/navigation | done (guest ✔; Firebase auth needs project config) |
| 6–7 | Sign → Text / Sign → Voice | done (real ONNX + MediaPipe path; needs on-device validation) |
| 8 | Voice → Sign | done |
| 9 | Live interpreter | done (needs backend + LiveKit) |
| 10–13 | Learn, Practice, Dictionary, History | done |
| 14 | Subscription + 1-month trial + verified entitlement | done (needs Play products + backend) |
| 15–16 | Profile/Settings, security/privacy | done |
| 17–18 | Tests, performance | 138 tests; profiling on device outstanding |
| 19 | Android release configuration | written, **not built here** (no Android SDK in the sandbox) |
| 20 | Final QA | see QA_CHECKLIST.md |
