/// Pure input validation. Return values are [ValidationError] codes so the UI
/// can localise them; `null` means valid.
enum ValidationError {
  required,
  invalidEmail,
  weakPassword,
  passwordMismatch,
  invalidPhone,
  invalidOtp,
  nameTooShort,
}

class Validators {
  const Validators._();

  static final RegExp _email =
      RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
  static final RegExp _e164 = RegExp(r'^\+[1-9]\d{7,14}$');

  static ValidationError? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return ValidationError.required;
    return _email.hasMatch(s) ? null : ValidationError.invalidEmail;
  }

  /// At least 8 chars with a letter and a digit.
  static ValidationError? password(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return ValidationError.required;
    final ok = s.length >= 8 && RegExp(r'[A-Za-z]').hasMatch(s) && RegExp(r'\d').hasMatch(s);
    return ok ? null : ValidationError.weakPassword;
  }

  static ValidationError? confirmPassword(String? v, String? original) {
    if ((v ?? '').isEmpty) return ValidationError.required;
    return v == original ? null : ValidationError.passwordMismatch;
  }

  /// Accepts E.164 (+91XXXXXXXXXX). [normalizePhone] adds a default country code.
  static ValidationError? phone(String? v, {String defaultCountryCode = '+91'}) {
    final s = normalizePhone(v ?? '', defaultCountryCode: defaultCountryCode);
    if (s.isEmpty) return ValidationError.required;
    return _e164.hasMatch(s) ? null : ValidationError.invalidPhone;
  }

  static String normalizePhone(String raw, {String defaultCountryCode = '+91'}) {
    final digits = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('+')) return digits;
    final local = digits.startsWith('0') ? digits.substring(1) : digits;
    return '$defaultCountryCode$local';
  }

  static ValidationError? otp(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return ValidationError.required;
    return RegExp(r'^\d{6}$').hasMatch(s) ? null : ValidationError.invalidOtp;
  }

  static ValidationError? name(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return ValidationError.required;
    return s.length < 2 ? ValidationError.nameTooShort : null;
  }
}
