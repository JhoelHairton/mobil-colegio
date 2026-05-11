import 'dart:async';

import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_documents.dart';

/// Datasource en memoria para documentos.
///
/// Mantiene una copia mutable de [MockDocuments.all] y un
/// [_StreamController.broadcast] por padre para emitir cambios en
/// tiempo real cuando llega un upload nuevo.
///
/// Cuando llegue Sprint 7, se crea otro datasource Firestore con la
/// misma forma pública y el repository elige cuál inyectar.
class DocumentsMockDataSource {
  DocumentsMockDataSource() {
    _documents = [...MockDocuments.all];
  }

  late final List<AppDocument> _documents;
  final Map<String, StreamController<List<AppDocument>>> _controllers = {};
  StreamController<List<AppDocument>>? _allController;

  /// Latencias simuladas para que el shimmer/skeleton no parpadee.
  static const Duration _initialLatency = Duration(milliseconds: 500);
  static const Duration _shortLatency = Duration(milliseconds: 250);
  static const Duration _uploadLatency = Duration(milliseconds: 1200);
  static const Duration _reviewLatency = Duration(milliseconds: 700);

  /// Stream de documentos del padre [parentId]. Re-emite cuando
  /// [uploadDocument] inserta un nuevo registro suyo.
  Stream<List<AppDocument>> watchMyDocuments(String parentId) {
    final controller = _controllers.putIfAbsent(
      parentId,
      StreamController<List<AppDocument>>.broadcast,
    );

    Future<void>.delayed(_initialLatency, () {
      if (!controller.isClosed) controller.add(_forParent(parentId));
    });

    return controller.stream;
  }

  Future<AppDocument?> getDocumentById(String id) async {
    await Future<void>.delayed(_shortLatency);
    for (final d in _documents) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Crea un registro nuevo en estado [DocumentStatus.pending]. La URL
  /// se simula a partir del nombre de archivo. Devuelve el id generado.
  Future<String> uploadDocument({
    required String parentId,
    String? studentId,
    required DocumentType type,
    required String fileName,
    required int fileSize,
    required String localPath,
  }) async {
    await Future<void>.delayed(_uploadLatency);
    final id = 'doc_${DateTime.now().millisecondsSinceEpoch}';
    final document = AppDocument(
      id: id,
      parentId: parentId,
      studentId: studentId,
      type: type,
      fileUrl: 'mock://documents/$fileName',
      fileName: fileName,
      fileSize: fileSize,
      status: DocumentStatus.pending,
      uploadedAt: DateTime.now(),
    );
    _documents.add(document);
    _emit(parentId);
    return id;
  }

  // ─── Admin / secretaría ────────────────────────────────────────────

  Stream<List<AppDocument>> watchAllDocuments() {
    final controller =
        _allController ??= StreamController<List<AppDocument>>.broadcast();

    Future<void>.delayed(_initialLatency, () {
      if (!controller.isClosed) controller.add(_allSorted());
    });

    return controller.stream;
  }

  Future<AppDocument> reviewDocument({
    required String documentId,
    required DocumentStatus newStatus,
    String? comment,
  }) async {
    await Future<void>.delayed(_reviewLatency);
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index == -1) {
      throw StateError('Documento $documentId no encontrado');
    }
    final updated = _documents[index].copyWith(
      status: newStatus,
      comments: comment,
      clearComments: comment == null,
    );
    _documents[index] = updated;
    _emit(updated.parentId);
    _emitAll();
    return updated;
  }

  // ─────────────────────── helpers ───────────────────────

  List<AppDocument> _forParent(String parentId) {
    final list = _documents.where((d) => d.parentId == parentId).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return list;
  }

  List<AppDocument> _allSorted() {
    return [..._documents]
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  void _emit(String parentId) {
    final controller = _controllers[parentId];
    if (controller != null && !controller.isClosed) {
      controller.add(_forParent(parentId));
    }
  }

  void _emitAll() {
    final controller = _allController;
    if (controller != null && !controller.isClosed) {
      controller.add(_allSorted());
    }
  }
}
