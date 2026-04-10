import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firestore_service.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_photo_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

// --- Dependency graph ---

final _profileDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseStorageProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(_profileDataSourceProvider));
});

final _getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final _updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final _changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(profileRepositoryProvider));
});

final _updateProfilePhotoUseCaseProvider = Provider<UpdateProfilePhotoUseCase>((ref) {
  return UpdateProfilePhotoUseCase(ref.watch(profileRepositoryProvider));
});

// --- State ---

/// Async profile for a given [uid].
final profileProvider =
    FutureProvider.family<ProfileEntity, String>((ref, uid) {
  return ref.watch(_getProfileUseCaseProvider)(uid);
});

// --- Controller ---

class ProfileController extends AsyncNotifier<ProfileEntity?> {
  @override
  Future<ProfileEntity?> build() async => null;

  Future<void> loadProfile(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(_getProfileUseCaseProvider)(uid),
    );
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(_updateProfileUseCaseProvider)(profile),
    );
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(_changePasswordUseCaseProvider)(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }

  Future<void> updateProfilePhoto({
    required String uid,
    required List<int> bytes,
    required String extension,
    required String contentType,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_updateProfilePhotoUseCaseProvider)(
        uid: uid,
        bytes: bytes,
        extension: extension,
        contentType: contentType,
      );
      return ref.read(_getProfileUseCaseProvider)(uid);
    });
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileEntity?>(
  ProfileController.new,
);
