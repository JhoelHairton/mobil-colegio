import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_category_x.dart';

/// Card del listado de eventos.
///
/// Estructura visual:
/// ```
/// ┌─────────────────────────────────┐
/// │   [hero del color categoría]    │  ← 140px con icono grande
/// │  [badge categoría]              │
/// ├─────────────────────────────────┤
/// │  Título h3                       │
/// │  Subtítulo / metadata            │
/// │  📅 fecha · 📍 ubicación         │
/// └─────────────────────────────────┘
/// borderRadius lg (20), border 0.5px, sin sombra.
/// ```
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cat = event.category;
    final dateLabel = _formatDate(event.startDate);
    final timeLabel = _formatTime(event.startDate);
    final statusBadge = _statusBadge();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────── Hero visual ───────
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cat.color.withValues(alpha: 0.18),
                            cat.color.withValues(alpha: 0.06),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        cat.icon,
                        size: 56,
                        color: cat.color.withValues(alpha: 0.85),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: _CategoryPill(label: cat.displayName, color: cat.color),
                    ),
                    if (statusBadge != null)
                      Positioned(
                        top: AppSpacing.md,
                        right: AppSpacing.md,
                        child: statusBadge,
                      ),
                  ],
                ),
              ),
              // ─────── Texto ───────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.h3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      event.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MetadataRow(
                      icon: PhosphorIcons.calendarBlank(),
                      label: '$dateLabel · $timeLabel',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _MetadataRow(
                      icon: PhosphorIcons.mapPin(),
                      label: event.location,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _statusBadge() {
    if (event.isOngoing) {
      return const _StatusPill(
        label: 'En curso',
        color: AppColors.success,
        background: AppColors.successSoft,
      );
    }
    if (event.isPast) {
      return const _StatusPill(
        label: 'Finalizado',
        color: AppColors.textSecondary,
        background: AppColors.surfaceMuted,
      );
    }
    final daysLeft = event.startDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) {
      return const _StatusPill(
        label: 'Hoy',
        color: AppColors.accent,
        background: AppColors.accentSoft,
      );
    }
    if (daysLeft <= 3) {
      return _StatusPill(
        label: daysLeft == 1 ? 'Mañana' : 'En $daysLeft días',
        color: AppColors.accent,
        background: AppColors.accentSoft,
      );
    }
    return null;
  }

  static String _formatDate(DateTime d) {
    return DateFormat('d MMM', 'es_PE').format(d);
  }

  static String _formatTime(DateTime d) {
    return DateFormat('HH:mm').format(d);
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        label,
        style: AppTextStyles.metadata.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: color.withValues(alpha: 0.30), width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.metadata.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.xs + 2),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
