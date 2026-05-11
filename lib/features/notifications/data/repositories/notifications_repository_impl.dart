import 'package:agenda_escolar_adventista/features/notifications/data/datasources/notifications_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/repositories/notifications_repository.dart';

/// Implementación basada en el datasource mock. Cuando llegue Firebase
/// (Sprint 7), se crea otra implementación con la misma forma — esta
/// queda intacta para tests y modo offline.
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._dataSource);

  final NotificationsMockDataSource _dataSource;

  @override
  Stream<List<AppNotification>> watchMyNotifications(String userId) =>
      _dataSource.watchMyNotifications(userId);

  @override
  Future<void> markAsRead(String notificationId) =>
      _dataSource.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead(String userId) =>
      _dataSource.markAllAsRead(userId);

  @override
  Future<void> deleteNotification(String notificationId) =>
      _dataSource.deleteNotification(notificationId);

  @override
  Future<AppNotification> createNotification(AppNotification notification) =>
      _dataSource.createNotification(notification);
}
