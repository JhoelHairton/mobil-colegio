import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';

/// Contrato del repositorio de gestión de usuarios.
///
/// Lo consume sólo el panel administrativo (admin/secretary). Cuando
/// llegue Firebase, la implementación cambia a queries de Firestore.
abstract class UsersRepository {
  /// Stream con todos los usuarios del catálogo institucional. Re-emite
  /// cuando se crea, suspende, reactiva o regenera código.
  Stream<List<AppUser>> watchAllUsers();

  /// Crea un usuario nuevo en estado [UserStatus.preregistered] con un
  /// código de activación de 8 caracteres y vencimiento a 90 días.
  /// Devuelve el usuario creado para que la UI pueda mostrar el
  /// código generado al admin.
  Future<AppUser> createUser({
    required String email,
    required String displayName,
    required UserRole role,
    String? phoneNumber,
    List<String> parentOfStudentIds,
    String? classroomCode,
    String? gradeLevel,
  });

  /// Cambia el estado de un usuario existente. Útil para suspender,
  /// reactivar o marcar como egresado.
  Future<AppUser> updateStatus(String uid, UserStatus newStatus);

  /// Genera un nuevo código de activación (de 8 caracteres) y resetea
  /// el vencimiento a 90 días. Sólo aplica a usuarios `preregistered`.
  Future<AppUser> regenerateActivationCode(String uid);
}
