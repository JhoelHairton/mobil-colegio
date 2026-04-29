import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_events.dart';

/// Datasource en memoria para events.
///
/// Sustituye al futuro datasource Firestore. Cuando llegue Sprint 7,
/// se crea otro datasource con la misma forma pública y el repository
/// elige cuál inyectar.
class EventsMockDataSource {
  EventsMockDataSource() {
    _events = [...MockEvents.all];
  }

  late final List<Event> _events;

  /// Latencia simulada para que el shimmer/skeleton no parpadee.
  static const Duration _latency = Duration(milliseconds: 500);
  static const Duration _shortLatency = Duration(milliseconds: 250);

  /// Stream que emite el listado activo de eventos. En el mock emitimos
  /// una sola vez (no hay sincronización en tiempo real).
  Stream<List<Event>> watchEvents() async* {
    await Future<void>.delayed(_latency);
    yield _activeNonArchivedSorted();
  }

  Future<List<Event>> getUpcomingEvents() async {
    await Future<void>.delayed(_latency);
    final now = DateTime.now();
    final upcoming = _events
        .where((e) => e.isActive && !e.isArchived && e.startDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.take(10).toList();
  }

  Future<Event?> getEventById(String id) async {
    await Future<void>.delayed(_shortLatency);
    for (final e in _events) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Lista interna ordenada por fecha de inicio ascendente.
  List<Event> _activeNonArchivedSorted() {
    final list = _events.where((e) => e.isActive && !e.isArchived).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return list;
  }
}
