import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/features/profile/domain/user_preferences.dart';
import 'package:signovoice/features/sign_translation/data/model_repository.dart';
import 'package:signovoice/features/sign_translation/domain/hand_frame.dart';
import 'package:signovoice/features/sign_translation/domain/model_manifest.dart';
import 'package:signovoice/features/sign_translation/domain/sign_prediction.dart';
import 'package:signovoice/features/sign_translation/domain/temporal_smoother.dart';

/// In-memory asset bundle so selection logic is tested without Flutter's asset cache.
class _Bundle extends CachingAssetBundle {
  _Bundle(this.files);
  final Map<String, String> files;
  @override
  Future<ByteData> load(String key) async {
    final s = files[key.replaceFirst('assets/models/', '')];
    if (s == null) throw FlutterError('missing $key');
    final b = Uint8List.fromList(utf8.encode(s));
    return ByteData.view(b.buffer);
  }
}

const _tfliteJson = '{"id":"t","engine":"tflite","model":"m.tflite","classes":4,"labelsFile":"l.txt","sequenceLength":30,"featureCount":126,"hands":2,"preprocess":"wristRelative","handOrder":"imageXAscending"}';
const _legacyJson = '{"version":1,"model":"old.onnx","inputName":"lstm_input","labels":["A","B"]}';

LandmarkPoint p(double x, double y, [double z = 0]) => (x: x, y: y, z: z);
List<LandmarkPoint> hand(double x0, {double y0 = 0.5}) => [for (var i = 0; i < 21; i++) p(x0 + i * 0.001, y0 + i * 0.002, 0.01 * i)];

