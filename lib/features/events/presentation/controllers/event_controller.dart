import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firestore_service.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../data/datasources/event_remote_datasource.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/usecases/create_event_usecase.dart';
import '../../domain/usecases/delete_event_usecase.dart';
import '../../domain/usecases/get_events_usecase.dart';

final _eventDataSourceProvider = Provider<EventRemoteDataSource>((ref) {
  return EventRemoteDataSource(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(ref.watch(_eventDataSourceProvider));
});

final _getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  return GetEventsUseCase(ref.watch(eventRepositoryProvider));
});

final _createEventUseCaseProvider = Provider<CreateEventUseCase>((ref) {
  return CreateEventUseCase(ref.watch(eventRepositoryProvider));
});

final _deleteEventUseCaseProvider = Provider<DeleteEventUseCase>((ref) {
  return DeleteEventUseCase(ref.watch(eventRepositoryProvider));
});

final eventsProvider = FutureProvider<List<EventEntity>>((ref) {
  final household = ref.watch(currentHouseholdProvider);
  if (household == null) return [];
  return ref.watch(_getEventsUseCaseProvider)(household.id);
});

class EventController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createEvent({
    required String title,
    String? description,
    required DateTime eventDate,
    String? eventTime,
    String? location,
    required String eventType,
  }) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_createEventUseCaseProvider)(
            household.id,
            title: title,
            description: description,
            eventDate: eventDate,
            eventTime: eventTime,
            location: location,
            eventType: eventType,
          );
      ref.invalidate(eventsProvider);
    });
  }

  Future<void> deleteEvent(String eventId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_deleteEventUseCaseProvider)(eventId);
      ref.invalidate(eventsProvider);
    });
  }
}

final eventControllerProvider = AsyncNotifierProvider<EventController, void>(
  EventController.new,
);
