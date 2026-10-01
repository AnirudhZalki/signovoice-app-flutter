"""Landmark -> model-feature conversion. MUST stay identical to lib/features/sign_translation/domain/hand_frame.dart
(`HandFrame.fromHands`) so what the model sees in training is what it sees on the phone."""
import numpy as np

SEQ = 30
PER_HAND = 63  # 21 landmarks * (x, y, z)


def build_frame(hands, n_hands=2, order="imageXAscending", mirror_x=False, preprocess="raw"):
    """hands: list of (21,3) arrays in normalised image coords (x right, y DOWN, as MediaPipe reports).
    Returns a float32 vector of n_hands*63 (zeros for missing hands)."""
    valid = [np.asarray(h, dtype=np.float32).copy() for h in hands if len(h) == 21]
    out = np.zeros(n_hands * PER_HAND, dtype=np.float32)
    if not valid:
        return out
    if mirror_x:
        for h in valid:
            h[:, 0] = 1.0 - h[:, 0]
    valid = valid[:n_hands]
    if order == "imageXAscending":
        valid.sort(key=lambda h: h[0, 0])
    elif order == "imageXDescending":
        valid.sort(key=lambda h: -h[0, 0])
    start = 0
    if n_hands == 2 and len(valid) == 1 and order != "detected":
        left_side = valid[0][0, 0] < 0.5
        first_slot = left_side if order == "imageXAscending" else not left_side
        start = 0 if first_slot else 1
    for i, h in enumerate(valid):
        p = _preprocess(h, preprocess)
        s = (start + i) * PER_HAND
        out[s:s + PER_HAND] = p.reshape(-1)
    return out


def _preprocess(p, mode):
    if mode == "raw":
        return p
    rel = p - p[0]
    if mode == "wristRelative":
        return rel
    m = np.abs(rel).max()
    return rel if m < 1e-6 else rel / m


def resample(seq, length=SEQ):
    """Linear time-resample [T,F] -> [length,F]. Frames with no hand (all zeros) borrow the nearest real frame's
    neighbours only through interpolation; if the clip has no hand at all the result is zeros."""
    seq = np.asarray(seq, dtype=np.float32)
    t = len(seq)
    if t == 0:
        return np.zeros((length, 0), dtype=np.float32)
    if t == 1:
        return np.repeat(seq, length, axis=0)
    src = np.linspace(0, t - 1, length)
    lo = np.floor(src).astype(int)
    hi = np.minimum(lo + 1, t - 1)
    w = (src - lo)[:, None]
    out = seq[lo] * (1 - w) + seq[hi] * w
    # Do not blend a real hand with an empty frame (would create a half-size ghost hand): snap to the nearer one.
    present = np.abs(seq).sum(axis=1) > 0
    mixed = present[lo] != present[hi]
    if mixed.any():
        nearer = np.where(w[:, 0] < 0.5, lo, hi)
        out[mixed] = seq[nearer[mixed]]
    return out.astype(np.float32)


def augment(seq, rng):
    """Spatial/temporal augmentation that keeps motion DIRECTION intact (no vertical/time flips;
    no horizontal flip, which would swap left/right-handed signs)."""
    x = seq.copy()
    f = x.shape[1]
    hands = f // PER_HAND
    pts = x.reshape(len(x), hands * 21, 3)
    present = np.abs(pts).sum(axis=2) > 0
    scale = rng.uniform(0.85, 1.15)
    ang = np.deg2rad(rng.uniform(-12, 12))
    shift = rng.uniform(-0.08, 0.08, size=2)
    c, s = np.cos(ang), np.sin(ang)
    xy = pts[..., :2] - 0.5
    rot = np.stack([xy[..., 0] * c - xy[..., 1] * s, xy[..., 0] * s + xy[..., 1] * c], axis=-1)
    pts[..., :2] = rot * scale + 0.5 + shift
    pts[..., 2] *= scale
    pts += rng.normal(0, 0.004, pts.shape).astype(np.float32)
    pts[~present] = 0.0
    # occasional dropped frames, like a missed detection on the phone
    drop = rng.random(len(pts)) < 0.04
    pts[drop] = 0.0
    return pts.reshape(len(x), f).astype(np.float32)
