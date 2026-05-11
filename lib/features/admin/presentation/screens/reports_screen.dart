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
import 'package:agenda_escolar_adventista/features/admin/presentation/providers/reports_providers.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/widgets/donut_chart.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/widgets/horizontal_bar_row.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_x.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_category_x.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedReportPeriodProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            period: period,
            onSelect: (p) =>
                ref.read(selectedReportPeriodProvider.notifier).state = p,
            onBack: () => _handleBack(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SummarySection()
                      .animate()
                      .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.04, end: 0),
                  const SizedBox(height: AppSpacing.xxl),
                  const _AttendanceSection()
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.04, end: 0),
                  const SizedBox(height: AppSpacing.xxl),
                  const _DocumentsSection()
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.04, end: 0),
                  const SizedBox(height: AppSpacing.xxl),
                  const _EventsSection()
                      .animate(delay: 180.ms)
                      .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.04, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.adminHome);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HEADER + SELECTOR DE PERÍODO
// ─────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.period,
    required this.onSelect,
    required this.onBack,
  });

  final ReportPeriod period;
  final ValueChanged<ReportPeriod> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  label: 'Volver',
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onBack,
                      borderRadius: AppRadius.borderBase,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Icon(
                          PhosphorIcons.arrowLeft(),
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Reportes',
                    style: AppTextStyles.h2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xxxxl,
                top: 2,
              ),
              child: Text(
                'Asistencia, documentos y eventos por período',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            _PeriodSegment(selected: period, onSelect: onSelect),
          ],
        ),
      ),
    );
  }
}

class _PeriodSegment extends StatelessWidget {
  const _PeriodSegment({required this.selected, required this.onSelect});

  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        children: ReportPeriod.values.map((period) {
          final isActive = period == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.surface : Colors.transparent,
                  borderRadius: AppRadius.borderFull,
                  border: isActive
                      ? Border.all(color: AppColors.border, width: 0.5)
                      : null,
                ),
                child: Text(
                  period.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SECCIÓN: RESUMEN
// ─────────────────────────────────────────────────────────────────────────

class _SummarySection extends ConsumerWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(reportSummaryProvider);
    final attendancePercent = (summary.attendanceAverage * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Resumen'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: PhosphorIcons.fingerprint(),
                color: AppColors.success,
                value: '$attendancePercent%',
                label: 'Asistencia promedio',
                hint: 'docentes',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                icon: PhosphorIcons.fileText(),
                color: AppColors.primary,
                value: '${summary.documentsTotal}',
                label: 'Documentos',
                hint: '${summary.documentsApproved} aprobados',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _StatCard(
          icon: PhosphorIcons.calendar(),
          color: AppColors.accent,
          value: '${summary.eventsTotal}',
          label: 'Eventos del período',
          hint: '${summary.eventsActive} activos',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.hint,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
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

// ─────────────────────────────────────────────────────────────────────────
// SECCIÓN: ASISTENCIA DOCENTE
// ─────────────────────────────────────────────────────────────────────────

class _AttendanceSection extends ConsumerWidget {
  const _AttendanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(attendanceReportProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Asistencia docente'),
        const SizedBox(height: AppSpacing.xs),
        Text(
          report.totalWorkableDays == 0
              ? 'Sin días laborables aún en este período.'
              : '${report.totalWorkableDays} días laborables · ${report.totalAttendances} asistencias · ${report.totalLate} tarde',
          style: AppTextStyles.metadata,
        ),
        const SizedBox(height: AppSpacing.md),
        if (report.stats.isEmpty)
          const _EmptyCard(message: 'No hay docentes activos.')
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                for (final stat in report.stats)
                  HorizontalBarRow(
                    label: stat.teacher.displayName,
                    subtitle:
                        '${stat.attendedDays}/${stat.workableDays} días${stat.lateCount > 0 ? ' · ${stat.lateCount} tarde' : ''}',
                    value: '${stat.attendancePercent}%',
                    fraction: stat.attendanceRate,
                    color: _attendanceColor(stat.attendanceRate),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static Color _attendanceColor(double rate) {
    if (rate >= 0.9) return AppColors.success;
    if (rate >= 0.7) return AppColors.warning;
    return AppColors.error;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SECCIÓN: DOCUMENTOS POR ESTADO (DONUT)
// ─────────────────────────────────────────────────────────────────────────

class _DocumentsSection extends ConsumerWidget {
  const _DocumentsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(documentsReportProvider);
    final slices = DocumentStatus.values
        .map(
          (status) => DonutSlice(
            label: status.displayName,
            value: (report.totalsByStatus[status] ?? 0).toDouble(),
            color: status.color,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Documentos por estado'),
        const SizedBox(height: AppSpacing.xs),
        Text(
          report.total == 0
              ? 'Sin documentos en este período.'
              : '${report.total} documentos recibidos',
          style: AppTextStyles.metadata,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: [
              Center(
                child: DonutChart(
                  slices: slices,
                  centerLabel: '${report.total}',
                  centerSubtitle: 'documentos',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              DonutLegend(slices: slices),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SECCIÓN: EVENTOS POR CATEGORÍA
// ─────────────────────────────────────────────────────────────────────────

class _EventsSection extends ConsumerWidget {
  const _EventsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(eventsReportProvider);
    // Para que la barra refleje "qué tan dominante" es esa categoría,
    // dividimos por el máximo de la lista (no por el total).
    final maxValue =
        report.totalsByCategory.values.fold<int>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Eventos por categoría'),
        const SizedBox(height: AppSpacing.xs),
        Text(
          report.total == 0
              ? 'Sin eventos en este período.'
              : '${report.totalActive} activos · ${report.totalArchived} archivados',
          style: AppTextStyles.metadata,
        ),
        const SizedBox(height: AppSpacing.md),
        if (report.total == 0)
          const _EmptyCard(
            message: 'Cuando publiques eventos, aparecerán aquí.',
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                for (final category in EventCategory.values)
                  HorizontalBarRow(
                    label: category.displayName,
                    value: '${report.totalsByCategory[category] ?? 0}',
                    fraction: maxValue == 0
                        ? 0
                        : (report.totalsByCategory[category] ?? 0) /
                            maxValue,
                    color: category.color,
                    leading: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Icon(
                        category.icon,
                        size: 16,
                        color: category.color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.h4);
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderBase,
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.info(),
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
