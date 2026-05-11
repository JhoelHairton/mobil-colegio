import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';

abstract class EventsRepository {
  /// Stream público: sólo eventos activos y no archivados. Es lo que
  /// los usuarios finales (padres, docentes, estudiantes) ven.
  Stream<List<Event>> watchEvents();

  /// Stream administrativo: incluye archivados e inactivos. Lo
  /// consume sólo el panel de admin/secretaría.
  Stream<List<Event>> watchAllEvents();

  Future<List<Event>> getUpcomingEvents();
  Future<Event?> getEventById(String id);
  Future<String> createEvent(Event event);
  Future<void> updateEvent(Event event);

  /// Mueve el evento al archivo histórico (no se borra).
  Future<void> archiveEvent(String id, {bool archived = true});

  Future<void> deleteEvent(String id);
}
