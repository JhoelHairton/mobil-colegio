/// Tipos de notificación in-app que el sistema puede emitir.
///
/// Cuando llegue Firebase Cloud Messaging (Sprint 7), las notificaciones
/// push reutilizan este tipo en el payload para que la UI las renderice
/// con el mismo icono y color.
enum NotificationType {
  /// Nuevo evento publicado por la administración.
  eventPublished,

  /// Documento del padre aprobado por secretaría.
  documentApproved,

  /// Documento del padre rechazado.
  documentRejected,

  /// Documento del padre pasó a "en revisión".
  documentReviewing,

  /// Recordatorio diario para que el docente registre asistencia.
  attendanceReminder,

  /// Aviso general del director o administración.
  generalAnnouncement,
}

/// Entidad de notificación in-app.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.deepLink,
  });

  final String id;

  /// uid del usuario destinatario. La lista es por usuario.
  final String userId;

  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  /// Ruta de go_router a la que navegar al tocar la notificación.
  /// Por ejemplo `/events/detail/evt_007` para abrir un evento.
  final String? deepLink;

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? deepLink,
    bool clearDeepLink = false,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      deepLink: clearDeepLink ? null : (deepLink ?? this.deepLink),
    );
  }
}
