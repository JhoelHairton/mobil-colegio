import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/repositories/attendance_repository.dart';

class RecordAttendance {
  RecordAttendance(this._repository);

  final AttendanceRepository _repository;

  Future<AttendanceResult> call({
    required String teacherId,
    required String qrPayload,
    required String deviceId,
    AttendanceMethod method = AttendanceMethod.qr,
  }) {
    return _repository.recordAttendance(
      teacherId: teacherId,
      qrPayload: qrPayload,
      deviceId: deviceId,
      method: method,
    );
  }
}
