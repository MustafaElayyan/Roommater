import 'package:flutter_test/flutter_test.dart';
import 'package:roommater/core/utils/app_utils.dart';

void main() {
  group('Form validation helpers', () {
    group('AppUtils.isValidEmail', () {
      const validEmails = [
        'user@example.com',
        'user.name+tag@sub.domain.org',
        'a@b.io',
      ];

      const invalidEmails = [
        '',
        'plainaddress',
        '@nodomain.com',
        'user@',
        'user@.com',
        'user@domain',
      ];

      for (final email in validEmails) {
        test('accepts valid email: $email', () {
          expect(AppUtils.isValidEmail(email), isTrue);
        });
      }

      for (final email in invalidEmails) {
        test('rejects invalid email: "$email"', () {
          expect(AppUtils.isValidEmail(email), isFalse);
        });
      }
    });

    group('AppUtils.isValidPassword', () {
      test('accepts password with 8 or more characters', () {
        expect(AppUtils.isValidPassword('12345678'), isTrue);
        expect(AppUtils.isValidPassword('abcdefghij'), isTrue);
      });

      test('rejects password shorter than 8 characters', () {
        expect(AppUtils.isValidPassword('1234567'), isFalse);
        expect(AppUtils.isValidPassword(''), isFalse);
      });
    });
  });
}
