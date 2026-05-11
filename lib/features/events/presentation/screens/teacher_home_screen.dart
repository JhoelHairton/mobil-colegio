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
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.displayName.split(' ').first ?? 'Profesor';
    final now = DateTime.now();
    final timeFormatted = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              // Bottom padding holgado para que la barra flotante no tape
              // el contenido al hacer scroll completo.
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxxxl + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(firstName),
                  const SizedBox(height: AppSpacing.xl),
                  _buildAttendanceCard(timeFormatted),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildWeekSummary(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildFloatingBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, prof. $name',
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
        GestureDetector(
          onTap: () => context.push(AppRoutes.notifications),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(String time) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: AppRadius.borderXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: AppTextStyles.display.copyWith(
              color: Colors.white,
              fontSize: 48,
            ),
          ),
          Text(
            _capitalize(
              DateFormat("EEEE d 'de' MMMM", 'es_PE').format(DateTime.now()),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          _buildStatusChip(
            'Entrada registrada',
            PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
            AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.qrScan),
                  icon: Icon(PhosphorIcons.qrCode(), size: 18),
                  label: const Text('Escanear QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderBase,
                    ),
                    textStyle: AppTextStyles.buttonRegular,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.mapPin(), size: 18),
                  label: const Text('Ubicación'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderBase,
                    ),
                    textStyle: AppTextStyles.buttonRegular,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.05,
          end: 0,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSummary() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Esta semana', style: AppTextStyles.h4),
              TextButton(
                onPressed: () => context.push(AppRoutes.attendanceHistory),
                child: Text(
                  'Ver detalles',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(6, (i) {
              const days = ['L', 'M', 'X', 'J', 'V', 'S'];
              final isToday = i == 5;
              final isCompleted = i < 5;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary
                          : isCompleted
                              ? AppColors.successSoft
                              : AppColors.divider,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              PhosphorIcons.check(PhosphorIconsStyle.bold),
                              size: 16,
                              color: AppColors.success,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    days[i],
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isToday ? AppColors.primary : null,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNav() {
    return FloatingBottomNav(
      currentIndex: _currentIndex,
      onTap: (i) {
        setState(() => _currentIndex = i);
        switch (i) {
          case 1:
            context.push(AppRoutes.qrScan);
          case 2:
            context.push(AppRoutes.eventsList);
          case 3:
            context.push(AppRoutes.notifications);
        }
      },
      items: [
        FloatingNavItem(
          icon: PhosphorIcons.house(),
          activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
          label: 'Inicio',
        ),
        FloatingNavItem(
          icon: PhosphorIcons.fingerprint(),
          activeIcon: PhosphorIcons.fingerprint(PhosphorIconsStyle.fill),
          label: 'Asistencia',
        ),
        FloatingNavItem(
          icon: PhosphorIcons.calendar(),
          activeIcon: PhosphorIcons.calendar(PhosphorIconsStyle.fill),
          label: 'Eventos',
        ),
        FloatingNavItem(
          icon: PhosphorIcons.user(),
          activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
          label: 'Perfil',
        ),
      ],
    );
  }

  static String _capitalize(String input) {
    if (input.isEmpty) return input;
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }
}
