import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';

/// Catálogo central de asistencias mock.
///
/// Genera registros de los últimos días para los docentes activos del
/// catálogo [`MockUsers`], con días faltantes (ausencias) y métodos
/// variados (QR la mayoría, click manual cuando algo falló).
///
/// El día de hoy NO tiene registro para teacher_001 — así el flujo de
/// escaneo QR puede probarse sin tener que limpiar nada.
class MockAttendance {
  MockAttendance._();

  static final DateTime _now = DateTime.now();

  /// Código QR válido para el día actual. Formato: `AEA-YYYYMMDD-V1`.
  ///
  /// El servidor real rotará el código diariamente; en mock lo derivamos
  /// de la fecha local. La versión `V1` queda reservada por si en el
  /// futuro firmamos el payload.
  static String get todaysQrCode => qrCodeFor(_now);

  /// Código QR válido para una fecha específica (útil en tests y demos).
  static String qrCodeFor(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'AEA-$y$m$d-V1';
  }

  static String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// Lista mutable: el datasource agrega nuevos registros en runtime.
  static final List<Attendance> all = _seed();

  static List<Attendance> _seed() {
    final list = <Attendance>[];

    // ───────── teacher_001 (Elena Flores) — docente principal de prueba.
    // 18 días con registro en los últimos 25, ausente algunos sábados/feriados.
    for (var i = 1; i <= 25; i++) {
      final day = _now.subtract(Duration(days: i));
      // Saltamos domingos (asumimos día libre) y un par de días aleatorios.
      if (day.weekday == DateTime.sunday) continue;
      if (i == 4 || i == 11 || i == 18) continue; // ausencias dispersas
      final isLate = i == 7 || i == 14; // dos llegadas tardes
      final hour = isLate ? 8 : 7;
      final minute = isLate ? (i == 7 ? 35 : 22) : 45;
      final method = (i % 6 == 0) ? AttendanceMethod.click : AttendanceMethod.qr;
      list.add(
        Attendance(
          id: 'att_t1_$i',
          teacherId: 'usr_teacher_001',
          date: _dateKey(day),
          checkInTime: DateTime(day.year, day.month, day.day, hour, minute),
          checkOutTime:
              DateTime(day.year, day.month, day.day, 14, isLate ? 5 : 0),
          method: method,
          deviceId: 'device_elena_pixel7',
          isValid: true,
        ),
      );
    }

    // ───────── teacher_002 (Néstor Huanca) — pocos registros recientes.
    for (var i in const [1, 2, 3, 5, 6, 8, 9]) {
      final day = _now.subtract(Duration(days: i));
      if (day.weekday == DateTime.sunday) continue;
      list.add(
        Attendance(
          id: 'att_t2_$i',
          teacherId: 'usr_teacher_002',
          date: _dateKey(day),
          checkInTime: DateTime(day.year, day.month, day.day, 7, 50),
          checkOutTime: DateTime(day.year, day.month, day.day, 14, 0),
          method: AttendanceMethod.qr,
          deviceId: 'device_nestor_galaxya54',
          isValid: true,
        ),
      );
    }

    // Ordenamos del más reciente al más antiguo para que la primera
    // entrega del stream ya venga lista para mostrar.
    list.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    return list;
  }

  /// Asistencias del docente [teacherId] ordenadas del más reciente al
  /// más antiguo.
  static List<Attendance> forTeacher(String teacherId) {
    return all.where((a) => a.teacherId == teacherId).toList()
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
  }

  /// Indica si el docente ya registró asistencia hoy.
  static bool hasCheckedInToday(String teacherId) {
    final today = _dateKey(_now);
    return all.any((a) => a.teacherId == teacherId && a.date == today);
  }
}
