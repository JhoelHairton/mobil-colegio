import 'dart:async';

import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_notifications.dart';

/// Datasource en memoria para notificaciones.
///
/// Mantiene una copia mutable de [MockNotifications.all] y un
/// [StreamController.broadcast] por usuario para emitir cambios cuando
/// se marcan como leídas o se eliminan.
class NotificationsMockDataSource {
  NotificationsMockDataSource() {
    _items = [...MockNotifications.all];
  }

  late final List<AppNotification> _items;
  final Map<String, StreamController<List<AppNotification>>> _controllers = {};

  static const Duration _initialLatency = Duration(milliseconds: 450);
  static const Duration _shortLatency = Duration(milliseconds: 150);

  Stream<List<AppNotification>> watchMyNotifications(String userId) {
    final controller = _controllers.putIfAbsent(
      userId,
      StreamController<List<AppNotification>>.broadcast,
    );

    Future<void>.delayed(_initialLatency, () {
      if (!controller.isClosed) controller.add(_forUser(userId));
    });

    return controller.stream;
  }

  Future<void> markAsRead(String notificationId) async {
    await Future<void>.delayed(_shortLatency);
    final index = _items.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    final updated = _items[index].copyWith(isRead: true);
    _items[index] = updated;
    _emit(updated.userId);
  }

  Future<void> markAllAsRead(String userId) async {
    await Future<void>.delayed(_shortLatency);
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.userId == userId && !item.isRead) {
        _items[i] = item.copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) _emit(userId);
  }

  Future<void> deleteNotification(String notificationId) async {
    await Future<void>.delayed(_shortLatency);
    final index = _items.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    final removed = _items.removeAt(index);
    _emit(removed.userId);
  }

  Future<AppNotification> createNotification(AppNotification notification) async {
    await Future<void>.delayed(_shortLatency);
    // Si llega sin id (caller lo dejó vacío), generamos uno único.
    final withId = notification.id.isEmpty
        ? notification.copyWith(
            id: 'ntf_${DateTime.now().millisecondsSinceEpoch}',
          )
        : notification;
    _items.add(withId);
    _emit(withId.userId);
    return withId;
  }

  // ─────────────────────── helpers ───────────────────────

  List<AppNotification> _forUser(String userId) {
    return _items.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _emit(String userId) {
    final controller = _controllers[userId];
    if (controller != null && !controller.isClosed) {
      controller.add(_forUser(userId));
    }
  }
}
