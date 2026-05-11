import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';
import 'package:agenda_escolar_adventista/features/notifications/presentation/widgets/notification_x.dart';

/// Card del listado de notificaciones in-app.
///
/// Visualmente:
/// ```
/// ┌────────────────────────────────────┐
/// │ ●  [icono]  Título                 │
/// │             Cuerpo en 2 líneas...  │
/// │             hace 2 h               │
/// └────────────────────────────────────┘
/// ```
/// El punto `●` a la izquierda solo aparece cuando la notificación no
/// está leída.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final type = notification.type;
    final unread = !notification.isRead;

    return Container(
      decoration: BoxDecoration(
        color: unread ? AppColors.surface : AppColors.surfaceMuted,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: unread
              ? type.color.withValues(alpha: 0.20)
              : AppColors.border,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador de no leída
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: unread ? type.color : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderBase,
                  ),
                  child: Icon(type.icon, size: 20, color: type.color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.body,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: AppTextStyles.metadata,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatTimestamp(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inMinutes < 1) return 'Hace un instante';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    final formatted = DateFormat("d 'de' MMMM", 'es_PE').format(when);
    return formatted;
  }
}
