import 'package:agenda_escolar_adventista/features/notifications/domain/repositories/notifications_repository.dart';

class MarkAllNotificationsAsRead {
  MarkAllNotificationsAsRead(this._repository);

  final NotificationsRepository _repository;

  Future<void> call(String userId) => _repository.markAllAsRead(userId);
}
