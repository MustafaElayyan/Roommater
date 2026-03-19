import 'package:flutter_test/flutter_test.dart';
import 'package:roommater/core/utils/app_utils.dart';

void main() {
  group('AppUtils.isValidEmail', () {
    test('returns true for valid email formats', () {
      expect(AppUtils.isValidEmail('user@example.com'), isTrue);
      expect(AppUtils.isValidEmail('user+tag@domain.co.uk'), isTrue);
    });

    test('returns false for invalid email formats', () {
      expect(AppUtils.isValidEmail('user@.com'), isFalse);
      expect(AppUtils.isValidEmail('@example.com'), isFalse);
      expect(AppUtils.isValidEmail(''), isFalse);
    });
  });

  group('AppUtils.isValidPassword', () {
    test('returns true for passwords with at least 8 characters', () {
      expect(AppUtils.isValidPassword('12345678'), isTrue);
      expect(AppUtils.isValidPassword('very_secure_password'), isTrue);
    });

    test('returns false for passwords shorter than 8 characters', () {
      expect(AppUtils.isValidPassword('1234567'), isFalse);
      expect(AppUtils.isValidPassword(''), isFalse);
    });
  });

  group('AppUtils.capitalise', () {
    test('capitalises correctly across edge cases', () {
      expect(AppUtils.capitalise(''), '');
      expect(AppUtils.capitalise('a'), 'A');
      expect(AppUtils.capitalise('hello'), 'Hello');
      expect(AppUtils.capitalise('ALL CAPS'), 'All caps');
    });
  });
}
