import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';

/// Interfaz del repositorio de autenticación (modelo institucional v2.0).
///
/// La implementación vive en `data/`. Sprint 1-6 usa una versión mock;
/// Sprint 7+ se reemplaza por una contra Firebase Auth + Firestore.
abstract class AuthRepository {
  /// Stream del estado de autenticación. Emite el usuario actual al
  /// suscribirse y luego cada cambio (login, logout, activación).
  Stream<AppUser?> get authStateChanges;

  /// Usuario actualmente autenticado o `null`.
  AppUser? get currentUser;

  /// Iniciar sesión con correo y contraseña.
  ///
  /// Lanza [AuthException] cuando: el usuario no existe, la cuenta está
  /// `preregistered` (necesita activación), `suspended`, `graduated`, o
  /// la contraseña es incorrecta.
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Activar una cuenta `preregistered` con email + código de 8 caracteres
  /// + nueva contraseña. La cuenta queda autenticada al terminar.
  Future<AppUser> activateAccount({
    required String email,
    required String activationCode,
    required String newPassword,
  });

  /// Enviar correo de recuperación de contraseña.
  Future<void> sendPasswordResetEmail(String email);

  /// Cerrar sesión.
  Future<void> signOut();
}
