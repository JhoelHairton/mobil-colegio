import 'package:agenda_escolar_adventista/features/attendance/data/datasources/attendance_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/repositories/attendance_repository.dart';

/// Implementación del repositorio de asistencias basada en el datasource
/// mock. Cuando llegue Sprint 7 se crea otra implementación con la
/// misma forma — esta queda intacta para tests y modo offline.
class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._dataSource);

  final AttendanceMockDataSource _dataSource;

  @override
  Stream<List<Attendance>> watchMyHistory(String teacherId) =>
      _dataSource.watchMyHistory(teacherId);

  @override
  Future<bool> hasCheckedInToday(String teacherId) =>
      _dataSource.hasCheckedInToday(teacherId);

  @override
  String getTodaysQrCode() => _dataSource.getTodaysQrCode();

  @override
  Future<AttendanceResult> recordAttendance({
    required String teacherId,
    required String qrPayload,
    required String deviceId,
    AttendanceMethod method = AttendanceMethod.qr,
  }) {
    return _dataSource.recordAttendance(
      teacherId: teacherId,
      qrPayload: qrPayload,
      deviceId: deviceId,
      method: method,
    );
  }
}
