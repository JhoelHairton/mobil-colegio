import 'package:agenda_escolar_adventista/features/documents/data/datasources/documents_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/repositories/documents_repository.dart';

/// Implementación del repositorio de documentos basada en el datasource
/// mock. Cuando llegue Sprint 7 (Firebase Storage + Firestore) se crea
/// otra implementación con la misma forma — esta queda para tests.
class DocumentsRepositoryImpl implements DocumentsRepository {
  DocumentsRepositoryImpl(this._dataSource);

  final DocumentsMockDataSource _dataSource;

  @override
  Stream<List<AppDocument>> watchMyDocuments(String parentId) =>
      _dataSource.watchMyDocuments(parentId);

  @override
  Future<AppDocument?> getDocumentById(String id) =>
      _dataSource.getDocumentById(id);

  @override
  Future<String> uploadDocument({
    required String parentId,
    String? studentId,
    required DocumentType type,
    required String fileName,
    required int fileSize,
    required String localPath,
  }) {
    return _dataSource.uploadDocument(
      parentId: parentId,
      studentId: studentId,
      type: type,
      fileName: fileName,
      fileSize: fileSize,
      localPath: localPath,
    );
  }

  @override
  Stream<List<AppDocument>> watchAllDocuments() =>
      _dataSource.watchAllDocuments();

  @override
  Future<AppDocument> reviewDocument({
    required String documentId,
    required DocumentStatus newStatus,
    String? comment,
  }) {
    return _dataSource.reviewDocument(
      documentId: documentId,
      newStatus: newStatus,
      comment: comment,
    );
  }
}
