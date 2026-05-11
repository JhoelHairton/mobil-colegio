import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/repositories/documents_repository.dart';

class GetMyDocuments {
  GetMyDocuments(this._repository);

  final DocumentsRepository _repository;

  Stream<List<AppDocument>> call(String parentId) =>
      _repository.watchMyDocuments(parentId);
}
