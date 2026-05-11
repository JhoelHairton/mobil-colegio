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
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/core/widgets/secondary_button.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';
import 'package:agenda_escolar_adventista/features/attendance/presentation/providers/attendance_providers.dart';

class AttendanceSuccessScreen extends ConsumerWidget {
  const AttendanceSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(todaysAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            children: [
              const Spacer(),
              const _AnimatedCheck(),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                '¡Asistencia registrada!',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              )
                  .animate(delay: 250.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSpacing.sm),
              Text(
                attendance == null
                    ? 'Tu entrada quedó registrada correctamente.'
                    : 'Tu entrada quedó registrada correctamente a las ${DateFormat('HH:mm').format(attendance.checkInTime)}.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 350.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSpacing.xl),
              if (attendance != null)
                _SummaryCard(attendance: attendance)
                    .animate(delay: 450.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
              const Spacer(),
              PrimaryButton(
                label: 'Volver al inicio',
                icon: PhosphorIcons.house(),
                onPressed: () => context.go(AppRoutes.teacherHome),
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: 'Ver mi historial',
                onPressed: () => context.go(AppRoutes.attendanceHistory),
              )
                  .animate(delay: 700.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// CHECK ANIMADO
// ─────────────────────────────────────────────────────────────────────────

class _AnimatedCheck extends StatelessWidget {
  const _AnimatedCheck();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Halo expansivo
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.4, 0.4),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: 300.ms),
        // Disco principal
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: AppColors.successSoft,
            shape: BoxShape.circle,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
              delay: 80.ms,
              duration: 450.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 250.ms),
        // Check
        Icon(
          PhosphorIcons.check(PhosphorIconsStyle.bold),
          size: 64,
          color: AppColors.success,
        )
            .animate()
            .scale(
              begin: const Offset(0.4, 0.4),
              end: const Offset(1, 1),
              delay: 200.ms,
              duration: 500.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(delay: 180.ms, duration: 240.ms),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// CARD DE RESUMEN
// ─────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.attendance});

  final Attendance attendance;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat("EEEE d 'de' MMMM", 'es_PE')
        .format(attendance.checkInTime);
    final dateLabelCap = dateLabel.isEmpty
        ? dateLabel
        : '${dateLabel[0].toUpperCase()}${dateLabel.substring(1)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          _Row(
            icon: PhosphorIcons.calendarBlank(),
            label: 'Fecha',
            value: dateLabelCap,
          ),
          const _Divider(),
          _Row(
            icon: PhosphorIcons.clock(),
            label: 'Hora de entrada',
            value: DateFormat('HH:mm').format(attendance.checkInTime),
          ),
          const _Divider(),
          _Row(
            icon: attendance.method == AttendanceMethod.qr
                ? PhosphorIcons.qrCode()
                : PhosphorIcons.cursorClick(),
            label: 'Método',
            value: attendance.method == AttendanceMethod.qr
                ? 'Escaneo QR'
                : 'Registro manual',
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      child: Row(
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
                  style: AppTextStyles.metadata
                      .copyWith(color: AppColors.textTertiary),
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.divider,
    );
  }
}