void main() {
  _mirrorLockTests();
  group('model selection', () {
    ModelRepository repo(Map<String, String> files) => ModelRepository(tokenProvider: () async => null, bundle: _Bundle(files));

    test('uses the TFLite model when its labels file matches the class count', () async {
      final s = await repo({'signovoice_model.json': _tfliteJson, 'l.txt': 'a\nb\n\nc\nd\n', 'labels.json': _legacyJson}).select();
      expect(s.manifest.engine, ModelEngineKind.tflite);
      expect(s.manifest.labels, ['a', 'b', 'c', 'd']);
      expect(s.manifest.hands, 2);
      expect(s.manifest.featureCount, 126);
      expect(s.manifest.spec.preprocess, FeaturePreprocess.wristRelative);
      expect(s.note, isNull);
    });

    test('falls back to ONNX (with a reason) when the labels file is missing', () async {
      final s = await repo({'signovoice_model.json': _tfliteJson, 'labels.json': _legacyJson}).select();
      expect(s.manifest.engine, ModelEngineKind.onnx);
      expect(s.note, contains('missing'));
    });

    test('never runs a model with the wrong number of labels', () async {
      final s = await repo({'signovoice_model.json': _tfliteJson, 'l.txt': 'a\nb\nc', 'labels.json': _legacyJson}).select();
      expect(s.manifest.engine, ModelEngineKind.onnx);
      expect(s.note, contains('3 entries'));
    });

    test('shipped manifest describes the bundled TFLite model (419 classes, 30×126, 2 hands)', () {
      final j = jsonDecode(File('assets/models/signovoice_model.json').readAsStringSync()) as Map<String, dynamic>;
      expect(j['classes'], 419);
      expect(j['sequenceLength'], 30);
      expect(j['featureCount'], 126);
      expect(j['hands'], 2);
      expect(File('assets/models/${j['model']}').existsSync(), isTrue);
    });
  });

  group('two-hand features', () {
    const two = HandFeatureSpec(hands: 2, mirrorX: false);

    test('feature count follows the hands', () {
      expect(two.featureCount, 126);
      expect(HandFrame.emptyFor(126).features.length, 126);
      expect(HandFrame.emptyFor(63), same(HandFrame.empty));
    });

    test('hands are ordered by image x', () {
      final f = HandFrame.fromHands([hand(0.7), hand(0.2)], two);
      expect(f.features[0], closeTo(0.2, 1e-9)); // first slot = left-most hand
      expect(f.features[63], closeTo(0.7, 1e-9));
    });

    test('a single hand goes in the slot for the side it appears on', () {
      final left = HandFrame.fromHands([hand(0.2)], two);
      expect(left.features[0], closeTo(0.2, 1e-9));
      expect(left.features[63], 0);
      final right = HandFrame.fromHands([hand(0.8)], two);
      expect(right.features[0], 0);
      expect(right.features[63], closeTo(0.8, 1e-9));
    });

    test('mirroring flips x before ordering', () {
      final f = HandFrame.fromHands([hand(0.2)], const HandFeatureSpec(hands: 2));
      expect(f.features[63], closeTo(0.8, 1e-9)); // 1-0.2 moved it to the right slot
    });

    test('wrist-relative puts the wrist at the origin; normalised is scale free', () {
      final rel = HandFrame.fromHands([hand(0.4)], const HandFeatureSpec(preprocess: FeaturePreprocess.wristRelative, mirrorX: false));
      expect(rel.features.sublist(0, 3), [0, 0, 0]);
      final big = [for (final q in hand(0.4)) p(q.x * 2, q.y * 2, q.z * 2)];
      final n1 = HandFrame.fromHands([hand(0.4)], const HandFeatureSpec(preprocess: FeaturePreprocess.normalized, mirrorX: false));
      final n2 = HandFrame.fromHands([big], const HandFeatureSpec(preprocess: FeaturePreprocess.normalized, mirrorX: false));
      for (var i = 0; i < 63; i++) {
        expect(n1.features[i], closeTo(n2.features[i], 1e-9));
      }
      expect(n1.features.map((v) => v.abs()).reduce((a, b) => a > b ? a : b), closeTo(1, 1e-9));
    });

    test('no valid hands -> empty frame; extra hands are ignored', () {
      expect(HandFrame.fromHands(const [], two).hasHand, isFalse);
      expect(HandFrame.fromHands([hand(0.1), hand(0.5), hand(0.9)], two).features.length, 126);
    });
  });

  group('margin filtering (many classes)', () {
    final t0 = DateTime(2026);
    SignPrediction flat(String l) => SignPrediction(label: l, confidence: 0.75, probabilities: {l: 0.75, 'other': 0.70});
    SignPrediction clear(String l) => SignPrediction(label: l, confidence: 0.75, probabilities: {l: 0.75, 'other': 0.10});

    test('a confident but ambiguous prediction is not accepted', () {
      final s = TemporalSmoother();
      for (var i = 0; i < 4; i++) {
        expect(s.add(flat('Hello'), threshold: 0.7, now: t0, minMargin: 0.1), isNull);
      }
    });
    test('a clear lead is accepted', () {
      final s = TemporalSmoother();
      s.add(clear('Hello'), threshold: 0.7, now: t0, minMargin: 0.1);
      expect(s.add(clear('Hello'), threshold: 0.7, now: t0, minMargin: 0.1), 'Hello');
    });
    test('margin is 1 when probabilities are unknown', () => expect(const SignPrediction(label: 'x', confidence: .9).margin, 1));
  });

  test('RecognitionMode enum unchanged', () => expect(RecognitionMode.values.length, 2));
}

void _mirrorLockTests() {
  test('manifest mirrorX pins the mirroring; the user setting only applies when unset', () {
    final base = {'model': 'm.tflite', 'engine': 'tflite', 'hands': 2};
    final free = ModelManifest.fromJson(base, labels: const ['a']).spec;
    expect(free.copyWith(mirrorX: false).mirrorX, isFalse);
    final locked = ModelManifest.fromJson({...base, 'mirrorX': false}, labels: const ['a']).spec;
    expect(locked.copyWith(mirrorX: true).mirrorX, isFalse);
  });
}
