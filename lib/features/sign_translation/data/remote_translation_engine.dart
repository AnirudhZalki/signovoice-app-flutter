import '../../../core/errors/failure.dart';
import '../../../core/services/api_client.dart';
import '../domain/translation_engine.dart';

/// "Advanced AI translation" (premium): POST /v1/translate on the SignoVoice
/// backend, which holds any model/API keys. Contract: docs/BACKEND_CONTRACT.md.
class RemoteTranslationEngine implements TranslationEngine {
  RemoteTranslationEngine(this.api);
  final ApiClient api;

  @override
  String get id => 'remote-ai';

  @override
  Future<TranslationResult> translate(List<String> glosses, {required String languageCode}) async {
    final data = await api.post('/v1/translate', body: {'glosses': glosses, 'language': languageCode});
    final text = data is Map<String, dynamic> ? data['text'] as String? : null;
    if (text == null || text.trim().isEmpty) {
      throw const Failure(FailureType.serviceUnavailable, debugDetail: 'empty translation');
    }
    return TranslationResult(text: text.trim(), glosses: glosses, languageCode: languageCode, engineId: id);
  }
}

/// Uses [primary] when allowed and reachable; otherwise (or on any failure)
/// falls back to [fallback], so translation never hard-fails.
class FallbackTranslationEngine implements TranslationEngine {
  FallbackTranslationEngine({required this.primary, required this.fallback, required this.usePrimary});
  final TranslationEngine primary;
  final TranslationEngine fallback;
  final bool Function() usePrimary;

  @override
  String get id => 'fallback(${primary.id}->${fallback.id})';

  @override
  Future<TranslationResult> translate(List<String> glosses, {required String languageCode}) async {
    if (usePrimary()) {
      try {
        return await primary.translate(glosses, languageCode: languageCode).timeout(const Duration(seconds: 4));
      } catch (_) {/* fall through to local rules */}
    }
    return fallback.translate(glosses, languageCode: languageCode);
  }
}
