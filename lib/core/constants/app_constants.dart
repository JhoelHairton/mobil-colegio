/// Constantes globales de la aplicación.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Agenda Escolar Adventista';
  static const String appShortName = 'AEA';
  static const String institutionName = 'Colegio Adventista Juliaca';
  static const String version = '1.0.0';

  // Coordenadas del colegio (configurar con las reales)
  static const double schoolLatitude = -15.5000;
  static const double schoolLongitude = -70.1333;
  static const double attendanceRadiusMeters = 100.0;

  // Ventanas horarias de asistencia
  static const int checkInStartHour = 6;
  static const int checkInStartMinute = 30;
  static const int checkInEndHour = 8;
  static const int checkInEndMinute = 30;

  static const int checkOutStartHour = 13;
  static const int checkOutStartMinute = 0;
  static const int checkOutEndHour = 18;
  static const int checkOutEndMinute = 0;

  // Tolerancia para tardanza (en minutos después del inicio puntual)
  static const int latenessToleranceMinutes = 15;

  // Documentos
  static const int maxDocumentSizeMB = 2;
  static const int maxDocumentSizeBytes = maxDocumentSizeMB * 1024 * 1024;
  static const List<String> allowedDocumentExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  // Soporte
  static const String supportEmail = 'soporte@colegioadventistajuliaca.edu.pe';
  static const String privacyEmail = 'privacidad@colegioadventistajuliaca.edu.pe';

  // URLs
  static const String privacyPolicyUrl = 'https://colegioadventistajuliaca.edu.pe/privacidad';
  static const String termsUrl = 'https://colegioadventistajuliaca.edu.pe/terminos';
}
