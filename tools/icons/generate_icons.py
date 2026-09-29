#!/usr/bin/env python3
"""Draws the SignoVoice mark (speech bubble + signing hand + connection dots) as PNGs.

Geometry mirrors android/app/src/main/res/drawable/ic_launcher_foreground.xml (108 viewport).
Outputs legacy launcher icons for Android < 8 (square + round) and the 512px Google Play icon.
Requires Pillow:  pip install pillow
"""
import os
from PIL import Image, ImageDraw

INDIGO = (0x31, 0x57, 0xD5, 255)
WHITE = (255, 255, 255, 255)
CYAN = (0x22, 0xC7, 0xE8, 255)
TEAL = (0x12, 0xA5, 0x94, 255)
SS = 4  # supersampling

def glyph(size, scale=0.85):
    """Foreground glyph on a transparent RGBA canvas of `size` px (supersampled)."""
    S = size * SS
    img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    k = S / 108.0

    def P(x, y):  # viewport -> pixels, with group scale around (54,54)
        return ((54 + (x - 54) * scale) * k, (54 + (y - 54) * scale) * k)

    def R(x0, y0, x1, y1, r, fill):
        a, b = P(x0, y0), P(x1, y1)
        d.rounded_rectangle([a, b], radius=r * scale * k, fill=fill)

    # bubble body + tail
    R(30, 28, 78, 70, 10, WHITE)
    d.polygon([P(38, 66), P(52, 70), P(38, 82)], fill=WHITE)
    # palm
    R(44.5, 46, 63.5, 61, 5, INDIGO)
    # fingers + thumb as round-capped strokes
    w = 4 * scale * k
    def stroke(p0, p1):
        a, b = P(*p0), P(*p1)
        d.line([a, b], fill=INDIGO, width=int(w))
        for c in (a, b):
            d.ellipse([c[0] - w / 2, c[1] - w / 2, c[0] + w / 2, c[1] + w / 2], fill=INDIGO)
    stroke((46.5, 47), (46.5, 39)); stroke((51.5, 47), (51.5, 36))
    stroke((56.5, 47), (56.5, 37)); stroke((61.5, 47), (61.5, 41)); stroke((44.5, 54), (40, 49))
    # connection motif
    d.line([P(82, 30), P(88, 42)], fill=CYAN, width=int(1.6 * scale * k))
    for (cx, cy, r, col) in ((82, 30, 4.5, CYAN), (88, 42, 2.8, TEAL)):
        c = P(cx, cy); rr = r * scale * k
        d.ellipse([c[0] - rr, c[1] - rr, c[0] + rr, c[1] + rr], fill=col)
    return img.resize((size, size), Image.LANCZOS)

def icon(size, round_=False):
    S = size * SS
    bg = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(bg)
    if round_:
        d.ellipse([0, 0, S - 1, S - 1], fill=INDIGO)
    else:
        d.rounded_rectangle([0, 0, S - 1, S - 1], radius=S * 0.22, fill=INDIGO)
    out = bg.resize((size, size), Image.LANCZOS)
    out.alpha_composite(glyph(size, scale=1.0 if not round_ else 0.9))
    return out

root = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
res = os.path.join(root, 'android', 'app', 'src', 'main', 'res')
for name, px in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
    folder = os.path.join(res, f'mipmap-{name}')
    os.makedirs(folder, exist_ok=True)
    icon(px).save(os.path.join(folder, 'ic_launcher.png'))
    icon(px, round_=True).save(os.path.join(folder, 'ic_launcher_round.png'))
icon(512).save(os.path.join(root, 'assets', 'store', 'play_icon_512.png'))
print('icons written')
