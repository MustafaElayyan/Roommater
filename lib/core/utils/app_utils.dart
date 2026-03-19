/// Miscellaneous utility functions shared across features.
///
/// Keep this file small; if helpers grow large, extract them into dedicated
/// files inside `lib/core/utils/`.
abstract final class AppUtils {
  /// Returns `true` if [email] is a syntactically valid email address.
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w.+-]+@([\w-]+\.)+[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Returns `true` if [password] meets the minimum security requirement
  /// (at least 8 characters).
  static bool isValidPassword(String password) => password.length >= 8;

  /// Capitalises the first letter of [text] and lower-cases the rest.
  static String capitalise(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
