import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/widgets/floating_bottom_nav.dart';
import 'package:agenda_escolar_adventista/core/widgets/skeleton_loader.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/providers/events_providers.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_category_x.dart';

/// Home del rol [UserRole.student].
///
/// Mock data por ahora. Sprint 3 conecta a `MockEvents`.
class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.displayName.split(' ').first ?? 'estudiante';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              _Header(firstName: firstName, classroomCode: user?.classroomCode),
              const SizedBox(height: AppSpacing.xxl),
              _SectionLabel(label: 'Tus accesos'),
              const SizedBox(height: AppSpacing.base),
              const _QuickAccessGrid(),
              const SizedBox(height: AppSpacing.xxl),
              _SectionLabel(label: 'Próximos eventos'),
              const SizedBox(height: AppSpacing.base),
              const _UpcomingEvents(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingBottomNav(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
              items: [
                FloatingNavItem(
                  icon: PhosphorIcons.house(),
                  activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                  label: 'Inicio',
                ),
                FloatingNavItem(
                  icon: PhosphorIcons.calendar(),
                  activeIcon: PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                  label: 'Eventos',
                ),
                FloatingNavItem(
                  icon: PhosphorIcons.bell(),
                  activeIcon: PhosphorIcons.bell(PhosphorIconsStyle.fill),
                  label: 'Avisos',
                ),
                FloatingNavItem(
                  icon: PhosphorIcons.user(),
                  activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.firstName, this.classroomCode});

  final String firstName;
  final String? classroomCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.base,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      PhosphorIcons.bell(),
                      color: Colors.white,
                    ),
                    onPressed: () => context.push(AppRoutes.notifications),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Hola, $firstName',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Bienvenido al colegio',
                style: AppTextStyles.h1.copyWith(color: Colors.white),
              )
                  .animate(delay: 80.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.1, end: 0),
              if (classroomCode != null) ...[
                const SizedBox(height: AppSpacing.base),
                _ClassroomBadge(code: classroomCode!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassroomBadge extends StatelessWidget {
  const _ClassroomBadge({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.graduationCap(),
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            code,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate(delay: 160.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────
// CONTENIDO
// ─────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Text(
        label,
        style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: PhosphorIcons.calendar(PhosphorIconsStyle.duotone),
        color: AppColors.categorySpiritual,
        label: 'Mis eventos',
        route: AppRoutes.eventsList,
      ),
      (
        icon: PhosphorIcons.bookOpen(PhosphorIconsStyle.duotone),
        color: AppColors.categoryAcademic,
        label: 'Materias',
        route: null,
      ),
      (
        icon: PhosphorIcons.megaphone(PhosphorIconsStyle.duotone),
        color: AppColors.categoryCampaign,
        label: 'Avisos',
        route: AppRoutes.notifications,
      ),
      (
        icon: PhosphorIcons.userCircle(PhosphorIconsStyle.duotone),
        color: AppColors.accent,
        label: 'Mi perfil',
        route: null,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.6,
        children: [
          for (var i = 0; i < items.length; i++)
            _QuickTile(
              icon: items[i].icon,
              color: items[i].color,
              label: items[i].label,
              onTap: items[i].route == null
                  ? null
                  : () => context.push(items[i].route!),
            )
                .animate(delay: (i * 70).ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderBase,
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              Text(
                label,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingEvents extends ConsumerWidget {
  const _UpcomingEvents();

  static const int _maxItems = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(eventsStreamProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: asyncEvents.when(
        loading: () => Column(
          children: List.generate(
            _maxItems,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: SkeletonCard(),
            ),
          ),
        ),
        error: (_, __) => _EventsMessage(
          icon: PhosphorIcons.warningCircle(),
          message: 'No pudimos cargar los eventos.',
        ),
        data: (events) {
          final upcoming = _filterUpcomingForStudent(events).take(_maxItems).toList();
          if (upcoming.isEmpty) {
            return _EventsMessage(
              icon: PhosphorIcons.calendarCheck(),
              message: 'No hay eventos próximos por ahora.',
            );
          }
          return Column(
            children: [
              for (var i = 0; i < upcoming.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _EventTile(event: upcoming[i])
                      .animate(delay: (i * 60).ms)
                      .fadeIn(duration: 350.ms)
                      .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final cat = event.category;
    final whenLabel = _formatWhen(event.startDate);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        borderRadius: AppRadius.borderMd,
        onTap: () => context.push('${AppRoutes.eventDetail}/${event.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderBase,
                ),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,  
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      whenLabel,
                      style: AppTextStyles.metadata,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(),
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatWhen(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayOf = DateTime(d.year, d.month, d.day);
    final diff = dayOf.difference(today).inDays;

    final time = DateFormat('HH:mm').format(d);
    if (diff == 0) return 'Hoy · $time';
    if (diff == 1) return 'Mañana · $time';
    if (diff > 1 && diff < 7) {
      final dayName = DateFormat('EEEE', 'es_PE').format(d);
      final capitalized = dayName.isEmpty
          ? dayName
          : '${dayName[0].toUpperCase()}${dayName.substring(1)}';
      return '$capitalized · $time';
    }
    final dateStr = DateFormat("d 'de' MMMM", 'es_PE').format(d);
    return '$dateStr · $time';
  }
}

class _EventsMessage extends StatelessWidget {
  const _EventsMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderBase,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filtra eventos visibles para un estudiante. Sólo se muestran los
/// dirigidos a [TargetAudience.all] (no incluye eventos exclusivos para
/// docentes o padres) y que aún no han terminado.
List<Event> _filterUpcomingForStudent(List<Event> events) {
  final list = events.where((e) {
    if (e.isPast) return false;
    return e.targetAudience == TargetAudience.all;
  }).toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
  return list;
}
