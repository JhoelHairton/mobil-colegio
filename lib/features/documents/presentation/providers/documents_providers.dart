import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';
import 'package:agenda_escolar_adventista/features/documents/data/datasources/documents_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/repositories/documents_repository.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/usecases/upload_document.dart';

/// Datasource único en memoria. Cuando llegue Firebase se reemplaza por
/// el datasource Firestore conservando esta misma forma.
final documentsMockDataSourceProvider = Provider<DocumentsMockDataSource>((ref) {
  return DocumentsMockDataSource();
});

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DocumentsRepositoryImpl(ref.watch(documentsMockDataSourceProvider));
});

final uploadDocumentUseCaseProvider = Provider<UploadDocument>((ref) {
  return UploadDocument(ref.watch(documentsRepositoryProvider));
});

/// Stream de documentos del padre actualmente autenticado. Vacío si no
/// hay sesión o si el usuario no es padre.
final myDocumentsStreamProvider = StreamProvider<List<AppDocument>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream<List<AppDocument>>.value(const []);
  }
  return ref.watch(documentsRepositoryProvider).watchMyDocuments(user.uid);
});

/// Estado del filtro por estado. `null` significa "Todos".
final selectedDocumentStatusProvider =
    StateProvider<DocumentStatus?>((ref) => null);

/// Documentos filtrados según [selectedDocumentStatusProvider].
final filteredDocumentsProvider = Provider<AsyncValue<List<AppDocument>>>((ref) {
  final docsAsync = ref.watch(myDocumentsStreamProvider);
  final selected = ref.watch(selectedDocumentStatusProvider);

  return docsAsync.whenData((docs) {
    if (selected == null) return docs;
    return docs.where((d) => d.status == selected).toList(growable: false);
  });
});

/// Conteos por estado para mostrar en chips/dashboards. Devuelve un mapa
/// estable con TODOS los estados, aunque el conteo sea 0.
final documentCountsByStatusProvider =
    Provider<Map<DocumentStatus, int>>((ref) {
  final docsAsync = ref.watch(myDocumentsStreamProvider);
  final base = {for (final s in DocumentStatus.values) s: 0};
  return docsAsync.maybeWhen(
    data: (docs) {
      final counts = Map<DocumentStatus, int>.from(base);
      for (final d in docs) {
        counts[d.status] = (counts[d.status] ?? 0) + 1;
      }
      return counts;
    },
    orElse: () => base,
  );
});
