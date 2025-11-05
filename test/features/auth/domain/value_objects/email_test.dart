import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/features/auth/domain/value_objects/email.dart';

void main() {
  group('Email', () {
    test('should create valid email', () {
      const email = Email('test@example.com');
      expect(email.value, 'test@example.com');
      expect(email.isValid, true);
      expect(email.validationError, null);
    });

    test('should invalidate empty email', () {
      const email = Email('');
      expect(email.isValid, false);
      expect(email.validationError, 'Email is required');
    });

    test('should invalidate malformed email', () {
      const email = Email('not-an-email');
      expect(email.isValid, false);
      expect(email.validationError, 'Invalid email format');
    });

    test('should validate various email formats', () {
      const validEmails = [
        'user@example.com',
        'user.name@example.com',
        'user+tag@example.co.uk',
        'user_123@example-domain.com',
      ];

      for (final emailStr in validEmails) {
        final email = Email(emailStr);
        expect(email.isValid, true, reason: '$emailStr should be valid');
        expect(email.validationError, null);
      }
    });
  });
}


