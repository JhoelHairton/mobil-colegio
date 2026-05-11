import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';
import 'package:agenda_escolar_adventista/features/notifications/data/datasources/notifications_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/usecases/delete_notification.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/usecases/mark_all_notifications_as_read.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/usecases/mark_notification_as_read.dart';

/// Datasource único en memoria. Cuando llegue Firebase se reemplaza por
/// el datasource Firestore conservando esta misma forma.
final notificationsMockDataSourceProvider =
    Provider<NotificationsMockDataSource>((ref) {
  return NotificationsMockDataSource();
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(
    ref.watch(notificationsMockDataSourceProvider),
  );
});

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsRead>((ref) {
  return MarkNotificationAsRead(ref.watch(notificationsRepositoryProvider));
});

final markAllNotificationsAsReadUseCaseProvider =
    Provider<MarkAllNotificationsAsRead>((ref) {
  return MarkAllNotificationsAsRead(ref.watch(notificationsRepositoryProvider));
});

final deleteNotificationUseCaseProvider = Provider<DeleteNotification>((ref) {
  return DeleteNotification(ref.watch(notificationsRepositoryProvider));
});

/// Stream de las notificaciones del usuario actualmente autenticado.
/// Vacío si no hay sesión.
final myNotificationsStreamProvider =
    StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream<List<AppNotification>>.value(const []);
  }
  return ref
      .watch(notificationsRepositoryProvider)
      .watchMyNotifications(user.uid);
});

/// Filtro de visibilidad: `true` = sólo no leídas. Por defecto `false`.
final showUnreadOnlyProvider = StateProvider<bool>((ref) => false);

/// Notificaciones según el filtro [showUnreadOnlyProvider].
final filteredNotificationsProvider =
    Provider<AsyncValue<List<AppNotification>>>((ref) {
  final asyncList = ref.watch(myNotificationsStreamProvider);
  final unreadOnly = ref.watch(showUnreadOnlyProvider);
  return asyncList.whenData((items) {
    if (!unreadOnly) return items;
    return items.where((n) => !n.isRead).toList(growable: false);
  });
});

/// Conteo de no leídas para mostrar en badges (home, drawer, etc.).
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final asyncList = ref.watch(myNotificationsStreamProvider);
  return asyncList.maybeWhen(
    data: (items) => items.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
