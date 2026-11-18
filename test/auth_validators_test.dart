import 'package:book_ease/features/auth/presentation/validators/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators', () {
    test('rejects empty and invalid emails', () {
      expect(AuthValidators.validateEmail(''), 'Email is required.');
      expect(
        AuthValidators.validateEmail('invalid'),
        'Enter a valid email address.',
      );
    });

    test('accepts a valid email', () {
      expect(AuthValidators.validateEmail('patient@example.com'), isNull);
    });

    test('requires a strong registration password', () {
      expect(
        AuthValidators.validatePassword('short'),
        'Password must be at least 8 characters.',
      );
      expect(
        AuthValidators.validatePassword('password1'),
        'Use at least 1 uppercase letter and 1 number.',
      );
      expect(AuthValidators.validatePassword('Password1'), isNull);
    });

    test('requires name and login password', () {
      expect(AuthValidators.validateName(''), 'Full name is required.');
      expect(AuthValidators.validateName('A'), 'Enter a valid full name.');
      expect(AuthValidators.validateName('Patient'), isNull);
      expect(AuthValidators.validateLoginPassword(''), 'Password is required.');
    });
  });
}
