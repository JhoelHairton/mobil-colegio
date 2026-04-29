import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: activar una cuenta preregistrada.
///
/// El admin pre-cargó al usuario en Excel y le entregó un código de 8
/// caracteres. El usuario lo combina con su email para activar la cuenta
/// y elegir una contraseña permanente.
class ActivateAccount {
  const ActivateAccount(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({
    required String email,
    required String activationCode,
    required String newPassword,
  }) {
    return _repository.activateAccount(
      email: email,
      activationCode: activationCode,
      newPassword: newPassword,
    );
  }
}
