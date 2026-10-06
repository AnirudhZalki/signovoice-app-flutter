import '../../core/errors/failure.dart';
import '../../l10n/app_localizations.dart';

/// Human-readable, localised explanation for a [Failure].
String failureMessage(AppLocalizations l, Failure f) => switch (f.type) {
      FailureType.offline => l.failureOffline,
      FailureType.network => l.failureNetwork,
      FailureType.timeout => l.failureTimeout,
      FailureType.unauthorized => l.failureUnauthorized,
      FailureType.notConfigured => l.failureNotConfigured,
      FailureType.permissionDenied => l.failurePermissionDenied,
      FailureType.permissionPermanentlyDenied => l.failurePermissionPermanent,
      FailureType.modelUnavailable => l.failureModelUnavailable,
      FailureType.serviceUnavailable => l.failureServiceUnavailable,
      FailureType.billingUnavailable => l.failureBilling,
      FailureType.cancelled => l.failureCancelled,
      FailureType.validation => l.failureValidation,
      FailureType.notFound => l.failureNotFound,
      FailureType.requiresRecentLogin => l.failureRecentLogin,
      FailureType.limitReached => l.failureLimit,
      FailureType.unknown => l.failureUnknown,
    };

/// [failureMessage] plus a short, non-sensitive reason such as "(unauthorized · 401)", so a problem can be reported precisely.
String failureMessageWithReason(AppLocalizations l, Failure f) =>
    '${failureMessage(l, f)}\n(${f.type.name}${f.code == null ? '' : ' · ${f.code}'})'
    // For server answers (code is an HTTP status) also show the server's own short reason.
    '${f.code != null && f.debugDetail != null ? '\n${f.debugDetail}' : ''}';
