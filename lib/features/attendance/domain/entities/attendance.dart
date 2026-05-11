/// Entidad de registro de asistencia.
enum AttendanceMethod { qr, click }

class Attendance {
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

  final String id;
  final String teacherId;
  /// Día en formato YYYY-MM-DD (clave única para evitar registros duplicados).
  final String date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final AttendanceMethod method;
  final String deviceId;
  final bool isValid;

  /// Considera "tarde" cualquier ingreso después de las 8:00 AM.
  bool get isLate {
    return checkInTime.hour > 8 ||
        (checkInTime.hour == 8 && checkInTime.minute > 0);
  }
}
