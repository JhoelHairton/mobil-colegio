import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';

/// Entidad de usuario en el dominio (modelo institucional v2.0).
///
/// El admin pre-carga usuarios desde Excel y el sistema genera un
/// [activationCode] de 8 caracteres con vigencia de 90 días. El
/// usuario activa la cuenta con email + código + nueva contraseña.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    required this.createdAt,
    this.phoneNumber,
    this.photoUrl,
    this.activationCode,
    this.activationCodeExpiresAt,
    this.parentOfStudentIds = const <String>[],
    this.classroomCode,
    this.gradeLevel,
  });

  /// Identificador único.
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;

  final String? phoneNumber;
  final String? photoUrl;

  /// Código de 8 caracteres generado por el sistema cuando el admin
  /// pre-registra al usuario. Sólo presente mientras [status] es
  /// [UserStatus.preregistered]. Tras la activación se limpia.
  final String? activationCode;

  /// Vencimiento del [activationCode] (90 días por defecto).
  final DateTime? activationCodeExpiresAt;

  /// IDs de los hijos vinculados (sólo cuando [role] es [UserRole.parent]).
  final List<String> parentOfStudentIds;

  /// Código de aula (sólo cuando [role] es [UserRole.student]). Ej: "5SEC-A".
  final String? classroomCode;

  /// Grado del estudiante (sólo cuando [role] es [UserRole.student]).
  /// Ej: "5° Secundaria".
  final String? gradeLevel;

  /// Si el código de activación todavía es válido en [now].
  bool isActivationCodeValid({DateTime? now}) {
    if (activationCode == null || activationCodeExpiresAt == null) return false;
    final reference = now ?? DateTime.now();
    return reference.isBefore(activationCodeExpiresAt!);
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    String? phoneNumber,
    String? photoUrl,
    String? activationCode,
    DateTime? activationCodeExpiresAt,
    List<String>? parentOfStudentIds,
    String? classroomCode,
    String? gradeLevel,
    bool clearActivationCode = false,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      activationCode: clearActivationCode
          ? null
          : (activationCode ?? this.activationCode),
      activationCodeExpiresAt: clearActivationCode
          ? null
          : (activationCodeExpiresAt ?? this.activationCodeExpiresAt),
      parentOfStudentIds: parentOfStudentIds ?? this.parentOfStudentIds,
      classroomCode: classroomCode ?? this.classroomCode,
      gradeLevel: gradeLevel ?? this.gradeLevel,
    );
  }
}
