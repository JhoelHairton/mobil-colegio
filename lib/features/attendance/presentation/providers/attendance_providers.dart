import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/features/attendance/data/datasources/attendance_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/usecases/record_attendance.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';

/// Datasource único en memoria. Cuando llegue Firebase se reemplaza por
/// el datasource Firestore conservando esta misma forma.
final attendanceMockDataSourceProvider =
    Provider<AttendanceMockDataSource>((ref) {
  return AttendanceMockDataSource();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(attendanceMockDataSourceProvider));
});

final recordAttendanceUseCaseProvider = Provider<RecordAttendance>((ref) {
  return RecordAttendance(ref.watch(attendanceRepositoryProvider));
});

/// Stream de las asistencias del docente actualmente autenticado.
/// Vacío si no hay sesión.
final myAttendanceStreamProvider =
    StreamProvider<List<Attendance>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream<List<Attendance>>.value(const []);
  }
  return ref.watch(attendanceRepositoryProvider).watchMyHistory(user.uid);
});

/// `true` cuando el docente actual ya marcó asistencia hoy. Se calcula
/// a partir del stream para mantenerse sincronizado tras un registro.
final hasCheckedInTodayProvider = Provider<bool>((ref) {
  final asyncList = ref.watch(myAttendanceStreamProvider);
  return asyncList.maybeWhen(
    data: (records) {
      if (records.isEmpty) return false;
      final today = _todayKey(DateTime.now());
      return records.any((a) => a.date == today);
    },
    orElse: () => false,
  );
});

/// Asistencia de hoy si existe (para mostrar la hora en el home).
final todaysAttendanceProvider = Provider<Attendance?>((ref) {
  final asyncList = ref.watch(myAttendanceStreamProvider);
  return asyncList.maybeWhen(
    data: (records) {
      final today = _todayKey(DateTime.now());
      for (final a in records) {
        if (a.date == today) return a;
      }
      return null;
    },
    orElse: () => null,
  );
});

String _todayKey(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
