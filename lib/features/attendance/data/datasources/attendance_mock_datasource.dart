import 'dart:async';

import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_attendance.dart';

/// Datasource en memoria para asistencias.
///
/// Mantiene una copia mutable de [MockAttendance.all] y un
/// [StreamController.broadcast] por docente para emitir cambios cuando
/// se registra una asistencia nueva.
class AttendanceMockDataSource {
  AttendanceMockDataSource() {
    _records = [...MockAttendance.all];
  }

  late final List<Attendance> _records;
  final Map<String, StreamController<List<Attendance>>> _controllers = {};

  /// Latencias simuladas: el shimmer de la lista no parpadea y el
  /// registro siente cierto peso para que el feedback visual valga.
  static const Duration _initialLatency = Duration(milliseconds: 500);
  static const Duration _writeLatency = Duration(milliseconds: 700);

  Stream<List<Attendance>> watchMyHistory(String teacherId) {
    final controller = _controllers.putIfAbsent(
      teacherId,
      StreamController<List<Attendance>>.broadcast,
    );

    Future<void>.delayed(_initialLatency, () {
      if (!controller.isClosed) controller.add(_forTeacher(teacherId));
    });

    return controller.stream;
  }

  Future<bool> hasCheckedInToday(String teacherId) async {
    return _hasCheckedInToday(teacherId);
  }

  String getTodaysQrCode() => MockAttendance.todaysQrCode;

  Future<AttendanceResult> recordAttendance({
    required String teacherId,
    required String qrPayload,
    required String deviceId,
    AttendanceMethod method = AttendanceMethod.qr,
  }) async {
    await Future<void>.delayed(_writeLatency);

    if (qrPayload.trim() != MockAttendance.todaysQrCode) {
      return const AttendanceInvalidQr();
    }

    if (_hasCheckedInToday(teacherId)) {
      final existing = _records.firstWhere(
        (a) => a.teacherId == teacherId && a.date == _todayKey(),
      );
      return AttendanceAlreadyRegistered(existing);
    }

    final now = DateTime.now();
    final attendance = Attendance(
      id: 'att_${now.millisecondsSinceEpoch}',
      teacherId: teacherId,
      date: _todayKey(),
      checkInTime: now,
      method: method,
      deviceId: deviceId,
      isValid: true,
    );
    _records.add(attendance);
    _emit(teacherId);
    return AttendanceRegistered(attendance);
  }

  // ─────────────────────── helpers ───────────────────────

  List<Attendance> _forTeacher(String teacherId) {
    final list = _records.where((a) => a.teacherId == teacherId).toList()
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    return list;
  }

  bool _hasCheckedInToday(String teacherId) {
    final today = _todayKey();
    return _records.any((a) => a.teacherId == teacherId && a.date == today);
  }

  String _todayKey() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _emit(String teacherId) {
    final controller = _controllers[teacherId];
    if (controller != null && !controller.isClosed) {
      controller.add(_forTeacher(teacherId));
    }
  }
}
