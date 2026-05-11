import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';

/// Catálogo central de notificaciones mock.
///
/// Cada notificación tiene un destinatario explícito (`userId`); el
/// datasource filtra por usuario antes de emitirlas al stream. Los
/// timestamps son relativos a [_now] para que la UI muestre etiquetas
/// del estilo "hace 2 h" sin importar cuándo se ejecute la app.
class MockNotifications {
  MockNotifications._();

  static final DateTime _now = DateTime.now();

  static DateTime _ago({int days = 0, int hours = 0, int minutes = 0}) {
    return _now.subtract(
      Duration(days: days, hours: hours, minutes: minutes),
    );
  }

  /// Lista mutable: el datasource modifica `isRead` y elimina entries
  /// en runtime cuando el usuario interactúa.
  static final List<AppNotification> all = [
    // ────────── Carlos Mamani (parent_001) ──────────
    AppNotification(
      id: 'ntf_p1_01',
      userId: 'usr_parent_001',
      type: NotificationType.documentRejected,
      title: 'Documento rechazado',
      body:
          'Tu solicitud de descuento para Mateo fue rechazada. Revisa los '
          'comentarios y vuelve a subir el comprobante.',
      createdAt: _ago(hours: 2),
      isRead: false,
      deepLink: '/documents',
    ),
    AppNotification(
      id: 'ntf_p1_02',
      userId: 'usr_parent_001',
      type: NotificationType.documentApproved,
      title: 'Documento aprobado',
      body:
          'Tu comprobante de membresía IASD quedó aprobado. El descuento '
          'institucional ya está activo.',
      createdAt: _ago(days: 1, hours: 3),
      isRead: false,
      deepLink: '/documents',
    ),
    AppNotification(
      id: 'ntf_p1_03',
      userId: 'usr_parent_001',
      type: NotificationType.eventPublished,
      title: 'Reunión general de apoderados',
      body:
          'La reunión informativa del primer trimestre se realizará en el '
          'auditorio principal. Asistencia obligatoria.',
      createdAt: _ago(days: 1, hours: 8),
      isRead: false,
      deepLink: '/events/detail/evt_004',
    ),
    AppNotification(
      id: 'ntf_p1_04',
      userId: 'usr_parent_001',
      type: NotificationType.documentReviewing,
      title: 'Documento en revisión',
      body:
          'La solicitud de descuento para Sofía pasó a revisión. Te '
          'avisaremos cuando se apruebe.',
      createdAt: _ago(days: 3),
      isRead: true,
      deepLink: '/documents',
    ),
    AppNotification(
      id: 'ntf_p1_05',
      userId: 'usr_parent_001',
      type: NotificationType.generalAnnouncement,
      title: 'Aviso del director',
      body:
          'A partir del lunes el ingreso al colegio es 7:30 AM. La portería '
          'cierra a las 7:45 AM.',
      createdAt: _ago(days: 5, hours: 4),
      isRead: true,
    ),
    AppNotification(
      id: 'ntf_p1_06',
      userId: 'usr_parent_001',
      type: NotificationType.eventPublished,
      title: 'Feria cultural adventista',
      body:
          'El sábado se realizará la feria cultural. Las familias están '
          'invitadas a visitar los stands de cada aula.',
      createdAt: _ago(days: 7),
      isRead: true,
      deepLink: '/events/detail/evt_007',
    ),

    // ────────── Elena Flores (teacher_001) ──────────
    AppNotification(
      id: 'ntf_t1_01',
      userId: 'usr_teacher_001',
      type: NotificationType.attendanceReminder,
      title: 'Recuerda registrar tu asistencia',
      body:
          'Aún no has registrado entrada hoy. Escanea el código QR del día '
          'en la sala de profesores.',
      createdAt: _ago(minutes: 30),
      isRead: false,
      deepLink: '/attendance/scan',
    ),
    AppNotification(
      id: 'ntf_t1_02',
      userId: 'usr_teacher_001',
      type: NotificationType.eventPublished,
      title: 'Capacitación docente — UGEL',
      body:
          'Taller de evaluación formativa este viernes en la sala de '
          'profesores. Asistencia obligatoria.',
      createdAt: _ago(days: 2),
      isRead: false,
      deepLink: '/events/detail/evt_005',
    ),
    AppNotification(
      id: 'ntf_t1_03',
      userId: 'usr_teacher_001',
      type: NotificationType.generalAnnouncement,
      title: 'Reunión de coordinación',
      body:
          'La reunión semanal de coordinadores se traslada al miércoles a '
          'las 4:00 PM en dirección.',
      createdAt: _ago(days: 4, hours: 6),
      isRead: true,
    ),
    AppNotification(
      id: 'ntf_t1_04',
      userId: 'usr_teacher_001',
      type: NotificationType.eventPublished,
      title: 'Olimpiadas matemáticas internas',
      body:
          'Las olimpiadas comenzarán hoy a las 9:00 AM en el segundo piso. '
          'Acompaña a tus estudiantes.',
      createdAt: _ago(days: 6),
      isRead: true,
      deepLink: '/events/detail/evt_003',
    ),

    // ────────── Mateo Mamani (student_001) ──────────
    AppNotification(
      id: 'ntf_s1_01',
      userId: 'usr_student_001',
      type: NotificationType.eventPublished,
      title: 'Festival deportivo interclases',
      body:
          'Inauguración del campeonato interno este sábado en la losa '
          'deportiva. Lleva tu polo de educación física.',
      createdAt: _ago(hours: 5),
      isRead: false,
      deepLink: '/events/detail/evt_006',
    ),
    AppNotification(
      id: 'ntf_s1_02',
      userId: 'usr_student_001',
      type: NotificationType.eventPublished,
      title: 'Vigilia juvenil',
      body:
          'Vigilia espiritual para 3° a 5° de secundaria este viernes a '
          'partir de las 7 PM en la capilla.',
      createdAt: _ago(days: 2, hours: 4),
      isRead: false,
      deepLink: '/events/detail/evt_008',
    ),
    AppNotification(
      id: 'ntf_s1_03',
      userId: 'usr_student_001',
      type: NotificationType.generalAnnouncement,
      title: 'Cambio de horario de salida',
      body:
          'Esta semana la salida será a las 1:30 PM por la jornada '
          'pedagógica de los profesores.',
      createdAt: _ago(days: 4),
      isRead: true,
    ),
  ];

  /// Notificaciones del usuario [userId] ordenadas de la más reciente a
  /// la más antigua.
  static List<AppNotification> forUser(String userId) {
    return all.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
