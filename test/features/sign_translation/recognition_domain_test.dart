import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/errors/failure.dart';
import 'package:signovoice/features/sign_translation/domain/gloss_processor.dart';
import 'package:signovoice/features/sign_translation/domain/hand_frame.dart';
import 'package:signovoice/features/sign_translation/domain/model_manifest.dart';
import 'package:signovoice/features/sign_translation/domain/recognition_engine.dart';
import 'package:signovoice/features/sign_translation/domain/recognition_session.dart';
import 'package:signovoice/features/sign_translation/domain/sequence_buffer.dart';
import 'package:signovoice/features/sign_translation/domain/sign_prediction.dart';
import 'package:signovoice/features/sign_translation/domain/temporal_smoother.dart';
import 'package:signovoice/features/sign_translation/domain/translation_engine.dart';

const labels = ['A', 'B', 'C', 'Hello', 'I love you', 'No', 'Please', 'Thanks', 'Yes'];

/// Test-only engine (never used in production code).
class ScriptedEngine implements SignRecognitionEngine {
  ScriptedEngine(this.script);
  final List<SignPrediction?> script;
  int calls = 0;
  @override
  String get name => 'scripted';
  @override
  EngineStatus get status => EngineStatus.ready;
  @override
  bool get requiresInternet => false;
  @override
  List<String> get labels => const [];
  @override
  int get sequenceLength => 30;
  @override
  HandFeatureSpec get featureSpec => const HandFeatureSpec();
  @override
  Future<void> initialize() async {}
  @override
  Future<SignPrediction?> predict(List<List<double>> window) async => script[calls++ % script.length];
  @override
  Future<void> dispose() async {}
}

SignPrediction p(String l, double c) => SignPrediction(label: l, confidence: c);
HandFrame hand() => HandFrame(List.filled(63, 0.5), hasHand: true);

