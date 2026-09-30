# Using `signovoice_model.tflite`

The app ships `assets/models/signovoice_model.tflite` (input `[1,30,126]`, output `[1,419]` softmax) and its manifest `assets/models/signovoice_model.json`. It is **not active yet**: the model file does not contain the 419 class names, and the app refuses to guess. Until the labels are added it falls back to the older 9-sign ONNX model (which is why it kept answering "Thank you").

## What is needed
1. **`assets/models/signovoice_model_labels.txt`** — exactly 419 lines, one word per line, in the model's **output index order** (index 0 first). This is the file the training script wrote/used (e.g. from `LabelEncoder.classes_` or the sorted dataset folders). A wrong order gives confidently wrong words, so the app checks the count matches `classes` and otherwise stays on ONNX.
2. **Input preprocessing** — confirm how the training data was built, then edit `signovoice_model.json`:
   - `hands`: `2` (126 = 2 hands × 21 landmarks × xyz).
   - `preprocess`: `raw` (MediaPipe normalised image coords), `wristRelative` (each hand minus its wrist) or `normalized` (wrist-relative, scaled to the hand's size).
   - `handOrder`: `imageXAscending` (left-in-image first), `imageXDescending`, or `detected`.
   - `sequenceLength`: 30 frames (matches the model).
3. In the app, *Settings → Translation → Mirror hand input* flips x for front-camera mirroring if signs look reversed.

## Quick check
Run the app on a device, open Sign → Text and perform a few signs. If output is stuck on one word, the preprocessing/handOrder differs from training — try `wristRelative`/`normalized` first. `test/features/sign_translation/model_selection_test.dart` verifies the manifest/labels consistency.
