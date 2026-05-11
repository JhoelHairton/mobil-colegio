import 'package:agenda_escolar_adventista/features/notifications/domain/repositories/notifications_repository.dart';

class DeleteNotification {
  DeleteNotification(this._repository);

  final NotificationsRepository _repository;

  Future<void> call(String notificationId) =>
      _repository.deleteNotification(notificationId);
}
