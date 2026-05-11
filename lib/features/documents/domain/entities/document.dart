/// Entidad de documento de padre.
enum DocumentType { membership, discount, tithe }

enum DocumentStatus { pending, reviewing, approved, rejected }

class AppDocument {
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

  AppDocument copyWith({
    String? id,
    String? parentId,
    String? studentId,
    DocumentType? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    DocumentStatus? status,
    DateTime? uploadedAt,
    String? comments,
    bool clearComments = false,
  }) {
    return AppDocument(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      comments: clearComments ? null : (comments ?? this.comments),
    );
  }
}
