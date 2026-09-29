import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/utils/validators.dart';

void main() {
  group('email', () {
    test('accepts valid', () => expect(Validators.email('a.b+c@example.co.in'), isNull));
    test('rejects invalid', () {
      expect(Validators.email('nope'), ValidationError.invalidEmail);
      expect(Validators.email('a@b'), ValidationError.invalidEmail);
      expect(Validators.email('  '), ValidationError.required);
    });
  });

  group('password', () {
    test('needs 8 chars, letter and digit', () {
      expect(Validators.password('abc12345'), isNull);
      expect(Validators.password('short1'), ValidationError.weakPassword);
      expect(Validators.password('allletters'), ValidationError.weakPassword);
      expect(Validators.password('12345678'), ValidationError.weakPassword);
      expect(Validators.password(''), ValidationError.required);
    });
    test('confirm must match', () {
      expect(Validators.confirmPassword('x', 'y'), ValidationError.passwordMismatch);
      expect(Validators.confirmPassword('x', 'x'), isNull);
    });
  });

  group('phone', () {
    test('normalises to E.164 with default country code', () {
      expect(Validators.normalizePhone('98765 43210'), '+919876543210');
      expect(Validators.normalizePhone('098765-43210'), '+919876543210');
      expect(Validators.normalizePhone('+1 (415) 555-2671'), '+14155552671');
    });
    test('validates', () {
      expect(Validators.phone('9876543210'), isNull);
      expect(Validators.phone('12'), ValidationError.invalidPhone);
      expect(Validators.phone(''), ValidationError.required);
    });
  });

  test('otp is exactly 6 digits', () {
    expect(Validators.otp('123456'), isNull);
    expect(Validators.otp('12345'), ValidationError.invalidOtp);
    expect(Validators.otp('12345a'), ValidationError.invalidOtp);
  });

  test('name needs 2+ chars', () {
    expect(Validators.name('A'), ValidationError.nameTooShort);
    expect(Validators.name('Al'), isNull);
  });
}
