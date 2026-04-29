import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: iniciar sesión.
class SignIn {
  final AuthRepository _repository;

  SignIn(this._repository);

  Future<AppUser> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
