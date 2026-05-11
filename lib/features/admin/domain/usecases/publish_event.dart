import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/domain/repositories/events_repository.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

/// Caso de uso "Publicar evento": crea (o actualiza) el evento Y emite
/// una notificación a cada usuario activo que coincida con la audiencia
/// objetivo.
///
/// Cuando llegue Firebase, esto se hace del lado servidor con una
/// Cloud Function — pero el contrato del use case se mantiene.
class PublishEvent {
  PublishEvent(this._events, this._notifications);

  final EventsRepository _events;
  final NotificationsRepository _notifications;

  /// Crea un evento nuevo y notifica a la audiencia. Devuelve el id
  /// generado.
  Future<String> create(Event draft) async {
    final id = await _events.createEvent(draft);
    final created = draft.copyWith(id: id);
    await _notifyAudience(created);
    return id;
  }

  /// Actualiza un evento existente. NO re-notifica para evitar spam;
  /// si el admin quiere reanunciar, debería crear uno nuevo.
  Future<void> update(Event event) {
    return _events.updateEvent(event);
  }

  Future<void> archive(String id, {bool archived = true}) {
    return _events.archiveEvent(id, archived: archived);
  }

  Future<void> delete(String id) {
    return _events.deleteEvent(id);
  }

  // ─── helpers ──────────────────────────────────────────────────────

  Future<void> _notifyAudience(Event event) async {
    final recipients = _resolveRecipients(event.targetAudience);
    final body = _bodyFor(event);
    for (final user in recipients) {
      await _notifications.createNotification(
        AppNotification(
          id: '',
          userId: user.uid,
          type: NotificationType.eventPublished,
          title: event.title,
          body: body,
          createdAt: DateTime.now(),
          isRead: false,
          deepLink: '/events/detail/${event.id}',
        ),
      );
    }
  }

  List<AppUser> _resolveRecipients(TargetAudience audience) {
    final actives =
        MockUsers.all.where((u) => u.status == UserStatus.active).toList();
    switch (audience) {
      case TargetAudience.all:
        return actives.where((u) => u.role.isMobileUser).toList();
      case TargetAudience.teachers:
        return actives.where((u) => u.role == UserRole.teacher).toList();
      case TargetAudience.parents:
        return actives.where((u) => u.role == UserRole.parent).toList();
    }
  }

  static String _bodyFor(Event event) {
    final loc = event.location.trim().isEmpty ? '' : ' · ${event.location}';
    return 'Nuevo evento publicado por la administración$loc. Toca para ver los detalles.';
  }
}
