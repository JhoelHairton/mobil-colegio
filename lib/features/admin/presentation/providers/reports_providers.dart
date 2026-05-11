import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_attendance.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_documents.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_events.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

// ─────────────────────────────────────────────────────────────────────────
// PERIODO SELECCIONADO
// ─────────────────────────────────────────────────────────────────────────

/// Períodos disponibles en el reporte. La interpretación numérica vive
/// en [_resolveRange] para mantener un único punto de cambio.
enum ReportPeriod {
  thisMonth('Este mes'),
  lastMonth('Mes anterior'),
  thisYear('Este año');

  const ReportPeriod(this.displayName);
  final String displayName;
}

final selectedReportPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.thisMonth);

/// Rango temporal `[start, end)` resuelto a partir del período. La
/// fecha actual se inyecta como [now] sólo en tests; en la app va al
/// `DateTime.now()` por defecto.
({DateTime start, DateTime end}) _resolveRange(
  ReportPeriod period, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  switch (period) {
    case ReportPeriod.thisMonth:
      final start = DateTime(reference.year, reference.month);
      final end = DateTime(reference.year, reference.month + 1);
      return (start: start, end: end);
    case ReportPeriod.lastMonth:
      final start = DateTime(reference.year, reference.month - 1);
      final end = DateTime(reference.year, reference.month);
      return (start: start, end: end);
    case ReportPeriod.thisYear:
      final start = DateTime(reference.year);
      final end = DateTime(reference.year + 1);
      return (start: start, end: end);
  }
}

final reportRangeProvider = Provider<({DateTime start, DateTime end})>((ref) {
  final period = ref.watch(selectedReportPeriodProvider);
  return _resolveRange(period);
});

// ─────────────────────────────────────────────────────────────────────────
// ASISTENCIA DOCENTE
// ─────────────────────────────────────────────────────────────────────────

class TeacherAttendanceStat {
  const TeacherAttendanceStat({
    required this.teacher,
    required this.attendedDays,
    required this.workableDays,
    required this.lateCount,
  });

  final AppUser teacher;

  /// Días con registro de asistencia dentro del período.
  final int attendedDays;

  /// Días laborables del período (lunes a viernes hasta hoy si es el
  /// mes actual, o todo el mes si ya pasó).
  final int workableDays;

  /// Cuántas asistencias del período fueron tarde (>8:00 AM).
  final int lateCount;

  double get attendanceRate {
    if (workableDays == 0) return 0;
    return (attendedDays / workableDays).clamp(0.0, 1.0);
  }

  int get attendancePercent => (attendanceRate * 100).round();
}

class AttendanceReport {
  const AttendanceReport({
    required this.stats,
    required this.totalAttendances,
    required this.totalLate,
    required this.totalWorkableDays,
  });

  final List<TeacherAttendanceStat> stats;
  final int totalAttendances;
  final int totalLate;
  final int totalWorkableDays;

  /// Promedio del % de asistencia entre todos los docentes activos.
  double get averageRate {
    if (stats.isEmpty) return 0;
    final sum = stats.fold<double>(0, (acc, s) => acc + s.attendanceRate);
    return sum / stats.length;
  }
}

final attendanceReportProvider = Provider<AttendanceReport>((ref) {
  final range = ref.watch(reportRangeProvider);
  final now = DateTime.now();

  final teachers = MockUsers.all
      .where((u) => u.role == UserRole.teacher && u.status == UserStatus.active)
      .toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));

  // Para el mes actual, contamos sólo los días laborables transcurridos
  // hasta ayer (no contamos el día de hoy porque la jornada no terminó).
  final effectiveEnd = range.end.isAfter(now) ? now : range.end;
  final workableDays = _countWeekdays(range.start, effectiveEnd);

  final stats = <TeacherAttendanceStat>[];
  var totalAttendances = 0;
  var totalLate = 0;

  for (final teacher in teachers) {
    final records = MockAttendance.all.where((a) {
      if (a.teacherId != teacher.uid) return false;
      return !a.checkInTime.isBefore(range.start) &&
          a.checkInTime.isBefore(range.end);
    }).toList();

    final lateInPeriod = records.where((a) => a.isLate).length;
    totalAttendances += records.length;
    totalLate += lateInPeriod;

    stats.add(
      TeacherAttendanceStat(
        teacher: teacher,
        attendedDays: records.length,
        workableDays: workableDays,
        lateCount: lateInPeriod,
      ),
    );
  }

  // Orden descendente por % de asistencia para destacar los mejores.
  stats.sort((a, b) => b.attendanceRate.compareTo(a.attendanceRate));

  return AttendanceReport(
    stats: stats,
    totalAttendances: totalAttendances,
    totalLate: totalLate,
    totalWorkableDays: workableDays,
  );
});

