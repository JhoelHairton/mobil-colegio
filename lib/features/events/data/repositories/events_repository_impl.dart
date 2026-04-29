import 'package:agenda_escolar_adventista/features/events/data/datasources/events_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/repositories/events_repository.dart';

/// Implementación del repositorio de eventos basada en el datasource mock.
///
/// Cuando lleguemos a Sprint 7 (Firebase), se crea un
/// `EventsRepositoryFirestore` que implementa la misma interfaz y se
/// cambia el binding en el provider — esta clase queda intacta para
/// pruebas y modo offline.
class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl(this._dataSource);

  final EventsMockDataSource _dataSource;

  @override
  Stream<List<Event>> watchEvents() => _dataSource.watchEvents();

  @override
  Future<List<Event>> getUpcomingEvents() => _dataSource.getUpcomingEvents();

  @override
  Future<Event?> getEventById(String id) => _dataSource.getEventById(id);

  @override
  Future<String> createEvent(Event event) async {
    // No soportamos creación todavía en mock. Se implementa cuando
    // llegue el panel web admin (Sprint 6).
    throw UnimplementedError('createEvent disponible cuando se conecte el panel admin.');
  }

  @override
  Future<void> updateEvent(Event event) async {
    throw UnimplementedError('updateEvent disponible cuando se conecte el panel admin.');
  }

  @override
  Future<void> deleteEvent(String id) async {
    throw UnimplementedError('deleteEvent disponible cuando se conecte el panel admin.');
  }
}
