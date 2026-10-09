#!/usr/bin/env python3
"""Trims the bundled Inter fonts to the Latin characters the app can show (Hindi/Kannada come from system fonts anyway).

  pip install fonttools
  python tools/size/subset_fonts.py            # rewrites assets/fonts/Inter_*.ttf in place (keep the originals in git history)
Fails if any character used in the app's code/strings would be lost. Re-run after adding new Latin symbols.
"""
import glob
import os
import sys

from fontTools import subset
from fontTools.ttLib import TTFont

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
KEEP = [(0x20, 0x7E), (0xA0, 0x24F), (0x2000, 0x206F), (0x20A0, 0x20CF), (0x2190, 0x21FF), (0x2212, 0x2212)]

text = ''
for pattern in ('lib/**/*.dart', 'lib/l10n/*.arb', 'tools/l10n/strings/*.txt'):
    for f in glob.glob(os.path.join(ROOT, pattern), recursive=True):
        text += open(f, encoding='utf-8', errors='ignore').read()
used = {c for c in text if ord(c) >= 0x20}

for path in sorted(glob.glob(os.path.join(ROOT, 'assets', 'fonts', 'Inter_*.ttf'))):
    cmap = TTFont(path).getBestCmap()
    unicodes = sorted({ord(c) for c in used if ord(c) in cmap} | {u for u in cmap if any(a <= u <= b for a, b in KEEP)})
    opts = subset.Options()
    opts.layout_features = ['*']
    opts.notdef_outline = True
    opts.name_IDs = ['*']
    opts.hinting = False
    font = subset.load_font(path, opts)
    s = subset.Subsetter(opts)
    s.populate(unicodes=unicodes)
    s.subset(font)
    before = os.path.getsize(path)
    tmp = path + '.tmp'
    subset.save_font(font, tmp, opts)
    new = TTFont(tmp).getBestCmap()
    lost = [c for c in used if ord(c) in cmap and ord(c) not in new]
    if lost:
        os.remove(tmp)
        sys.exit(f'{path}: would lose used characters {lost}')
    os.replace(tmp, path)
    print(f'{os.path.basename(path)}: {before // 1024} KB -> {os.path.getsize(path) // 1024} KB')
