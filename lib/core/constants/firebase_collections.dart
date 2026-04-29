/// Nombres de colecciones de Firestore.
/// Centralizar aquí evita typos y facilita refactoring.
class FirebaseCollections {
  FirebaseCollections._();

  static const String users = 'users';
  static const String events = 'events';
  static const String attendance = 'attendance';
  static const String attendanceQrCodes = 'attendance_qr_codes';
  static const String documents = 'documents';
  static const String students = 'students';
  static const String notifications = 'notifications';
  static const String auditLogs = 'audit_logs';
}