/// Cuenta los días lun-vie en `[start, end)`.
int _countWeekdays(DateTime start, DateTime end) {
  if (!end.isAfter(start)) return 0;
  var count = 0;
  var cursor = DateTime(start.year, start.month, start.day);
  final stop = DateTime(end.year, end.month, end.day);
  while (cursor.isBefore(stop)) {
    if (cursor.weekday >= DateTime.monday && cursor.weekday <= DateTime.friday) {
      count++;
    }
    cursor = cursor.add(const Duration(days: 1));
  }
  return count;
}

// ─────────────────────────────────────────────────────────────────────────
// DOCUMENTOS POR ESTADO
// ─────────────────────────────────────────────────────────────────────────

class DocumentsReport {
  const DocumentsReport({
    required this.totalsByStatus,
    required this.totalsByType,
  });

  final Map<DocumentStatus, int> totalsByStatus;
  final Map<DocumentType, int> totalsByType;

  int get total => totalsByStatus.values.fold(0, (a, b) => a + b);
}

final documentsReportProvider = Provider<DocumentsReport>((ref) {
  final range = ref.watch(reportRangeProvider);

  final byStatus = {for (final s in DocumentStatus.values) s: 0};
  final byType = {for (final t in DocumentType.values) t: 0};

  for (final doc in MockDocuments.all) {
    final inRange = !doc.uploadedAt.isBefore(range.start) &&
        doc.uploadedAt.isBefore(range.end);
    if (!inRange) continue;
    byStatus[doc.status] = (byStatus[doc.status] ?? 0) + 1;
    byType[doc.type] = (byType[doc.type] ?? 0) + 1;
  }

  return DocumentsReport(
    totalsByStatus: byStatus,
    totalsByType: byType,
  );
});

// ─────────────────────────────────────────────────────────────────────────
// EVENTOS POR CATEGORÍA
// ─────────────────────────────────────────────────────────────────────────

class EventsReport {
  const EventsReport({
    required this.totalsByCategory,
    required this.totalActive,
    required this.totalArchived,
  });

  final Map<EventCategory, int> totalsByCategory;
  final int totalActive;
  final int totalArchived;

  int get total => totalsByCategory.values.fold(0, (a, b) => a + b);
}

final eventsReportProvider = Provider<EventsReport>((ref) {
  final range = ref.watch(reportRangeProvider);

  final byCategory = {for (final c in EventCategory.values) c: 0};
  var totalActive = 0;
  var totalArchived = 0;

  for (final event in MockEvents.all) {
    // El criterio de "evento del período" es startDate dentro del rango.
    final inRange = !event.startDate.isBefore(range.start) &&
        event.startDate.isBefore(range.end);
    if (!inRange) continue;
    byCategory[event.category] = (byCategory[event.category] ?? 0) + 1;
    if (event.isArchived) {
      totalArchived++;
    } else if (event.isActive) {
      totalActive++;
    }
  }

  return EventsReport(
    totalsByCategory: byCategory,
    totalActive: totalActive,
    totalArchived: totalArchived,
  );
});

// ─────────────────────────────────────────────────────────────────────────
// RESUMEN GENERAL
// ─────────────────────────────────────────────────────────────────────────

class ReportSummary {
  const ReportSummary({
    required this.attendanceAverage,
    required this.documentsTotal,
    required this.documentsApproved,
    required this.eventsTotal,
    required this.eventsActive,
  });

  final double attendanceAverage;
  final int documentsTotal;
  final int documentsApproved;
  final int eventsTotal;
  final int eventsActive;
}

final reportSummaryProvider = Provider<ReportSummary>((ref) {
  final attendance = ref.watch(attendanceReportProvider);
  final documents = ref.watch(documentsReportProvider);
  final events = ref.watch(eventsReportProvider);
  return ReportSummary(
    attendanceAverage: attendance.averageRate,
    documentsTotal: documents.total,
    documentsApproved:
        documents.totalsByStatus[DocumentStatus.approved] ?? 0,
    eventsTotal: events.total,
    eventsActive: events.totalActive,
  );
});
