import 'dart:async';

import 'package:agenda_escolar_adventista/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/repositories/auth_repository.dart';

/// Implementación de [AuthRepository] respaldada por [AuthMockDataSource].
///
/// Mantiene el [currentUser] en memoria y emite por [authStateChanges]
/// cada cambio (sign in, sign out, activación que también loguea).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthMockDataSource _dataSource;
  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> get authStateChanges async* {
    // Emite el estado actual al suscribirse y luego sigue con los cambios.
    yield _currentUser;
    yield* _authStateController.stream;
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = await _dataSource.signIn(email: email, password: password);
    _emit(user);
    return user;
  }

  @override
  Future<AppUser> activateAccount({
    required String email,
    required String activationCode,
    required String newPassword,
  }) async {
    final user = await _dataSource.activateAccount(
      email: email,
      activationCode: activationCode,
      newPassword: newPassword,
    );
    _emit(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() async {
    _emit(null);
  }

  void _emit(AppUser? user) {
    _currentUser = user;
    _authStateController.add(user);
  }
}
