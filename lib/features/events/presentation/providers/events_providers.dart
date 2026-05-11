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

// ─────────────────────────────────────────────────────────────────────────
// FILTROS
// ─────────────────────────────────────────────────────────────────────────

/// Rango temporal aplicable al listado de eventos.
enum EventTimeRange {
  upcoming('upcoming', 'Próximos'),
  past('past', 'Pasados');

  const EventTimeRange(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Categoría seleccionada en el filtro de la lista de eventos.
/// `null` significa "Todos".
final selectedEventCategoryProvider = StateProvider<EventCategory?>((ref) => null);

/// Rango temporal seleccionado. Por defecto los próximos.
final selectedEventTimeRangeProvider =
    StateProvider<EventTimeRange>((ref) => EventTimeRange.upcoming);

/// Texto de búsqueda libre para filtrar por título o ubicación.
final eventSearchQueryProvider = StateProvider<String>((ref) => '');

/// Eventos filtrados por categoría, rango temporal y búsqueda. La fecha
/// de inicio decide si un evento es "próximo" o "pasado" — los `ongoing`
/// se consideran próximos para no esconderlos del usuario.
final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsAsync = ref.watch(eventsStreamProvider);
  final category = ref.watch(selectedEventCategoryProvider);
  final range = ref.watch(selectedEventTimeRangeProvider);
  final query = ref.watch(eventSearchQueryProvider).trim().toLowerCase();

  return eventsAsync.whenData((events) {
    Iterable<Event> result = events;

    if (category != null) {
      result = result.where((e) => e.category == category);
    }

    result = result.where((e) {
      switch (range) {
        case EventTimeRange.upcoming:
          return !e.isPast;
        case EventTimeRange.past:
          return e.isPast;
      }
    });

    if (query.isNotEmpty) {
      result = result.where((e) {
        return e.title.toLowerCase().contains(query) ||
            e.location.toLowerCase().contains(query);
      });
    }

    final list = result.toList();
    // Pasados se muestran del más reciente al más antiguo; próximos al revés.
    list.sort(
      (a, b) => range == EventTimeRange.past
          ? b.startDate.compareTo(a.startDate)
          : a.startDate.compareTo(b.startDate),
    );
    return list;
  });
});
