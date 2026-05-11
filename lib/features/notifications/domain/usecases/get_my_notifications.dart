import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/repositories/notifications_repository.dart';

class GetMyNotifications {
  GetMyNotifications(this._repository);

  final NotificationsRepository _repository;

  Stream<List<AppNotification>> call(String userId) =>
      _repository.watchMyNotifications(userId);
}
