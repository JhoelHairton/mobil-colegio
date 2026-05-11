import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';

/// Catálogo central de documentos mock.
///
/// Cubre los 3 tipos ([DocumentType]) y los 4 estados
/// ([DocumentStatus]) con datos repartidos entre los padres del
/// catálogo [`MockUsers`]. La cuenta principal de prueba
/// (`usr_parent_001` — `apoderado@familia.com`) tiene la data más
/// variada para que el cliente vea todos los estados al hacer demo.
class MockDocuments {
  MockDocuments._();

  static final DateTime _now = DateTime.now();

  static DateTime _at(int daysAgo, {int hour = 10, int minute = 0}) {
    final base = _now.subtract(Duration(days: daysAgo));
    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  /// Lista mutable: el datasource agrega nuevos uploads en runtime.
  static final List<AppDocument> all = [
    // ───────────────── Carlos Mamani (parent_001) ─────────────────
    // 3 pendientes / en revisión, 2 aprobados, 1 rechazado.
    AppDocument(
      id: 'doc_001',
      parentId: 'usr_parent_001',
      studentId: 'usr_student_001',
      type: DocumentType.membership,
      fileUrl: 'mock://documents/comprobante-membresia-mateo.pdf',
      fileName: 'comprobante-membresia-mateo.pdf',
      fileSize: 248320,
      status: DocumentStatus.pending,
      uploadedAt: _at(1, hour: 8, minute: 30),
    ),
    AppDocument(
      id: 'doc_002',
      parentId: 'usr_parent_001',
      studentId: 'usr_student_002',
      type: DocumentType.discount,
      fileUrl: 'mock://documents/solicitud-descuento-sofia.pdf',
      fileName: 'solicitud-descuento-sofia.pdf',
      fileSize: 412800,
      status: DocumentStatus.reviewing,
      uploadedAt: _at(3, hour: 17, minute: 45),
      comments: 'En revisión por la oficina de bienestar.',
    ),
    AppDocument(
      id: 'doc_003',
      parentId: 'usr_parent_001',
      studentId: null,
      type: DocumentType.tithe,
      fileUrl: 'mock://documents/comprobante-diezmo-marzo.jpg',
      fileName: 'comprobante-diezmo-marzo.jpg',
      fileSize: 1124500,
      status: DocumentStatus.pending,
      uploadedAt: _at(5, hour: 19),
    ),
    AppDocument(
      id: 'doc_004',
      parentId: 'usr_parent_001',
      studentId: 'usr_student_001',
      type: DocumentType.membership,
      fileUrl: 'mock://documents/membresia-iasd-juliaca.pdf',
      fileName: 'membresia-iasd-juliaca.pdf',
      fileSize: 198440,
      status: DocumentStatus.approved,
      uploadedAt: _at(18, hour: 11),
      comments: 'Aprobado. Descuento institucional aplicado.',
    ),
    AppDocument(
      id: 'doc_005',
      parentId: 'usr_parent_001',
      studentId: 'usr_student_002',
      type: DocumentType.tithe,
      fileUrl: 'mock://documents/diezmo-febrero-sofia.pdf',
      fileName: 'diezmo-febrero-sofia.pdf',
      fileSize: 312080,
      status: DocumentStatus.approved,
      uploadedAt: _at(28, hour: 9, minute: 15),
    ),
    AppDocument(
      id: 'doc_006',
      parentId: 'usr_parent_001',
      studentId: 'usr_student_001',
      type: DocumentType.discount,
      fileUrl: 'mock://documents/descuento-rechazado-mateo.pdf',
      fileName: 'descuento-rechazado-mateo.pdf',
      fileSize: 567220,
      status: DocumentStatus.rejected,
      uploadedAt: _at(35, hour: 14, minute: 20),
      comments:
          'El comprobante de ingresos está vencido. Por favor adjunta uno '
          'emitido en los últimos 3 meses y vuelve a subirlo.',
    ),

    // ───────────────── María Aguilar (parent_002) ─────────────────
    AppDocument(
      id: 'doc_007',
      parentId: 'usr_parent_002',
      studentId: 'usr_student_003',
      type: DocumentType.membership,
      fileUrl: 'mock://documents/membresia-aguilar.pdf',
      fileName: 'membresia-aguilar.pdf',
      fileSize: 220100,
      status: DocumentStatus.approved,
      uploadedAt: _at(45, hour: 10),
    ),
    AppDocument(
      id: 'doc_008',
      parentId: 'usr_parent_002',
      studentId: 'usr_student_003',
      type: DocumentType.tithe,
      fileUrl: 'mock://documents/diezmo-aguilar-marzo.jpg',
      fileName: 'diezmo-aguilar-marzo.jpg',
      fileSize: 880500,
      status: DocumentStatus.reviewing,
      uploadedAt: _at(2, hour: 16),
    ),

    // ───────────────── Lucía Quispe (parent_003 — preregistrada) ─────────────────
    // Aún no ha activado; la mostramos sólo para que cuando active,
    // tenga al menos un documento histórico subido por la secretaría.
    AppDocument(
      id: 'doc_009',
      parentId: 'usr_parent_003',
      studentId: 'usr_student_004',
      type: DocumentType.membership,
      fileUrl: 'mock://documents/membresia-quispe.pdf',
      fileName: 'membresia-quispe.pdf',
      fileSize: 191300,
      status: DocumentStatus.approved,
      uploadedAt: _at(60, hour: 12),
      comments: 'Cargado por secretaría durante la matrícula.',
    ),
  ];

  /// Documentos de un padre específico ordenados por fecha de carga
  /// descendente (lo más nuevo primero).
  static List<AppDocument> forParent(String parentId) {
    final list = all.where((d) => d.parentId == parentId).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return list;
  }

  /// Búsqueda por id.
  static AppDocument? findById(String id) {
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }
}
