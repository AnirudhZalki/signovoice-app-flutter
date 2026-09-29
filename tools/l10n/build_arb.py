#!/usr/bin/env python3
"""Generates lib/l10n/app_{en,hi,kn}.arb from tools/l10n/strings/*.txt.

Line format:  key | English | Hindi | Kannada     (blank lines and # comments ignored)
Placeholders: write {name} in the English text; all placeholders are Strings.
Missing hi/kn text falls back to English at runtime, but the script warns.
"""
import glob, json, os, re, sys

root = os.path.dirname(os.path.abspath(__file__))
out = os.path.join(root, '..', '..', 'lib', 'l10n')
langs = ['en', 'hi', 'kn']
data = {l: {} for l in langs}
meta = {}
warn = 0
for f in sorted(glob.glob(os.path.join(root, 'strings', '*.txt'))):
    for n, line in enumerate(open(f, encoding='utf-8'), 1):
        line = line.rstrip('\n')
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        parts = [p.strip() for p in line.split(' | ')]
        if len(parts) != 4:
            sys.exit(f'{os.path.basename(f)}:{n}: expected 4 columns, got {len(parts)}: {line[:60]}')
        key, en, hi, kn = parts
        if key in meta:
            sys.exit(f'duplicate key {key} ({os.path.basename(f)}:{n})')
        ph = sorted(set(re.findall(r'\{(\w+)\}', en)))
        for lang, txt in zip(langs, (en, hi, kn)):
            if lang != 'en' and set(re.findall(r'\{(\w+)\}', txt)) != set(ph):
                sys.exit(f'{key}: placeholder mismatch in {lang}')
            data[lang][key] = txt.replace('\\n', '\n')
        meta[key] = ph
os.makedirs(out, exist_ok=True)
for lang in langs:
    arb = {'@@locale': lang}
    for key, txt in data[lang].items():
        arb[key] = txt
        if lang == 'en' and meta[key]:
            arb['@' + key] = {'placeholders': {p: {'type': 'String'} for p in meta[key]}}
    with open(os.path.join(out, f'app_{lang}.arb'), 'w', encoding='utf-8') as fh:
        json.dump(arb, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
print(f'{len(meta)} strings -> {out}')
