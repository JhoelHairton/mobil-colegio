/// Entidad de registro de asistencia.
enum AttendanceMethod { qr, click }

class Attendance {
  final String id;
  final String teacherId;
  final String date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final AttendanceMethod method;
  final String deviceId;
  final bool isValid;

  const Attendance({
    required this.id,
    required this.teacherId,
    required this.date,
    required this.checkInTime,
    required this.method,
    required this.deviceId,
    required this.isValid,
    this.checkOutTime,
  });
}
