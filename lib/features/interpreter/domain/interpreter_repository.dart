import 'interpreter_models.dart';

/// Backend operations for interpreters. Throws `Failure`
/// (`notConfigured` when there's no backend).
abstract class InterpreterRepository {
  Future<List<Interpreter>> list({String? language});
  Future<CallRequestState> requestInterpreter({required CallMode mode, required String language, String? interpreterId, String? note});
  Future<CallRequestState> requestStatus(String requestId);
  Future<void> cancelRequest(String requestId);
  Future<void> submitFeedback({required String callId, required int rating, String? comment});
  Future<void> reportIssue({required String callId, required IssueCategory category, String? details});
}
