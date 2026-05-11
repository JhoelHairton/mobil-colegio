/// Constantes con todas las rutas de la aplicación.
class AppRoutes {
  AppRoutes._();

  // Auth y onboarding
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String activate = '/activate';
  static const String forgotPassword = '/forgot-password';

  // Home según rol
  static const String parentHome = '/parent/home';
  static const String teacherHome = '/teacher/home';
  static const String studentHome = '/student/home';
  static const String adminHome = '/admin/home';

  // Admin / secretaría
  static const String adminPendingDocuments = '/admin/documents';
  static const String adminUsers = '/admin/users';
  static const String adminCreateUser = '/admin/users/new';
  static const String adminEvents = '/admin/events';
  static const String adminCreateEvent = '/admin/events/new';
  static const String adminEditEvent = '/admin/events/edit';
  static const String adminReports = '/admin/reports';
  static const String adminBulkImport = '/admin/users/import';

  // Eventos
  static const String eventsList = '/events';
  static const String eventDetail = '/events/detail';

  // Asistencia
  static const String qrScan = '/attendance/scan';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceSuccess = '/attendance/success';

  // Documentos
  static const String myDocuments = '/documents';
  static const String uploadDocument = '/documents/upload';

  // Notificaciones
  static const String notifications = '/notifications';

  // Perfil
  static const String profile = '/profile';

  // Dev — vitrina del design system (no expuesto en menús de producción)
  static const String styleGuide = '/style-guide';
}
