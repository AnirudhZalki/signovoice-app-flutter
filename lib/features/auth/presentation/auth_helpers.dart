import '../../../core/errors/failure.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/failure_message.dart';

String? validationText(AppLocalizations l, ValidationError? e) => switch (e) {
      null => null,
      ValidationError.required => l.validationRequired,
      ValidationError.invalidEmail => l.validationEmail,
      ValidationError.weakPassword => l.validationPassword,
      ValidationError.passwordMismatch => l.validationPasswordMismatch,
      ValidationError.invalidPhone => l.validationPhone,
      ValidationError.invalidOtp => l.validationOtp,
      ValidationError.nameTooShort => l.validationName,
    };

/// Friendly, specific message for auth failures (falls back to generic ones).
String authFailureMessage(AppLocalizations l, Failure f) {
  switch (f.code) {
    case 'wrong-password':
    case 'invalid-credential':
    case 'user-not-found':
      return l.authInvalidCredentials;
    case 'email-already-in-use':
      return l.authEmailInUse;
    case 'weak-password':
      return l.authWeakPassword;
    case 'too-many-requests':
      return l.authTooMany;
    case 'invalid-verification-code':
    case 'invalid-verification-id':
      return l.authInvalidCode;
    case 'user-disabled':
      return l.authDisabled;
    case 'google-cancelled':
      return l.googleSignInCancelled;
    case 'invalid-phone-number':
      return l.validationPhone;
    case 'invalid-email':
      return l.validationEmail;
  }
  return failureMessage(l, f);
}
