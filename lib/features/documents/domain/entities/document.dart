/// Entidad de documento de padre.
enum DocumentType { membership, discount, tithe }

enum DocumentStatus { pending, reviewing, approved, rejected }

class AppDocument {
  final String id;
  final String parentId;
  final String? studentId;
  final DocumentType type;
  final String fileUrl;
  final String fileName;
  final int fileSize;
  final DocumentStatus status;
  final DateTime uploadedAt;
  final String? comments;

  const AppDocument({
    required this.id,
    required this.parentId,
    required this.type,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.status,
    required this.uploadedAt,
    this.studentId,
    this.comments,
  });
}
