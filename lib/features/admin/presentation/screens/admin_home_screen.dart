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
import 'package:agenda_escolar_adventista/features/admin/presentation/providers/admin_providers.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.displayName.split(' ').first ?? 'admin';
    final isSecretary = user?.role == UserRole.secretary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(firstName: firstName, isSecretary: isSecretary),
              const SizedBox(height: AppSpacing.xl),
              const _PendingHero(),
              const SizedBox(height: AppSpacing.xxl),
              const _SectionLabel(label: 'Resumen de hoy'),
              const SizedBox(height: AppSpacing.md),
              const _KpiGrid(),
              const SizedBox(height: AppSpacing.xxl),
              const _SectionLabel(label: 'Acciones'),
              const SizedBox(height: AppSpacing.md),
              const _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.firstName, required this.isSecretary});

  final String firstName;
  final bool isSecretary;

  @override
  Widget build(BuildContext context) {
    final initial = firstName.isEmpty ? '?' : firstName[0].toUpperCase();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSecretary ? 'Hola, $firstName' : 'Bienvenido, $firstName',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _capitalize(
                  DateFormat("EEEE d 'de' MMMM", 'es_PE').format(DateTime.now()),
                ),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Text(
            initial,
            style: AppTextStyles.h4.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  static String _capitalize(String input) {
    if (input.isEmpty) return input;
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.h4);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HERO: pendientes de revisión (acción principal)
// ─────────────────────────────────────────────────────────────────────────

class _PendingHero extends ConsumerWidget {
  const _PendingHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(adminDocumentCountsByStatusProvider);
    final pending = counts[DocumentStatus.pending] ?? 0;
    final reviewing = counts[DocumentStatus.reviewing] ?? 0;
    final total = pending + reviewing;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.adminPendingDocuments),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          borderRadius: AppRadius.borderLg,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: AppRadius.borderBase,
                  ),
                  child: Icon(
                    PhosphorIcons.fileMagnifyingGlass(),
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Icon(
                  PhosphorIcons.arrowRight(),
                  size: 22,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              total == 0 ? 'Sin documentos pendientes' : '$total documentos',
              style: AppTextStyles.display.copyWith(
                color: Colors.white,
                fontSize: 40,
                height: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              total == 0
                  ? 'Estás al día. Cuando los padres suban algo nuevo, aparecerá aquí.'
                  : pending == 0
                      ? 'En revisión por la secretaría.'
                      : reviewing == 0
                          ? 'Esperan tu primera revisión.'
                          : '$pending por revisar · $reviewing en proceso.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// KPI GRID
// ─────────────────────────────────────────────────────────────────────────

class _KpiGrid extends ConsumerWidget {
  const _KpiGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUsers = ref.watch(totalActiveUsersProvider);
    final teachers = ref.watch(totalTeachersProvider);
    final attendancesAsync = ref.watch(attendancesTodayCountProvider);
    final activeEvents = ref.watch(activeEventsCountProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: PhosphorIcons.usersThree(),
                color: AppColors.primary,
                label: 'Usuarios activos',
                value: '$activeUsers',
                hint: '$teachers docentes',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _KpiCard(
                icon: PhosphorIcons.fingerprint(),
                color: AppColors.success,
                label: 'Asistencias hoy',
                value: attendancesAsync.when(
                  data: (n) => '$n',
                  loading: () => '—',
                  error: (_, __) => '—',
                ),
                hint: 'de $teachers docentes',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: PhosphorIcons.calendar(),
                color: AppColors.accent,
                label: 'Eventos activos',
                value: '$activeEvents',
                hint: 'no archivados',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _PendingDocsKpi(),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.hint,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w600),
          ),
          Text(hint, style: AppTextStyles.metadata),
        ],
      ),
    );
  }
}

class _PendingDocsKpi extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(adminDocumentCountsByStatusProvider);
    final pending = counts[DocumentStatus.pending] ?? 0;
    final reviewing = counts[DocumentStatus.reviewing] ?? 0;
    return _KpiCard(
      icon: PhosphorIcons.fileText(),
      color: AppColors.warning,
      label: 'Documentos pendientes',
      value: '${pending + reviewing}',
      hint: pending == 0 ? 'al día' : '$pending sin revisar',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS
// ─────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionTile(
          icon: PhosphorIcons.fileMagnifyingGlass(),
          title: 'Aprobar documentos',
          subtitle: 'Revisar membresías, descuentos y diezmos',
          color: AppColors.primary,
          onTap: () => context.push(AppRoutes.adminPendingDocuments),
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionTile(
          icon: PhosphorIcons.usersThree(),
          title: 'Gestionar usuarios',
          subtitle: 'Crear, suspender o regenerar códigos',
          color: AppColors.info,
          onTap: () => context.push(AppRoutes.adminUsers),
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionTile(
          icon: PhosphorIcons.calendarPlus(),
          title: 'Gestionar eventos',
          subtitle: 'Crear, editar y archivar para todos o por rol',
          color: AppColors.accent,
          onTap: () => context.push(AppRoutes.adminEvents),
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionTile(
          icon: PhosphorIcons.chartBar(),
          title: 'Reportes',
          subtitle: 'Asistencia, documentos, eventos',
          color: AppColors.categorySpiritual,
          onTap: () => context.push(AppRoutes.adminReports),
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionTile(
          icon: PhosphorIcons.fileXls(),
          title: 'Carga masiva (CSV)',
          subtitle: 'Importar usuarios desde una planilla',
          color: AppColors.categoryAcademic,
          onTap: () => context.push(AppRoutes.adminBulkImport),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        borderRadius: AppRadius.borderMd,
        onTap: onTap,
        child: Container(
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
}
