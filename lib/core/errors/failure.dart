/// Categories of failure the UI knows how to explain to a person.
enum FailureType {
  offline,
  network,
  timeout,
  unauthorized,
  notConfigured,
  permissionDenied,
  permissionPermanentlyDenied,
  modelUnavailable,
  serviceUnavailable,
  billingUnavailable,
  cancelled,
  validation,
  notFound,
  requiresRecentLogin,
  limitReached,
  unknown,
}

/// Domain-level failure. [debugDetail] is for logs only and is never shown.
class Failure implements Exception {
  const Failure(this.type, {this.debugDetail, this.code});

  final FailureType type;
  final String? debugDetail;

  /// Optional machine code (e.g. a Firebase auth error code) for UI branching.
  final String? code;

  bool get isRetryable => switch (type) {
        FailureType.offline ||
        FailureType.network ||
        FailureType.timeout ||
        FailureType.serviceUnavailable ||
        FailureType.unknown =>
          true,
        _ => false,
      };

  @override
  String toString() => 'Failure($type${code == null ? '' : ', $code'})';
}
