import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/repositories/documents_repository.dart';

class UploadDocument {
  UploadDocument(this._repository);

  final DocumentsRepository _repository;

  Future<String> call({
    required String parentId,
    String? studentId,
    required DocumentType type,
    required String fileName,
    required int fileSize,
    required String localPath,
  }) {
    return _repository.uploadDocument(
      parentId: parentId,
      studentId: studentId,
      type: type,
      fileName: fileName,
      fileSize: fileSize,
      localPath: localPath,
    );
  }
}