void main() {
  group('parseModelOutput', () {
    test('picks argmax from probabilities', () {
      final r = parseModelOutput([0, 0, 0, 0.9, 0.05, 0, 0.05, 0, 0], labels);
      expect(r.label, 'Hello');
      expect(r.confidence, closeTo(0.9, 1e-9));
      expect(r.probabilities.length, 9);
      expect(r.topK(2).first.key, 'Hello');
    });

    test('applies softmax to logits', () {
      final r = parseModelOutput([1, 2, 10, 0, 0, 0, 0, 0, 0], labels);
      expect(r.label, 'C');
      expect(r.probabilities.values.fold<double>(0, (a, b) => a + b), closeTo(1, 1e-9));
    });

    test('rejects length mismatch and NaN as model unavailable', () {
      expect(() => parseModelOutput([0.5, 0.5], labels), throwsA(isA<Failure>().having((f) => f.type, 'type', FailureType.modelUnavailable)));
      expect(() => parseModelOutput([double.nan, ...List.filled(8, 0.1)], labels), throwsA(isA<Failure>()));
    });
  });

  test('ModelManifest parses the bundled manifest shape', () {
    final m = ModelManifest.fromJson({
      'version': 1,
      'model': 'sign_language_model.onnx',
      'inputName': 'lstm_input',
      'sequenceLength': 30,
      'featureCount': 63,
      'labels': labels,
    });
    expect(m.assetPath, 'assets/models/sign_language_model.onnx');
    expect(m.labels.length, 9);
    expect(() => ModelManifest.fromJson({'labels': []}), throwsA(isA<Failure>()));
  });

  group('HandFrame', () {
    test('mirrors x and keeps y/z', () {
      final lms = List.generate(21, (i) => (x: 0.25, y: 0.5, z: -0.1));
      final f = HandFrame.fromLandmarks(lms);
      expect(f.hasHand, isTrue);
      expect(f.features.length, 63);
      expect(f.features[0], 0.75);
      expect(f.features[1], 0.5);
      expect(f.features[2], -0.1);
      expect(HandFrame.fromLandmarks(lms, mirrorX: false).features[0], 0.25);
    });
    test('wrong landmark count yields empty frame', () {
      expect(HandFrame.fromLandmarks([(x: 0, y: 0, z: 0)]).hasHand, isFalse);
    });
  });

  group('LandmarkSequenceBuffer', () {
    test('keeps only the last N frames and reports presence', () {
      final b = LandmarkSequenceBuffer(length: 4);
      for (var i = 0; i < 6; i++) {
        b.add(i.isEven ? hand() : HandFrame.empty);
      }
      expect(b.size, 4);
      expect(b.isFull, isTrue);
      expect(b.handPresence, 0.5);
      expect(b.trailingEmpty, 1);
      expect(b.toWindow().length, 4);
    });
  });

  group('TemporalSmoother', () {
    final t0 = DateTime(2026, 1, 1);
    test('needs agreement (2 of 3) above threshold', () {
      final s = TemporalSmoother();
      expect(s.add(p('Hello', 0.9), threshold: 0.7, now: t0), isNull);
      expect(s.add(p('Hello', 0.85), threshold: 0.7, now: t0), 'Hello');
    });
    test('ignores low-confidence predictions', () {
      final s = TemporalSmoother();
      for (var i = 0; i < 5; i++) {
        expect(s.add(p('Yes', 0.4), threshold: 0.7, now: t0), isNull);
      }
    });
    test('suppresses duplicates until the hand leaves', () {
      final s = TemporalSmoother();
      s.add(p('Yes', 0.9), threshold: 0.7, now: t0);
      expect(s.add(p('Yes', 0.9), threshold: 0.7, now: t0), 'Yes');
      // still signing the same sign -> no repeat
      expect(s.add(p('Yes', 0.9), threshold: 0.7, now: t0), isNull);
      expect(s.add(p('Yes', 0.9), threshold: 0.7, now: t0), isNull);
      // hand leaves long enough, then the same sign again is accepted
      s.noteNoHand(t0);
      s.noteNoHand(t0.add(const Duration(seconds: 1)));
      s.add(p('Yes', 0.9), threshold: 0.7, now: t0.add(const Duration(seconds: 2)));
      expect(s.add(p('Yes', 0.9), threshold: 0.7, now: t0.add(const Duration(seconds: 2))), 'Yes');
    });
    test('a different sign is accepted immediately after another', () {
      final s = TemporalSmoother();
      s.add(p('Yes', 0.9), threshold: 0.7, now: t0);
      s.add(p('Yes', 0.9), threshold: 0.7, now: t0);
      s.add(p('No', 0.9), threshold: 0.7, now: t0);
      expect(s.add(p('No', 0.9), threshold: 0.7, now: t0), 'No');
    });
  });

  group('GlossProcessor', () {
    const g = GlossProcessor();
    test('normalises and drops consecutive duplicates', () {
      expect(g.normalize('  i   love you '), 'I LOVE YOU');
      var l = <String>[];
      l = g.append(l, 'Hello');
      l = g.append(l, 'hello');
      l = g.append(l, 'Yes');
      expect(l, ['HELLO', 'YES']);
    });
    test('merges fingerspelled runs', () {
      expect(g.mergeFingerspelling(['A', 'B', 'C', 'HELLO', 'A']), ['ABC', 'HELLO', 'A']);
    });
  });

  group('SentenceBuilder', () {
    const b = SentenceBuilder();
    test('single known sign', () => expect(b.build(['HELLO']), 'Hello'));
    test('maps thanks', () => expect(b.build(['THANKS']), 'Thank you'));
    test('phrase match, both word orders', () {
      expect(b.build(['WHERE', 'HOSPITAL']), 'Where is the hospital?');
      expect(b.build(['HOSPITAL', 'WHERE']), 'Where is the hospital?');
    });
    test('question word adds question mark', () => expect(b.build(['WHERE', 'YOU']), 'Where you?'));
    test('multi-word gets a full stop, unknown words pass through', () {
      expect(b.build(['HELLO', 'FRIEND']), 'Hello friend.');
    });
    test('fingerspelling stays as letters', () => expect(b.build(['A', 'B', 'C']), 'ABC'));
    test('localises to Hindi and Kannada', () {
      expect(b.build(['YES'], languageCode: 'hi'), 'हाँ');
      expect(b.build(['THANKS'], languageCode: 'kn'), 'ಧನ್ಯವಾದ');
      expect(b.build(['HELLO', 'PLEASE'], languageCode: 'hi'), endsWith('।'));
    });
    test('empty input', () => expect(b.build([]), ''));
  });

  test('RuleBasedTranslationEngine wraps the builder', () async {
    final r = await const RuleBasedTranslationEngine().translate(['HELLO'], languageCode: 'en');
    expect(r.text, 'Hello');
    expect(r.engineId, 'rule-based');
  });

  group('RecognitionSession', () {
    test('skips until the window is full', () async {
      final s = RecognitionSession(engine: ScriptedEngine([p('Hello', 0.9)]), buffer: LandmarkSequenceBuffer(length: 3));
      s.pushFrame(hand());
      expect(await s.infer(), isNull);
    });

    test('reports no hand and does not call the model', () async {
      final e = ScriptedEngine([p('Hello', 0.9)]);
      final s = RecognitionSession(engine: e, buffer: LandmarkSequenceBuffer(length: 3));
      for (var i = 0; i < 3; i++) {
        s.pushFrame(HandFrame.empty);
      }
      final u = await s.infer();
      expect(u!.handVisible, isFalse);
      expect(e.calls, 0);
    });

    test('accepts a stable sign after two agreeing ticks', () async {
      final s = RecognitionSession(
          engine: ScriptedEngine([p('Thanks', 0.92), p('Thanks', 0.9)]), buffer: LandmarkSequenceBuffer(length: 3));
      for (var i = 0; i < 3; i++) {
        s.pushFrame(hand());
      }
      final first = await s.infer();
      final second = await s.infer();
      expect(first!.accepted, isNull);
      expect(second!.accepted, 'THANKS');
    });
  });
}
