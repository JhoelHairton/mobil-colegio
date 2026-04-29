import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/features/events/data/datasources/events_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/events/data/repositories/events_repository_impl.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/domain/repositories/events_repository.dart';

/// Datasource único en memoria. Cuando llegue Firebase se reemplaza por
/// el datasource Firestore conservando esta misma forma.
final eventsMockDataSourceProvider = Provider<EventsMockDataSource>((ref) {
  return EventsMockDataSource();
});

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepositoryImpl(ref.watch(eventsMockDataSourceProvider));
});

/// Stream de todos los eventos activos no archivados, ordenados por
/// fecha ascendente.
final eventsStreamProvider = StreamProvider<List<Event>>((ref) {
  return ref.watch(eventsRepositoryProvider).watchEvents();
});

/// Detalle de un evento por id.
final eventByIdProvider = FutureProvider.family<Event?, String>((ref, id) {
  return ref.watch(eventsRepositoryProvider).getEventById(id);
});

/// Categoría seleccionada en el filtro de la lista de eventos.
/// `null` significa "Todos".
final selectedEventCategoryProvider = StateProvider<EventCategory?>((ref) => null);

/// Eventos filtrados por la categoría seleccionada.
final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsAsync = ref.watch(eventsStreamProvider);
  final selected = ref.watch(selectedEventCategoryProvider);

  return eventsAsync.whenData((events) {
    if (selected == null) return events;
    return events.where((e) => e.category == selected).toList();
  });
});
