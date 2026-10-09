#!/usr/bin/env python3
"""Shows what makes an APK/AAB big: totals plus the largest files grouped by what they are.

  python tools/size/apk_report.py build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
  python tools/size/apk_report.py build/app/outputs/bundle/release/app-release.aab

Sizes are *compressed* (what is downloaded) and uncompressed (what is installed). Works on Windows too.
"""
import sys
import zipfile
from collections import defaultdict


def group(name: str) -> str:
    n = name.lower()
    if n.endswith('.so'):
        for key, label in (('mediapipe', 'MediaPipe (hand tracking)'), ('onnxruntime', 'ONNX Runtime'), ('tensorflowlite', 'TensorFlow Lite / LiteRT'),
                           ('litert', 'TensorFlow Lite / LiteRT'), ('jingle', 'WebRTC (live calls)'), ('webrtc', 'WebRTC (live calls)'),
                           ('flutter', 'Flutter engine'), ('app.so', 'Your Dart code (libapp.so)'), ('mlkit', 'ML Kit')):
            if key in n:
                return label
        return 'Other native libraries'
    if n.endswith('.dex'):
        return 'Java/Kotlin code (classes.dex)'
    if '/assets/' in '/' + n or n.startswith('assets/') or 'flutter_assets' in n:
        return 'Flutter assets (models, videos, fonts, data)'
    if n.startswith('res/') or n.endswith('.arsc'):
        return 'Android resources'
    return 'Other'


def mb(b: int) -> str:
    return f'{b / 1048576:7.2f} MB'


def main(path: str):
    z = zipfile.ZipFile(path)
    infos = z.infolist()
    total_c = sum(i.compress_size for i in infos)
    total_u = sum(i.file_size for i in infos)
    print(f'{path}\n  file size on disk: {mb(sum(i.compress_size for i in infos))} (compressed contents)   installed: {mb(total_u)}\n')
    groups = defaultdict(lambda: [0, 0])
    for i in infos:
        g = group(i.filename)
        groups[g][0] += i.compress_size
        groups[g][1] += i.file_size
    print('By category (download / installed):')
    for g, (c, u) in sorted(groups.items(), key=lambda kv: -kv[1][0]):
        print(f'  {mb(c)} / {mb(u)}  {g}')
    print('\nTop 20 files by download size:')
    for i in sorted(infos, key=lambda i: -i.compress_size)[:20]:
        print(f'  {mb(i.compress_size)}  {i.filename}')
    abis = sorted({i.filename.split('/')[1] for i in infos if i.filename.startswith('lib/') and i.filename.count('/') >= 2})
    if abis:
        print('\nCPU architectures inside: ' + ', '.join(abis) + '  (a phone only needs ONE; build with --split-per-abi or an .aab)')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
