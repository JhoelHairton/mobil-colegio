import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';

/// Resultado de un intento de registro de asistencia.
sealed class AttendanceResult {
  const AttendanceResult();
}

/// Asistencia registrada con éxito.
class AttendanceRegistered extends AttendanceResult {
  const AttendanceRegistered(this.attendance);
  final Attendance attendance;
}

/// Falló porque el contenido del QR no coincide con el código del día.
class AttendanceInvalidQr extends AttendanceResult {
  const AttendanceInvalidQr();
}

/// El docente ya registró asistencia hoy.
class AttendanceAlreadyRegistered extends AttendanceResult {
  const AttendanceAlreadyRegistered(this.existing);
  final Attendance existing;
}

/// Contrato del repositorio de asistencias.
abstract class AttendanceRepository {
  /// Stream de las asistencias del docente, ordenadas por fecha
  /// descendente. Re-emite cuando se registra una nueva.
  Stream<List<Attendance>> watchMyHistory(String teacherId);

  /// Registra asistencia validando el contenido del QR.
  ///
  /// Si [qrPayload] no coincide con el código del día, retorna
  /// [AttendanceInvalidQr]. Si ya hay registro hoy, retorna
  /// [AttendanceAlreadyRegistered]. En caso exitoso retorna
  /// [AttendanceRegistered] con la entidad creada.
  Future<AttendanceResult> recordAttendance({
    required String teacherId,
    required String qrPayload,
    required String deviceId,
    AttendanceMethod method = AttendanceMethod.qr,
  });

  /// Código QR válido para hoy (mock: deriva de la fecha local).
  String getTodaysQrCode();

  /// Indica si el docente ya registró asistencia el día de hoy.
  Future<bool> hasCheckedInToday(String teacherId);
}
