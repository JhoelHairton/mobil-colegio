import 'package:agenda_escolar_adventista/features/events/data/datasources/events_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/repositories/events_repository.dart';

/// Implementación del repositorio de eventos basada en el datasource
/// mock. Cuando llegue Sprint 7 (Firebase) se crea otra implementación
/// con la misma forma — esta queda intacta para tests y modo offline.
class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl(this._dataSource);

  final EventsMockDataSource _dataSource;

  @override
  Stream<List<Event>> watchEvents() => _dataSource.watchEvents();

  @override
  Stream<List<Event>> watchAllEvents() => _dataSource.watchAllEvents();

  @override
  Future<List<Event>> getUpcomingEvents() => _dataSource.getUpcomingEvents();

  @override
  Future<Event?> getEventById(String id) => _dataSource.getEventById(id);

  @override
  Future<String> createEvent(Event event) => _dataSource.createEvent(event);

  @override
  Future<void> updateEvent(Event event) => _dataSource.updateEvent(event);

  @override
  Future<void> archiveEvent(String id, {bool archived = true}) =>
      _dataSource.archiveEvent(id, archived: archived);

  @override
  Future<void> deleteEvent(String id) => _dataSource.deleteEvent(id);
}
