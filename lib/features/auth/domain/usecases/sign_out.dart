import 'package:agenda_escolar_adventista/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: cerrar sesión.
class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<void> call() => _repository.signOut();
}
