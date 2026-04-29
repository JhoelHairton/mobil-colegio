import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/widgets/floating_bottom_nav.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';

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

class _UpcomingEvents extends StatelessWidget {
  const _UpcomingEvents();

  @override
  Widget build(BuildContext context) {
    // Mock corto inline. Sprint 3 lo reemplaza con MockEvents centralizado.
    final events = [
      (
        title: 'Feria cultural adventista',
        when: 'Mañana · 09:00',
        accent: AppColors.categoryCultural,
        icon: PhosphorIcons.musicNotes(PhosphorIconsStyle.duotone),
      ),
      (
        title: 'Examen de matemática',
        when: 'Lun 4 · 08:00',
        accent: AppColors.categoryAcademic,
        icon: PhosphorIcons.exam(PhosphorIconsStyle.duotone),
      ),
      (
        title: 'Culto juvenil',
        when: 'Vie 8 · 19:00',
        accent: AppColors.categorySpiritual,
        icon: PhosphorIcons.bookOpen(PhosphorIconsStyle.duotone),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          for (var i = 0; i < events.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _EventTile(
                title: events[i].title,
                when: events[i].when,
                accent: events[i].accent,
                icon: events[i].icon,
              )
                  .animate(delay: (i * 60).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
            ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.title,
    required this.when,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String when;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderBase,
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(when, style: AppTextStyles.metadata),
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
    );
  }
}
