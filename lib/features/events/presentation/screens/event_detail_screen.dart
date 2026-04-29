import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/widgets/empty_state.dart';
import 'package:agenda_escolar_adventista/core/widgets/error_view.dart';
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/providers/events_providers.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_category_x.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: ErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(eventByIdProvider(eventId)),
          ),
        ),
        data: (event) {
          if (event == null) {
            return _NotFound(onBack: () => Navigator.of(context).maybePop());
          }
          return _EventDetail(event: event);
        },
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: EmptyState(
        icon: PhosphorIcons.calendarX(),
        title: 'No encontramos este evento',
        subtitle: 'Es posible que haya sido archivado o eliminado por la administración.',
        actionLabel: 'Volver',
        onAction: onBack,
      ),
    );
  }
}

class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _HeroSliver(event: event),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.xl,
                  AppSpacing.screenHorizontal,
                  // Espacio extra para no chocar con la barra de acciones inferior.
                  AppSpacing.xxxxl + AppSpacing.lg,
                ),
                child: _EventBody(event: event),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _ActionBar(event: event),
        ),
      ],
    );
  }
}

/// Hero superior con SliverAppBar collapsable. Muestra el icono de
/// categoría grande sobre un gradiente del color de la misma.
class _HeroSliver extends StatelessWidget {
  const _HeroSliver({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final cat = event.category;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: _CircleIconButton(
          icon: PhosphorIcons.arrowLeft(),
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: _CircleIconButton(
            icon: PhosphorIcons.shareNetwork(),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compartir disponible próximamente'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        background: Hero(
          tag: 'event-hero-${event.id}',
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cat.color.withValues(alpha: 0.32),
                  cat.color.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Icon(
                    cat.icon,
                    size: 120,
                    color: cat.color.withValues(alpha: 0.85),
                  ).animate().fadeIn(duration: 500.ms).scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutCubic,
                        duration: 500.ms,
                      ),
                ),
                Positioned(
                  left: AppSpacing.screenHorizontal,
                  bottom: AppSpacing.lg,
                  child: _CategoryPill(label: cat.displayName, color: cat.color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventBody extends StatelessWidget {
  const _EventBody({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Text(event.title, style: AppTextStyles.h1),
      const SizedBox(height: AppSpacing.md),
      _StatusLine(event: event),
      const SizedBox(height: AppSpacing.xl),
      _InfoCard(event: event),
      const SizedBox(height: AppSpacing.xl),
      Text(
        'Descripción',
        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        event.description,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      ),
      const SizedBox(height: AppSpacing.xl),
      _AudienceBadge(audience: event.targetAudience),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++)
          children[i]
              .animate(delay: (i * 50).ms)
              .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _label();
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.borderFull,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  (String, Color) _label() {
    if (event.isOngoing) return ('En curso ahora', AppColors.success);
    if (event.isPast) return ('Finalizado', AppColors.textSecondary);
    final daysLeft = event.startDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return ('Hoy', AppColors.accent);
    if (daysLeft == 1) return ('Mañana', AppColors.accent);
    if (daysLeft <= 7) return ('Esta semana', AppColors.accent);
    return ('Próximo', AppColors.primary);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat("EEEE d 'de' MMMM", 'es_PE')
        .format(event.startDate);
    final dateLabelCapitalized = dateLabel.isEmpty
        ? dateLabel
        : '${dateLabel[0].toUpperCase()}${dateLabel.substring(1)}';
    final timeLabel = _timeRange(event.startDate, event.endDate);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: PhosphorIcons.calendarBlank(),
            label: 'Fecha',
            value: dateLabelCapitalized,
          ),
          const _InfoDivider(),
          _InfoRow(
            icon: PhosphorIcons.clock(),
            label: 'Horario',
            value: timeLabel,
          ),
          const _InfoDivider(),
          _InfoRow(
            icon: PhosphorIcons.mapPin(),
            label: 'Ubicación',
            value: event.location,
          ),
        ],
      ),
    );
  }

  String _timeRange(DateTime start, DateTime end) {
    final fmt = DateFormat('HH:mm');
    final sameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    if (sameDay) {
      return '${fmt.format(start)} – ${fmt.format(end)}';
    }
    final dateFmt = DateFormat('d MMM HH:mm', 'es_PE');
    return '${dateFmt.format(start)} – ${dateFmt.format(end)}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadius.borderBase,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.metadata.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.divider,
    );
  }
}

class _AudienceBadge extends StatelessWidget {
  const _AudienceBadge({required this.audience});

  final TargetAudience audience;

  @override
  Widget build(BuildContext context) {
    final icon = switch (audience) {
      TargetAudience.all => PhosphorIcons.usersThree(),
      TargetAudience.teachers => PhosphorIcons.chalkboardTeacher(),
      TargetAudience.parents => PhosphorIcons.usersFour(),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            audience.displayName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final disabled = event.isPast;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            AppSpacing.md,
          ),
          child: PrimaryButton(
            label: disabled ? 'Evento finalizado' : 'Agregar al calendario',
            icon: PhosphorIcons.calendarPlus(),
            onPressed: disabled
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Listo. El evento se agregará a tu calendario cuando conectemos el backend.',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
          ),
        ),
      ),
    );
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
