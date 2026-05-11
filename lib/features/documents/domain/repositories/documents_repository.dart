import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';

/// Contrato del repositorio de documentos.
///
/// La capa de datos puede implementar esta interfaz tanto con mock
/// como con Firebase. La presentation depende sólo de esta abstracción.
abstract class DocumentsRepository {
  /// Stream de documentos de un padre específico, ordenados por fecha
  /// de carga descendente. Re-emite cuando se sube un documento nuevo.
  Stream<List<AppDocument>> watchMyDocuments(String parentId);

  /// Detalle de un documento por id.
  Future<AppDocument?> getDocumentById(String id);

  /// Sube un nuevo documento. Retorna el id generado.
  ///
  /// Por ahora la "subida" es simulada: se adjunta el archivo local y
  /// el repo crea el registro en estado [DocumentStatus.pending].
  Future<String> uploadDocument({
    required String parentId,
    String? studentId,
    required DocumentType type,
    required String fileName,
    required int fileSize,
    required String localPath,
  });

  // ─── Operaciones de admin / secretaría ─────────────────────────────

  /// Stream con TODOS los documentos del sistema (todos los padres),
  /// ordenados de más reciente a más antiguo. Re-emite cuando se
  /// cambia el estado de cualquier documento.
  Stream<List<AppDocument>> watchAllDocuments();

  /// Cambia el estado de un documento. Si [newStatus] es
  /// [DocumentStatus.rejected], [comment] debería tener el motivo del
  /// rechazo. Devuelve el documento actualizado.
  Future<AppDocument> reviewDocument({
    required String documentId,
    required DocumentStatus newStatus,
    String? comment,
  });
}
