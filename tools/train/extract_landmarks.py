#!/usr/bin/env python3
"""Extract MediaPipe hand landmarks from sign videos (INCLUDE dataset, zenodo.org/records/4010759).

Folder layout expected (what the INCLUDE zips unpack to):  <root>/<Category>/<N. word>/<video>.mp4|MOV
Output: <out>/<word>/<video>.npy  with shape [T, hands*63] sampled at --fps frames per second.

  python extract_landmarks.py --videos ~/include --out ~/include_landmarks --fps 20
"""
import argparse
import re
from pathlib import Path

import cv2
import numpy as np

from features import build_frame

VIDEO_EXT = {".mp4", ".mov", ".avi", ".mkv", ".webm"}


def clean_label(name: str) -> str:
    return re.sub(r"^\s*\d+[.)]?\s*", "", name).strip().lower()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--videos", required=True, type=Path)
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--fps", type=float, default=20.0)
    ap.add_argument("--hands", type=int, default=2)
    ap.add_argument("--order", default="imageXAscending")
    ap.add_argument("--preprocess", default="raw", choices=["raw", "wristRelative", "normalized"])
    ap.add_argument("--mirror-x", action="store_true", help="flip x like the app's 'Mirror hand input' setting")
    ap.add_argument("--max-per-class", type=int, default=0)
    a = ap.parse_args()

    import mediapipe as mp
    hands_mod = mp.solutions.hands

    files = sorted(p for p in a.videos.rglob("*") if p.suffix.lower() in VIDEO_EXT)
    counts = {}
    print(f"{len(files)} videos found")
    with hands_mod.Hands(static_image_mode=False, max_num_hands=a.hands,
                         min_detection_confidence=0.5, min_tracking_confidence=0.5) as det:
        for i, f in enumerate(files):
            label = clean_label(f.parent.name)
            if a.max_per_class and counts.get(label, 0) >= a.max_per_class:
                continue
            dst = a.out / label / (f.stem + ".npy")
            if dst.exists():
                counts[label] = counts.get(label, 0) + 1
                continue
            cap = cv2.VideoCapture(str(f))
            src_fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
            step = max(1, round(src_fps / a.fps))
            rows, n = [], 0
            while True:
                ok, bgr = cap.read()
                if not ok:
                    break
                if n % step == 0:
                    res = det.process(cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB))
                    hs = [[(l.x, l.y, l.z) for l in h.landmark] for h in (res.multi_hand_landmarks or [])]
                    rows.append(build_frame(hs, a.hands, a.order, a.mirror_x, a.preprocess))
                n += 1
            cap.release()
            if not rows or not any(np.abs(r).sum() > 0 for r in rows):
                print(f"  skip (no hands): {f}")
                continue
            dst.parent.mkdir(parents=True, exist_ok=True)
            np.save(dst, np.stack(rows).astype(np.float32))
            counts[label] = counts.get(label, 0) + 1
            if i % 50 == 0:
                print(f"  {i}/{len(files)} {label}")
    print(f"done: {len(counts)} classes, {sum(counts.values())} clips")


if __name__ == "__main__":
    main()
