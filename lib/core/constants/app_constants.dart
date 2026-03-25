/// Application-wide constants.
///
/// Add compile-time values here that are shared across multiple features.
/// Avoid placing feature-specific constants here; keep those inside the
/// relevant feature's own `domain/` layer.
abstract final class AppConstants {
  // App metadata
  static const String appName = 'Roommater';
  static const String appVersion = '0.1.0';

  // API resource names
  static const String usersCollection = 'users';
  static const String listingsCollection = 'listings';
  static const String chatsCollection = 'chats';
  static const String messagesSubcollection = 'messages';

  // Media resource paths
  static const String avatarStoragePath = 'avatars';
  static const String listingImagesStoragePath = 'listing_images';

  // Pagination
  static const int defaultPageSize = 20;
}
