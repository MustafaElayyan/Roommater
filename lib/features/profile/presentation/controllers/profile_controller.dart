import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

// --- Dependency graph ---

final _profileDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(ref.watch(firestoreProvider));
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
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileEntity?>(
  ProfileController.new,
);
