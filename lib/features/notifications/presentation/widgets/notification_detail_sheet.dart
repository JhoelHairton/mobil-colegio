import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';
import 'package:agenda_escolar_adventista/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:agenda_escolar_adventista/features/notifications/presentation/widgets/notification_x.dart';

/// Bottom sheet con el detalle completo de una notificación.
///
/// Marca como leída al abrirse (si aún no lo estaba) y ofrece dos
/// acciones: navegar al deepLink (si existe) y eliminar.
Future<void> showNotificationDetailSheet({
  required BuildContext context,
  required AppNotification notification,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => NotificationDetailSheet(notification: notification),
  );
}

class NotificationDetailSheet extends ConsumerStatefulWidget {
  const NotificationDetailSheet({super.key, required this.notification});

  final AppNotification notification;

  @override
  ConsumerState<NotificationDetailSheet> createState() =>
      _NotificationDetailSheetState();
}

class _NotificationDetailSheetState
    extends ConsumerState<NotificationDetailSheet> {
  @override
  void initState() {
    super.initState();
    // Marca como leída al abrir el sheet (sin esperar — se hace en
    // background). Si ya estaba leída es un no-op.
    if (!widget.notification.isRead) {
      Future<void>.microtask(() {
        ref
            .read(markNotificationAsReadUseCaseProvider)
            .call(widget.notification.id);
      });
    }
  }

  Future<void> _handleSeeMore() async {
    final link = widget.notification.deepLink;
    if (link == null || link.isEmpty) return;
    final navigator = Navigator.of(context);
    navigator.pop(); // cerramos el sheet
    if (!mounted) return;
    context.push(link);
  }

  Future<void> _handleDelete() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref
        .read(deleteNotificationUseCaseProvider)
        .call(widget.notification.id);
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Notificación eliminada'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final type = notification.type;
    final hasLink =
        notification.deepLink != null && notification.deepLink!.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: AppRadius.borderFull,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Icono grande de tipo
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderLg,
                ),
                child: Icon(type.icon, size: 36, color: type.color),
              )
                  .animate()
                  .fadeIn(duration: 250.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutCubic,
                    duration: 300.ms,
                  ),
              const SizedBox(height: AppSpacing.lg),
              _TypeChip(type: type),
              const SizedBox(height: AppSpacing.md),
              Text(
                notification.title,
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                notification.body,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TimeRow(when: notification.createdAt),
              const SizedBox(height: AppSpacing.xl),
              if (hasLink)
                _ActionButton(
                  icon: PhosphorIcons.arrowRight(),
                  label: _seeMoreLabel(type),
                  isPrimary: true,
                  onTap: _handleSeeMore,
                ),
              if (hasLink) const SizedBox(height: AppSpacing.sm),
              _ActionButton(
                icon: PhosphorIcons.trash(),
                label: 'Eliminar',
                isPrimary: false,
                isDestructive: true,
                onTap: _handleDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _seeMoreLabel(NotificationType type) {
    switch (type) {
      case NotificationType.eventPublished:
        return 'Ver evento';
      case NotificationType.documentApproved:
      case NotificationType.documentRejected:
      case NotificationType.documentReviewing:
        return 'Ver mis documentos';
      case NotificationType.attendanceReminder:
        return 'Escanear QR';
      case NotificationType.generalAnnouncement:
        return 'Ver más';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SUBWIDGETS
// ─────────────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        _label(type),
        style: AppTextStyles.metadata.copyWith(
          color: type.color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static String _label(NotificationType type) {
    switch (type) {
      case NotificationType.eventPublished:
        return 'EVENTO';
      case NotificationType.documentApproved:
        return 'DOCUMENTO APROBADO';
      case NotificationType.documentRejected:
        return 'DOCUMENTO RECHAZADO';
      case NotificationType.documentReviewing:
        return 'DOCUMENTO EN REVISIÓN';
      case NotificationType.attendanceReminder:
        return 'ASISTENCIA';
      case NotificationType.generalAnnouncement:
        return 'AVISO';
    }
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.when});

  final DateTime when;

  @override
  Widget build(BuildContext context) {
    final relative = _relative(when);
    final absolute = _absolute(when);
    return Row(
      children: [
        Icon(
          PhosphorIcons.clock(),
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.xs + 2),
        Text(
          '$relative · $absolute',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  static String _relative(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inMinutes < 1) return 'Hace un instante';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return DateFormat("d 'de' MMMM", 'es_PE').format(when);
  }

  static String _absolute(DateTime when) {
    return DateFormat('d MMM, HH:mm', 'es_PE').format(when);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final foreground = isDestructive
        ? AppColors.error
        : (isPrimary ? Colors.white : AppColors.primary);
    final background = isDestructive
        ? AppColors.errorSoft
        : (isPrimary ? AppColors.primary : AppColors.surface);
    final border = isDestructive
        ? AppColors.error.withValues(alpha: 0.20)
        : (isPrimary ? AppColors.primary : AppColors.border);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: background,
        borderRadius: AppRadius.borderBase,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderBase,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderBase,
              border: Border.all(color: border, width: isPrimary ? 0 : 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTextStyles.buttonRegular.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
