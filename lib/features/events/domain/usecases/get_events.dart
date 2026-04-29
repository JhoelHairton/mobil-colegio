import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/repositories/events_repository.dart';

class GetEvents {
  final EventsRepository _repository;
  GetEvents(this._repository);

  Stream<List<Event>> call() => _repository.watchEvents();
}
