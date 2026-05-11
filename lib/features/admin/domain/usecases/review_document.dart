import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/repositories/documents_repository.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_x.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/repositories/notifications_repository.dart';

/// Caso de uso "Revisar documento" — núcleo del flujo de la
/// administración. Cambia el estado del documento Y notifica al padre
/// involucrado en una sola llamada para que la presentation no tenga
/// que orquestar nada.
class ReviewDocument {
  ReviewDocument(this._documents, this._notifications);

  final DocumentsRepository _documents;
  final NotificationsRepository _notifications;

  Future<AppDocument> approve({
    required String documentId,
    String? comment,
  }) {
    return _execute(
      documentId: documentId,
      newStatus: DocumentStatus.approved,
      comment: comment,
    );
  }

  Future<AppDocument> reject({
    required String documentId,
    required String comment,
  }) {
    if (comment.trim().isEmpty) {
      throw ArgumentError('Para rechazar es obligatorio un comentario.');
    }
    return _execute(
      documentId: documentId,
      newStatus: DocumentStatus.rejected,
      comment: comment,
    );
  }

  /// Útil para mover un documento a "en revisión" cuando la secretaría
  /// lo abre y lo está procesando.
  Future<AppDocument> markAsReviewing({required String documentId}) {
    return _execute(
      documentId: documentId,
      newStatus: DocumentStatus.reviewing,
    );
  }

  Future<AppDocument> _execute({
    required String documentId,
    required DocumentStatus newStatus,
    String? comment,
  }) async {
    final updated = await _documents.reviewDocument(
      documentId: documentId,
      newStatus: newStatus,
      comment: comment,
    );

    // Notificamos al padre. En "reviewing" no es necesario molestarlo.
    if (newStatus == DocumentStatus.approved ||
        newStatus == DocumentStatus.rejected) {
      await _notifications.createNotification(
        AppNotification(
          id: '',
          userId: updated.parentId,
          type: newStatus == DocumentStatus.approved
              ? NotificationType.documentApproved
              : NotificationType.documentRejected,
          title: newStatus == DocumentStatus.approved
              ? 'Documento aprobado'
              : 'Documento rechazado',
          body: _bodyFor(updated, newStatus, comment),
          createdAt: DateTime.now(),
          isRead: false,
          deepLink: '/documents',
        ),
      );
    }

    return updated;
  }

  static String _bodyFor(
    AppDocument doc,
    DocumentStatus newStatus,
    String? comment,
  ) {
    final typeName = doc.type.shortDisplayName.toLowerCase();
    if (newStatus == DocumentStatus.approved) {
      return 'Tu documento de $typeName quedó aprobado por la administración.';
    }
    final reason = (comment == null || comment.trim().isEmpty)
        ? 'Revisa los comentarios y vuelve a subirlo.'
        : comment;
    return 'Tu documento de $typeName fue rechazado. $reason';
  }
}
