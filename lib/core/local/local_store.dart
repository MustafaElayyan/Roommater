import 'dart:async';

import '../../features/auth/data/models/user_model.dart';
import '../../features/chat/data/models/chat_model.dart';
import '../../features/chat/data/models/message_model.dart';
import '../../features/profile/data/models/profile_model.dart';
import '../../features/roommate_listing/data/models/listing_model.dart';

final class LocalStore {
  LocalStore._();

  static final Map<String, LocalAuthAccount> accountsByEmail = {};
  static UserModel? currentUser;
  static final StreamController<UserModel?> authStateController =
      StreamController<UserModel?>.broadcast();

  static final Map<String, ProfileModel> profilesById = {
    'placeholder_uid': const ProfileModel(
      uid: 'placeholder_uid',
      displayName: 'Demo User',
      email: 'demo@roommater.local',
      bio: 'This profile is served from local app data.',
      location: 'Localhost',
    ),
  };

  static final Map<String, ListingModel> listingsById = {
    'listing_1': ListingModel(
      id: 'listing_1',
      ownerId: 'placeholder_uid',
      title: 'Sunny Room Near Campus',
      description: 'Private room with shared kitchen and high-speed Wi-Fi.',
      rent: 450,
      location: 'Downtown',
      imageUrls: const [],
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      isAvailable: true,
    ),
  };

  static final Map<String, ChatModel> chatsById = {
    'chat_1': ChatModel(
      id: 'chat_1',
      participantIds: const ['placeholder_uid', 'owner_1'],
      lastMessage: 'Hey! Is the room still available?',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  };

  static final Map<String, List<MessageModel>> messagesByChatId = {
    'chat_1': [
      MessageModel(
        id: 'message_1',
        chatId: 'chat_1',
        senderId: 'owner_1',
        text: 'Yes, it is available.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
      MessageModel(
        id: 'message_2',
        chatId: 'chat_1',
        senderId: 'placeholder_uid',
        text: 'Hey! Is the room still available?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  };

  static final StreamController<void> chatsChangedController =
      StreamController<void>.broadcast();
  static final StreamController<String> messagesChangedController =
      StreamController<String>.broadcast();

  static String nextId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
}

final class LocalAuthAccount {
  const LocalAuthAccount({
    required this.uid,
    required this.email,
    required this.password,
  });

  final String uid;
  final String email;
  final String password;
}
