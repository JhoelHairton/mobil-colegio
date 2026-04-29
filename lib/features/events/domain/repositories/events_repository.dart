import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';

abstract class EventsRepository {
  Stream<List<Event>> watchEvents();
  Future<List<Event>> getUpcomingEvents();
  Future<Event?> getEventById(String id);
  Future<String> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);
}
