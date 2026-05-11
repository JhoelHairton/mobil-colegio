import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';

/// Contrato del repositorio de notificaciones in-app.
abstract class NotificationsRepository {
  /// Stream de las notificaciones del usuario, ordenadas de la más
  /// reciente a la más antigua. Re-emite ante cambios (mark/delete).
  Stream<List<AppNotification>> watchMyNotifications(String userId);

  /// Marca una notificación específica como leída.
  Future<void> markAsRead(String notificationId);

  /// Marca todas las notificaciones del usuario como leídas.
  Future<void> markAllAsRead(String userId);

  /// Elimina una notificación.
  Future<void> deleteNotification(String notificationId);

  /// Crea una nueva notificación. La usa la administración cuando
  /// emite avisos (por ejemplo: aprobar/rechazar un documento envía
  /// una notificación al padre correspondiente).
  Future<AppNotification> createNotification(AppNotification notification);
}
