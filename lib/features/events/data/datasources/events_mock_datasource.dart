import 'dart:async';

import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_events.dart';

/// Datasource en memoria para events.
///
/// Mantiene una lista mutable y dos broadcast controllers (uno público
/// para usuarios finales con eventos visibles, otro global para admin
/// que muestra TODO incluido archivados/inactivos). Los métodos CRUD
/// actualizan la lista y emiten en ambos streams cuando corresponde.
///
/// Sustituye al futuro datasource Firestore. Cuando llegue Sprint 7,
/// se crea otro datasource con la misma forma pública y el repository
/// elige cuál inyectar.
class EventsMockDataSource {
  EventsMockDataSource() {
    _events = [...MockEvents.all];
  }

  late final List<Event> _events;
  StreamController<List<Event>>? _publicController;
  StreamController<List<Event>>? _allController;

  /// Latencia simulada para que el shimmer/skeleton no parpadee.
  static const Duration _initialLatency = Duration(milliseconds: 500);
  static const Duration _shortLatency = Duration(milliseconds: 250);
  static const Duration _writeLatency = Duration(milliseconds: 700);

  // ─── Lectores ──────────────────────────────────────────────────────

  /// Stream público: sólo eventos `isActive && !isArchived`. Es lo que
  /// ven padres, docentes y estudiantes en la app.
  Stream<List<Event>> watchEvents() {
    final controller =
        _publicController ??= StreamController<List<Event>>.broadcast();

    Future<void>.delayed(_initialLatency, () {
      if (!controller.isClosed) controller.add(_publicSorted());
    });

    return controller.stream;
  }

  /// Stream para admin/secretaría: incluye archivados e inactivos.
  Stream<List<Event>> watchAllEvents() {
    final controller =
        _allController ??= StreamController<List<Event>>.broadcast();

    Future<void>.delayed(_initialLatency, () {
      if (!controller.isClosed) controller.add(_allSorted());
    });

    return controller.stream;
  }

  Future<List<Event>> getUpcomingEvents() async {
    await Future<void>.delayed(_initialLatency);
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

  // ─── Escritores ────────────────────────────────────────────────────

  Future<String> createEvent(Event event) async {
    await Future<void>.delayed(_writeLatency);
    final withId = event.id.isEmpty
        ? event.copyWith(id: 'evt_${DateTime.now().millisecondsSinceEpoch}')
        : event;
    _events.add(withId);
    _emitAll();
    return withId.id;
  }

  Future<void> updateEvent(Event event) async {
    await Future<void>.delayed(_writeLatency);
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      throw StateError('Evento ${event.id} no encontrado.');
    }
    _events[index] = event;
    _emitAll();
  }

  Future<void> archiveEvent(String id, {bool archived = true}) async {
    await Future<void>.delayed(_writeLatency);
    final index = _events.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw StateError('Evento $id no encontrado.');
    }
    _events[index] = _events[index].copyWith(isArchived: archived);
    _emitAll();
  }

  Future<void> deleteEvent(String id) async {
    await Future<void>.delayed(_writeLatency);
    _events.removeWhere((e) => e.id == id);
    _emitAll();
  }

  // ─── helpers ──────────────────────────────────────────────────────

  List<Event> _publicSorted() {
    final list = _events
        .where((e) => e.isActive && !e.isArchived)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return list;
  }

  List<Event> _allSorted() {
    // Para admin: orden por relevancia. No archivados primero (los
    // próximos arriba), archivados al final.
    final list = [..._events];
    list.sort((a, b) {
      // Archivados van al final
      if (a.isArchived != b.isArchived) {
        return a.isArchived ? 1 : -1;
      }
      // Dentro del mismo grupo, los próximos primero (asc por start)
      return a.startDate.compareTo(b.startDate);
    });
    return list;
  }

  void _emitAll() {
    final pub = _publicController;
    if (pub != null && !pub.isClosed) pub.add(_publicSorted());
    final all = _allController;
    if (all != null && !all.isClosed) all.add(_allSorted());
  }
}
