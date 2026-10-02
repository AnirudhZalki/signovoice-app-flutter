import '../../../core/errors/failure.dart';
import '../../../core/services/api_client.dart';
import '../domain/interpreter_models.dart';
import '../domain/interpreter_repository.dart';

/// Contract: docs/BACKEND_CONTRACT.md → "Interpreters".
class HttpInterpreterRepository implements InterpreterRepository {
  HttpInterpreterRepository(this.api);
  final ApiClient api;

  Map<String, dynamic> _map(dynamic d) {
    if (d is Map<String, dynamic>) return d;
    throw const Failure(FailureType.serviceUnavailable, debugDetail: 'malformed response');
  }

  @override
  Future<List<Interpreter>> list({String? language}) async {
    final d = _map(await api.get('/v1/interpreters', query: {'language': ?language}));
    return [for (final e in (d['interpreters'] as List<dynamic>? ?? const [])) Interpreter.fromJson(e as Map<String, dynamic>)];
  }

  @override
  Future<CallRequestState> requestInterpreter({required CallMode mode, required String language, String? interpreterId, String? note}) async {
    final d = _map(await api.post('/v1/interpreter/requests', body: {
      'mode': mode.name,
      'language': language,
      'interpreterId': ?interpreterId,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    }));
    return CallRequestState.fromJson(d);
  }

  @override
  Future<CallRequestState> requestStatus(String requestId) async =>
      CallRequestState.fromJson(_map(await api.get('/v1/interpreter/requests/$requestId')), fallbackId: requestId);

  @override
  Future<void> cancelRequest(String requestId) async {
    await api.delete('/v1/interpreter/requests/$requestId');
  }

  @override
  Future<void> submitFeedback({required String callId, required int rating, String? comment}) async {
    await api.post('/v1/interpreter/calls/$callId/feedback', body: {
      'rating': rating,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
  }

  @override
  Future<void> reportIssue({required String callId, required IssueCategory category, String? details}) async {
    await api.post('/v1/interpreter/calls/$callId/report', body: {
      'category': category.name,
      if (details != null && details.trim().isNotEmpty) 'details': details.trim(),
    });
  }

  @override
  Future<InterpreterMe> me() async => InterpreterMe.fromJson(_map(await api.get('/v1/interpreter/me')));

  @override
  Future<void> setAvailability({required bool available}) async {
    await api.post('/v1/interpreter/me/status', body: {'status': available ? 'available' : 'offline'});
  }

  @override
  Future<List<IncomingRequest>> queue() async {
    final d = _map(await api.get('/v1/interpreter/queue'));
    return [for (final e in (d['requests'] as List<dynamic>? ?? const [])) IncomingRequest.fromJson(e as Map<String, dynamic>)];
  }

  @override
  Future<CallSession> accept(String requestId) async {
    final d = _map(await api.post('/v1/interpreter/queue/$requestId/accept'));
    return CallSession.fromJson(_map(d['session']));
  }

  @override
  Future<void> endCall(String callId) async {
    await api.post('/v1/interpreter/calls/$callId/end');
  }
}
