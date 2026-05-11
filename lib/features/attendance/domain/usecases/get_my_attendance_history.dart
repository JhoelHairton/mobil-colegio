import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/repositories/attendance_repository.dart';

class GetMyAttendanceHistory {
  GetMyAttendanceHistory(this._repository);

  final AttendanceRepository _repository;

  Stream<List<Attendance>> call(String teacherId) =>
      _repository.watchMyHistory(teacherId);
}
