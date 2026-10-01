#!/usr/bin/env python3
"""Train the sign classifier from extracted landmarks and export the app's TFLite model.

  python train.py --data ~/include_landmarks --out ../../assets/models --epochs 60

Writes into --out:  signovoice_model.tflite, signovoice_model_labels.txt, signovoice_model.json
(the exact trio the app's ModelRepository looks for; labels are in the model's output order).
"""
import argparse
import json
from pathlib import Path

import numpy as np

from features import SEQ, PER_HAND, augment, resample


def load(data: Path, min_clips: int):
    by = {}
    for d in sorted(p for p in data.iterdir() if p.is_dir()):
        clips = [np.load(f) for f in sorted(d.glob("*.npy"))]
        if len(clips) >= min_clips:
            by[d.name] = clips
    labels = sorted(by)
    return labels, by


def random_window(clip, rng):
    t = len(clip)
    if t <= 8:
        return resample(clip)
    length = int(rng.uniform(0.7, 1.0) * t)
    start = int(rng.integers(0, t - length + 1))
    return resample(clip[start:start + length])


def build_model(classes, features, batch=None):
    import tensorflow as tf
    from tensorflow.keras import layers as L

    inp = L.Input(shape=(SEQ, features), batch_size=batch, name="landmarks")
    x = L.Dense(128)(inp)
    pos = tf.range(SEQ)
    x = x + L.Embedding(SEQ, 128)(pos)  # learned positions: keeps frame ORDER, hence motion direction
    for _ in range(2):
        h = L.LayerNormalization()(x)
        h = L.MultiHeadAttention(num_heads=4, key_dim=32)(h, h)
        x = x + L.Dropout(0.1)(h)
        h = L.LayerNormalization()(x)
        h = L.Dense(256, activation="gelu")(h)
        h = L.Dense(128)(h)
        x = x + L.Dropout(0.1)(h)
    x = L.LayerNormalization()(x)
    x = L.Concatenate()([L.GlobalAveragePooling1D()(x), L.GlobalMaxPooling1D()(x)])
    x = L.Dropout(0.3)(x)
    out = L.Dense(classes, activation="softmax", name="probs")(x)
    return tf.keras.Model(inp, out, name="SignLanguageTransformer")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True, type=Path)
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--epochs", type=int, default=60)
    ap.add_argument("--batch", type=int, default=64)
    ap.add_argument("--min-clips", type=int, default=4)
    ap.add_argument("--preprocess", default="raw", choices=["raw", "wristRelative", "normalized"])
    ap.add_argument("--hands", type=int, default=2)
    ap.add_argument("--order", default="imageXAscending")
    ap.add_argument("--min-val-acc", type=float, default=0.6, help="refuse to export a model worse than this")
    a = ap.parse_args()

    import tensorflow as tf
    rng = np.random.default_rng(7)
    labels, by = load(a.data, a.min_clips)
    n = len(labels)
    feats = a.hands * PER_HAND
    print(f"{n} classes, {sum(len(v) for v in by.values())} clips")

    train, val = [], []
    for ci, name in enumerate(labels):
        idx = rng.permutation(len(by[name]))
        k = max(1, int(round(0.2 * len(idx))))
        for j, i in enumerate(idx):
            (val if j < k else train).append((by[name][i], ci))

    Xv = np.stack([resample(c) for c, _ in val])
    yv = np.array([y for _, y in val])

    def batches():
        while True:
            order = rng.permutation(len(train))
            for s in range(0, len(order) - a.batch + 1, a.batch):
                b = [train[i] for i in order[s:s + a.batch]]
                yield (np.stack([augment(random_window(c, rng), rng) for c, _ in b]),
                       np.array([y for _, y in b]))

    model = build_model(n, feats)
    steps = max(1, len(train) // a.batch)
    sched = tf.keras.optimizers.schedules.CosineDecay(1e-3, a.epochs * steps)
    model.compile(tf.keras.optimizers.AdamW(sched, weight_decay=1e-4),
                  "sparse_categorical_crossentropy",
                  ["accuracy", tf.keras.metrics.SparseTopKCategoricalAccuracy(5, name="top5")])
    gen = tf.data.Dataset.from_generator(
        batches, output_signature=(tf.TensorSpec((None, SEQ, feats), tf.float32), tf.TensorSpec((None,), tf.int32)))
    model.fit(gen, steps_per_epoch=steps, epochs=a.epochs, validation_data=(Xv, yv), verbose=2)
    _, acc, top5 = model.evaluate(Xv, yv, verbose=0)
    print(f"val top-1 {acc:.3f}  top-5 {top5:.3f}")

    # Fixed batch 1, as the app's TFLite engine expects [1, 30, features].
    export = build_model(n, feats, batch=1)
    export.set_weights(model.get_weights())
    conv = tf.lite.TFLiteConverter.from_keras_model(export)
    conv.optimizations = [tf.lite.Optimize.DEFAULT]
    conv.target_spec.supported_types = [tf.float16]
    blob = conv.convert()

    it = tf.lite.Interpreter(model_content=blob)
    it.allocate_tensors()
    i_d, o_d = it.get_input_details()[0], it.get_output_details()[0]
    assert list(i_d["shape"]) == [1, SEQ, feats] and list(o_d["shape"]) == [1, n], (i_d["shape"], o_d["shape"])
    ok = 0
    for x, y in zip(Xv, yv):
        it.set_tensor(i_d["index"], x[None].astype(np.float32))
        it.invoke()
        ok += int(np.argmax(it.get_tensor(o_d["index"])[0]) == y)
    tfl_acc = ok / len(Xv)
    print(f"TFLite val top-1 {tfl_acc:.3f}")
    if tfl_acc < a.min_val_acc:
        raise SystemExit(f"TFLite accuracy {tfl_acc:.3f} < {a.min_val_acc}: not exporting. Add data/epochs.")

    a.out.mkdir(parents=True, exist_ok=True)
    (a.out / "signovoice_model.tflite").write_bytes(blob)
    (a.out / "signovoice_model_labels.txt").write_text("\n".join(labels) + "\n", encoding="utf-8")
    (a.out / "signovoice_model.json").write_text(json.dumps({
        "id": f"signovoice_transformer_{n}", "version": 3, "engine": "tflite",
        "model": "signovoice_model.tflite", "classes": n,
        "labelsFile": "signovoice_model_labels.txt", "sequenceLength": SEQ,
        "featureCount": feats, "hands": a.hands, "preprocess": a.preprocess, "handOrder": a.order, "mirrorX": False,
    }, indent=2) + "\n")
    print(f"exported {n} classes -> {a.out}")


if __name__ == "__main__":
    main()
