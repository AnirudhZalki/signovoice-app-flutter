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

  /// After the Razorpay checkout succeeds: the backend verifies the signature and queues the request.
  Future<CallRequestState> payRequest({required String requestId, required String orderId, required String paymentId, required String signature});

  // Interpreter side
  Future<InterpreterMe> saveProfile({required String name, required List<String> languages, required int ratePaise, String? bio});
  Future<void> decline(String requestId);
  Future<InterpreterMe> me();
  Future<void> setAvailability({required bool available});
  Future<List<IncomingRequest>> queue();
  Future<CallSession> accept(String requestId);
  Future<void> endCall(String callId);

  // Admin
  Future<bool> isAdmin();
  Future<List<AdminInterpreter>> adminInterpreters({String filter = 'all'});
  Future<void> adminSetApproved(String uid, {required bool approved});
}
