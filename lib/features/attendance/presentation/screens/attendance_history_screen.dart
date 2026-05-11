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
import 'package:agenda_escolar_adventista/core/widgets/modern_header.dart';
import 'package:agenda_escolar_adventista/core/widgets/skeleton_loader.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';
import 'package:agenda_escolar_adventista/features/attendance/presentation/providers/attendance_providers.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecords = ref.watch(myAttendanceStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ModernHeader(
            title: 'Mi asistencia',
            subtitle: asyncRecords.maybeWhen(
              data: _subtitleForRecords,
              orElse: () => 'Cargando historial…',
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                ref.invalidate(myAttendanceStreamProvider);
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: asyncRecords.when(
                loading: () => const _LoadingList(),
                error: (err, _) => _ScrollableSingle(
                  child: ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(myAttendanceStreamProvider),
                  ),
                ),
                data: (records) {
                  if (records.isEmpty) {
                    return _ScrollableSingle(
                      child: EmptyState(
                        icon: PhosphorIcons.fingerprint(),
                        title: 'Aún no registras asistencia',
                        subtitle:
                            'Cuando escanees el QR del día, aparecerá aquí tu historial completo.',
                      ),
                    );
                  }
                  return _GroupedHistory(records: records);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitleForRecords(List<Attendance> records) {
    if (records.isEmpty) return 'Sin registros aún';
    final now = DateTime.now();
    final thisMonth = records.where((a) {
      return a.checkInTime.year == now.year &&
          a.checkInTime.month == now.month;
    }).length;
    final late = records.where((a) {
      return a.checkInTime.year == now.year &&
          a.checkInTime.month == now.month &&
          a.isLate;
    }).length;
    final monthName = DateFormat('MMMM', 'es_PE').format(now);
    final monthCap = monthName.isEmpty
        ? monthName
        : '${monthName[0].toUpperCase()}${monthName.substring(1)}';
    if (late == 0) return '$monthCap · $thisMonth días asistidos';
    return '$monthCap · $thisMonth días asistidos · $late tarde';
  }
}

// ─────────────────────────────────────────────────────────────────────────
// LISTA AGRUPADA POR MES
// ─────────────────────────────────────────────────────────────────────────

class _GroupedHistory extends StatelessWidget {
  const _GroupedHistory({required this.records});

  final List<Attendance> records;

  @override
  Widget build(BuildContext context) {
    final groups = _groupByMonth(records);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      itemCount: groups.length,
      itemBuilder: (_, groupIndex) {
        final group = groups[groupIndex];
        return Padding(
          padding: EdgeInsets.only(
            bottom: groupIndex == groups.length - 1
                ? 0
                : AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MonthLabel(label: group.label, count: group.records.length),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < group.records.length; i++) ...[
                _AttendanceTile(attendance: group.records[i])
                    .animate(delay: (i * 40).ms)
                    .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                if (i != group.records.length - 1)
                  const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    );
  }

  static List<_MonthGroup> _groupByMonth(List<Attendance> records) {
    final map = <String, List<Attendance>>{};
    for (final a in records) {
      final key = '${a.checkInTime.year}-${a.checkInTime.month}';
      map.putIfAbsent(key, () => []).add(a);
    }
    final groups = <_MonthGroup>[];
    final keys = map.keys.toList()
      ..sort((a, b) {
        // ordenamos descendente por año-mes
        final pa = a.split('-').map(int.parse).toList();
        final pb = b.split('-').map(int.parse).toList();
        final ya = pa[0];
        final ma = pa[1];
        final yb = pb[0];
        final mb = pb[1];
        if (ya != yb) return yb.compareTo(ya);
        return mb.compareTo(ma);
      });
    for (final key in keys) {
      final list = map[key]!
        ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
      final first = list.first.checkInTime;
      final monthLabel = DateFormat("MMMM 'de' yyyy", 'es_PE').format(first);
      final cap = monthLabel.isEmpty
          ? monthLabel
          : '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)}';
      groups.add(_MonthGroup(label: cap, records: list));
    }
    return groups;
  }
}

class _MonthGroup {
  const _MonthGroup({required this.label, required this.records});
  final String label;
  final List<Attendance> records;
}

class _MonthLabel extends StatelessWidget {
  const _MonthLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.h4),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: 2,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: AppRadius.borderFull,
          ),
          child: Text(
            count == 1 ? '1 día' : '$count días',
            style: AppTextStyles.metadata.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.attendance});

  final Attendance attendance;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE d MMM', 'es_PE')
        .format(attendance.checkInTime);
    final dateLabelCap = dateLabel.isEmpty
        ? dateLabel
        : '${dateLabel[0].toUpperCase()}${dateLabel.substring(1)}';
    final time = DateFormat('HH:mm').format(attendance.checkInTime);
    final isLate = attendance.isLate;
    final color = isLate ? AppColors.warning : AppColors.success;
    final softColor = isLate ? AppColors.warningSoft : AppColors.successSoft;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderBase,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: softColor,
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(
              isLate
                  ? PhosphorIcons.warning()
                  : PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabelCap,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      attendance.method == AttendanceMethod.qr
                          ? PhosphorIcons.qrCode()
                          : PhosphorIcons.cursorClick(),
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attendance.method == AttendanceMethod.qr ? 'QR' : 'Manual',
                      style: AppTextStyles.metadata,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w700, color: color),
              ),
              if (isLate)
                Text(
                  'Tarde',
                  style: AppTextStyles.metadata.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// LOADING / EMPTY HELPERS
// ─────────────────────────────────────────────────────────────────────────

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}

class _ScrollableSingle extends StatelessWidget {
  const _ScrollableSingle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
