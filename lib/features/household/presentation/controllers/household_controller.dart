import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firestore_service.dart';
import '../../data/datasources/household_remote_datasource.dart';
import '../../data/repositories/household_repository_impl.dart';
import '../../domain/entities/household_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/household_repository.dart';
import '../../domain/usecases/create_household_usecase.dart';
import '../../domain/usecases/get_household_usecase.dart';
import '../../domain/usecases/get_members_usecase.dart';
import '../../domain/usecases/join_household_usecase.dart';
import '../../domain/usecases/remove_member_usecase.dart';

// --- Dependency graph ---

final _householdDataSourceProvider =
    Provider<HouseholdRemoteDataSource>((ref) {
  return HouseholdRemoteDataSource(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepositoryImpl(ref.watch(_householdDataSourceProvider));
});

final _createHouseholdUseCaseProvider =
    Provider<CreateHouseholdUseCase>((ref) {
  return CreateHouseholdUseCase(ref.watch(householdRepositoryProvider));
});

final _joinHouseholdUseCaseProvider = Provider<JoinHouseholdUseCase>((ref) {
  return JoinHouseholdUseCase(ref.watch(householdRepositoryProvider));
});

final _getHouseholdUseCaseProvider = Provider<GetHouseholdUseCase>((ref) {
  return GetHouseholdUseCase(ref.watch(householdRepositoryProvider));
});

final _getMembersUseCaseProvider = Provider<GetMembersUseCase>((ref) {
  return GetMembersUseCase(ref.watch(householdRepositoryProvider));
});

final _removeMemberUseCaseProvider = Provider<RemoveMemberUseCase>((ref) {
  return RemoveMemberUseCase(ref.watch(householdRepositoryProvider));
});

// --- State ---

/// Stores the current user's household, or `null` when not in a household.
final currentHouseholdProvider = StateProvider<HouseholdEntity?>((ref) => null);

/// Fetches the members for the household with [householdId].
final householdMembersProvider =
    FutureProvider.family<List<MemberEntity>, String>((ref, householdId) {
  return ref.watch(_getMembersUseCaseProvider)(householdId);
});

// --- Controller ---

/// Manages household interactions from the UI.
class HouseholdController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createHousehold(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final household = await ref.read(_createHouseholdUseCaseProvider)(name);
      ref.read(currentHouseholdProvider.notifier).state = household;
    });
  }

  Future<void> joinHousehold(String inviteCode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final household =
          await ref.read(_joinHouseholdUseCaseProvider)(inviteCode);
      ref.read(currentHouseholdProvider.notifier).state = household;
    });
  }

  Future<void> loadHousehold(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final household = await ref.read(_getHouseholdUseCaseProvider)(id);
      ref.read(currentHouseholdProvider.notifier).state = household;
    });
  }

  Future<void> removeMember({
    required String householdId,
    required String userId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_removeMemberUseCaseProvider)(
        householdId: householdId,
        userId: userId,
      );
      ref.invalidate(householdMembersProvider(householdId));
    });
  }

  Future<void> deleteHousehold(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(householdRepositoryProvider).deleteHousehold(id);
      ref.read(currentHouseholdProvider.notifier).state = null;
    });
  }
}

final householdControllerProvider =
    AsyncNotifierProvider<HouseholdController, void>(
  HouseholdController.new,
);
