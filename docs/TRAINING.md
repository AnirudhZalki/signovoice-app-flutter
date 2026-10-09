# Training the sign model on the INCLUDE dataset

Dataset: **INCLUDE** (Indian Sign Language, 263 words, ~4,300 videos) — https://zenodo.org/records/4010759
(zips such as `Adjectives_1of8.zip`; pick the categories you need, a few GB each). Run these on **your own machine or Google Colab**
(GPU optional); the sandbox this repo was developed in cannot reach Zenodo.

```
cd tools/train
python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
# 1. download + unzip the INCLUDE zips into one folder, e.g. ~/include  (layout: <Category>/<N. word>/<video>.MOV)
python extract_landmarks.py --videos ~/include --out ~/include_landmarks --fps 20
python train.py --data ~/include_landmarks --out ../../assets/models --epochs 60
```
`train.py` writes `signovoice_model.tflite`, `signovoice_model_labels.txt` and `signovoice_model.json` straight into
`assets/models/`, replacing the current files. Rebuild the app; Settings › Translation shows which model is active. It refuses to export
if the TFLite model scores below `--min-val-acc` (default 0.6) on held-out clips.

## Why this fixes "guessing in the opposite direction"
- **Same features as the phone.** `tools/train/features.py` mirrors `HandFrame.fromHands` (hand slot order, single-hand placement,
  raw image coordinates with y pointing *down*), so a hand moving top → bottom is learned as increasing y, exactly as the app sends it.
- **Direction-safe augmentation.** Scale, small rotation, shift, noise and dropped frames only. No vertical flip, no time reversal and
  no left/right flip, so up-vs-down and left-handed signs stay distinct.
- **Order-aware model.** Learned positional embeddings keep frame order, which is what separates "down" from "up".
- **Mirroring pinned.** The manifest carries `"mirrorX": false` (INCLUDE videos are unmirrored), so the app's "Mirror hand input"
  switch no longer flips this model's input. Older models without the field still follow the switch.

## Caveats (be realistic)
- INCLUDE has ~16 clips per word from a handful of signers; expect good accuracy on those signers, lower on new people and lighting.
  Add your own recordings (same folder layout) to improve it.
- Frame rate: training samples ~20 fps clips and resamples windows to 30 frames; the app fills 30 consecutive camera frames. If live
  results look too fast/slow, change `--fps` to match the camera rate and retrain.
- Validate on a phone before shipping; the training script cannot test the Android camera path.

## Phone held upright (portrait) vs landscape
The models are trained on landscape webcam video. Since the camera frame of an upright phone is tall, the app now (1) rotates each frame by the *current* phone orientation (`cameraRotationDegrees`) instead of assuming portrait, and (2) re-expresses the hand landmarks on the landscape canvas of the same sensor in real pixel proportions (`toLandscapeCanvas`), so a sign looks the same to the model in either orientation. When you record your own training clips, record landscape (or accept the same conversion in `tools/train/features.py`: apply the same mapping to portrait clips before building features).
