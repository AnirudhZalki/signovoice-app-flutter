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
