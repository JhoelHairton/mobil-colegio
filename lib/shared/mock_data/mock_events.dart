import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';

/// Catálogo central de eventos mock.
///
/// Cubre las 5 categorías ([EventCategory]) con eventos pasados, en curso
/// y futuros. Las fechas son relativas a [_now] para que la app siempre
/// muestre un mix coherente sin importar cuándo se ejecute.
class MockEvents {
  MockEvents._();

  static final DateTime _now = DateTime.now();

  /// Construye un evento con fechas relativas a hoy.
  static DateTime _at(int days, {int hour = 9, int minute = 0}) {
    final base = _now.add(Duration(days: days));
    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  static const String _adminUid = 'usr_admin_001';
  static const String _secretaryUid = 'usr_secretary_001';

  static final List<Event> all = [
    // ─────────────────── PASADOS (archivo histórico) ───────────────────
    Event(
      id: 'evt_001',
      title: 'Aniversario institucional 2026',
      description:
          'Celebración por los 78 años del Colegio Adventista de Juliaca. '
          'Programa especial con desfile cívico, presentación de delegaciones '
          'por nivel y palabras del director. Habrá venta de almuerzos a cargo '
          'de la APAFA.',
      category: EventCategory.cultural,
      startDate: _at(-30, hour: 8),
      endDate: _at(-30, hour: 13),
      location: 'Patio principal',
      targetAudience: TargetAudience.all,
      createdBy: _adminUid,
      createdAt: _at(-50),
      isActive: true,
      isArchived: true,
    ),
    Event(
      id: 'evt_002',
      title: 'Semana de oración — primer trimestre',
      description:
          'Cinco días de reflexión espiritual con el tema "Discípulos por la '
          'gracia". Predicaciones a cargo del Pr. Jorge Mamani. Se invita a '
          'padres a acompañar a sus hijos en el culto matutino.',
      category: EventCategory.spiritual,
      startDate: _at(-14, hour: 7, minute: 30),
      endDate: _at(-10, hour: 8, minute: 30),
      location: 'Capilla del colegio',
      targetAudience: TargetAudience.all,
      createdBy: _adminUid,
      createdAt: _at(-40),
      isActive: true,
      isArchived: true,
    ),

    // ─────────────────── EN CURSO O HOY ───────────────────
    Event(
      id: 'evt_003',
      title: 'Olimpiadas matemáticas internas',
      description:
          'Competencia interna de matemática para 3°, 4° y 5° de secundaria. '
          'Los tres primeros lugares representarán al colegio en la fase '
          'departamental ONEM 2026. Se rendirá una prueba escrita de 90 '
          'minutos por nivel.',
      category: EventCategory.academic,
      startDate: _at(0, hour: 9),
      endDate: _at(0, hour: 12, minute: 30),
      location: 'Aulas del segundo piso',
      targetAudience: TargetAudience.all,
      createdBy: _secretaryUid,
      createdAt: _at(-10),
      isActive: true,
      isArchived: false,
    ),

    // ─────────────────── PRÓXIMOS (esta semana) ───────────────────
    Event(
      id: 'evt_004',
      title: 'Reunión general de apoderados',
      description:
          'Reunión informativa sobre el cierre del primer trimestre, entrega '
          'de libretas y novedades del calendario académico. La asistencia '
          'es obligatoria para al menos un apoderado por estudiante.',
      category: EventCategory.academic,
      startDate: _at(2, hour: 18),
      endDate: _at(2, hour: 20),
      location: 'Auditorio principal',
      targetAudience: TargetAudience.parents,
      createdBy: _adminUid,
      createdAt: _at(-5),
      isActive: true,
      isArchived: false,
    ),
    Event(
      id: 'evt_005',
      title: 'Capacitación docente — evaluación formativa',
      description:
          'Taller a cargo de la UGEL Puno sobre el nuevo enfoque de '
          'evaluación formativa. Sólo personal docente. Se entregará '
          'certificado con 8 horas pedagógicas.',
      category: EventCategory.academic,
      startDate: _at(3, hour: 14, minute: 30),
      endDate: _at(3, hour: 18, minute: 30),
      location: 'Sala de profesores',
      targetAudience: TargetAudience.teachers,
      createdBy: _adminUid,
      createdAt: _at(-7),
      isActive: true,
      isArchived: false,
    ),
    Event(
      id: 'evt_006',
      title: 'Festival deportivo interclases',
      description:
          'Inauguración del campeonato interno 2026 de fulbito, vóley y '
          'básquet. Las delegaciones desfilarán por nivel. Después del acto '
          'inaugural se jugarán los partidos de la primera fecha.',
      category: EventCategory.sports,
      startDate: _at(5, hour: 8),
      endDate: _at(5, hour: 13),
      location: 'Losa deportiva',
      targetAudience: TargetAudience.all,
      createdBy: _adminUid,
      createdAt: _at(-12),
      isActive: true,
      isArchived: false,
    ),

    // ─────────────────── PRÓXIMOS (este mes) ───────────────────
    Event(
      id: 'evt_007',
      title: 'Feria cultural adventista',
      description:
          'Feria abierta a la comunidad de Juliaca. Cada aula presentará un '
          'stand con un país hispanohablante: gastronomía, costumbres, '
          'música y vestimenta típica. Habrá premios para los tres mejores '
          'stands. Entrada libre.',
      category: EventCategory.cultural,
      startDate: _at(9, hour: 9),
      endDate: _at(9, hour: 17),
      location: 'Patio principal y aulas',
      targetAudience: TargetAudience.all,
      createdBy: _adminUid,
      createdAt: _at(-15),
      isActive: true,
      isArchived: false,
    ),
    Event(
      id: 'evt_008',
      title: 'Vigilia juvenil — Adolescentes',
      description:
          'Vigilia espiritual para estudiantes de 3° a 5° de secundaria. '
          'Charlas, juegos cristianos y testimonios. Inicio 7 PM, fin a las '
          '11 PM. Los apoderados deben recoger a sus hijos al término.',
      category: EventCategory.spiritual,
      startDate: _at(12, hour: 19),
      endDate: _at(12, hour: 23),
      location: 'Capilla del colegio',
      targetAudience: TargetAudience.all,
      createdBy: _adminUid,
      createdAt: _at(-18),
      isActive: true,
      isArchived: false,
    ),
    Event(
      id: 'evt_009',
      title: 'Campaña de salud bucal',
      description:
          'Campaña gratuita en alianza con el Centro de Salud de Juliaca. '
          'Revisión odontológica, fluorización y charla de hábitos de '
          'higiene para todos los niveles. Traer cepillo personal.',
      category: EventCategory.campaign,
      startDate: _at(15, hour: 8),
      endDate: _at(15, hour: 14),
      location: 'Tópico y patio principal',
      targetAudience: TargetAudience.all,
      createdBy: _secretaryUid,
      createdAt: _at(-20),
      isActive: true,
      isArchived: false,
    ),

    // ─────────────────── PRÓXIMOS (próximo mes) ───────────────────
    Event(
      id: 'evt_010',
      title: 'Examen bimestral — segundo bimestre',
      description:
          'Inicio de la semana de exámenes bimestrales. El cronograma '
          'detallado por curso se publicará en la pizarra del aula. No se '
          'aceptarán justificaciones sin documento médico oficial.',
      category: EventCategory.academic,
      startDate: _at(22, hour: 8),
      endDate: _at(26, hour: 13),
      location: 'Aulas regulares',
      targetAudience: TargetAudience.all,
      createdBy: _secretaryUid,
      createdAt: _at(-3),
      isActive: true,
      isArchived: false,
    ),
    Event(
      id: 'evt_011',
      title: 'Concurso interescolar de oratoria',
      description:
          'Representación del colegio en el concurso interescolar organizado '
          'por la UGEL Puno. Tres estudiantes representarán a la institución. '
          'La selección interna se realizará una semana antes.',
      category: EventCategory.cultural,
      startDate: _at(28, hour: 10),
      endDate: _at(28, hour: 13, minute: 30),
      location: 'Auditorio UGEL Puno',
      targetAudience: TargetAudience.all,
      createdBy: _adminUid,
      createdAt: _at(-2),
      isActive: true,
      isArchived: false,
    ),
    Event(
      id: 'evt_012',
      title: 'Campaña de donación de víveres',
      description:
          'Campaña solidaria de cuaresma para apoyar a familias damnificadas '
          'por las inundaciones en el sur. Cada aula traerá un kit base '
          '(arroz, fideos, atún, leche). Se reciben donaciones hasta el '
          'viernes.',
      category: EventCategory.campaign,
      startDate: _at(33, hour: 7, minute: 30),
      endDate: _at(38, hour: 17),
      location: 'Recepción del colegio',
      targetAudience: TargetAudience.all,
      createdBy: _adminUid,
      createdAt: _at(-1),
      isActive: true,
      isArchived: false,
    ),
    Event(
      id: 'evt_013',
      title: 'Final de campeonato deportivo',
      description:
          'Partidos finales del campeonato interclases en las disciplinas de '
          'fulbito, vóley y básquet. Premiación al término. Se invita a los '
          'apoderados a asistir.',
      category: EventCategory.sports,
      startDate: _at(40, hour: 9),
      endDate: _at(40, hour: 13),
      location: 'Losa deportiva',
      targetAudience: TargetAudience.all,
      createdBy: _adminUid,
      createdAt: _at(0),
      isActive: true,
      isArchived: false,
    ),
    Event(
      id: 'evt_014',
      title: 'Clausura del primer semestre',
      description:
          'Acto académico de cierre del primer semestre. Premiación a los '
          'tercios y quintos superiores. Entrega de libretas a los '
          'apoderados al término del acto.',
      category: EventCategory.academic,
      startDate: _at(60, hour: 16),
      endDate: _at(60, hour: 18, minute: 30),
      location: 'Auditorio principal',
      targetAudience: TargetAudience.all,
      createdBy: _adminUid,
      createdAt: _at(0),
      isActive: true,
      isArchived: false,
    ),

    // ─────────────────── ARCHIVADO ───────────────────
    Event(
      id: 'evt_015',
      title: 'Retiro espiritual del personal docente 2025',
      description:
          'Retiro anual del personal docente en Lago Titicaca. Tres días de '
          'reflexión y planificación pedagógica. Evento del año anterior.',
      category: EventCategory.spiritual,
      startDate: _at(-200, hour: 8),
      endDate: _at(-198, hour: 18),
      location: 'Hotel Casa Andina, Puno',
      targetAudience: TargetAudience.teachers,
      createdBy: _adminUid,
      createdAt: _at(-220),
      isActive: false,
      isArchived: true,
    ),
  ];

  /// Búsqueda por id. Útil para el datasource mock.
  static Event? findById(String id) {
    for (final e in all) {
      if (e.id == id) return e;
    }
    return null;
  }
}
