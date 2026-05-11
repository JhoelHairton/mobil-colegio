import 'package:agenda_escolar_adventista/core/errors/exceptions.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

/// Datasource en memoria para auth.
///
/// Sustituye al futuro datasource Firebase. Cuando llegue Sprint 7,
/// se crea otro datasource que implemente la misma interfaz pública
/// y el repository elige cuál inyectar.
class AuthMockDataSource {
  AuthMockDataSource();

  /// Operamos directamente sobre la lista global de [MockUsers] para
  /// que cualquier cambio del módulo de gestión de usuarios (crear,
  /// suspender, regenerar código) se refleje aquí sin tener que
  /// sincronizar dos copias.
  List<AppUser> get _users => MockUsers.all;

  /// Contraseñas mock por email. Coincide con [MockUsers].
  static const Map<String, String> _passwords = {
    'director@colegioadventistajuliaca.edu.pe': 'Admin123',
    'secretaria@colegioadventistajuliaca.edu.pe': 'Admin123',
    'profesora.flores@teacher.test': 'Docente123',
    'profesor.huanca@teacher.test': 'Docente123',
    'apoderado@familia.com': 'Padre123',
    'maria.aguilar@familia.com': 'Padre123',
    'mateo.mamani@student.test': 'Estudiante123',
    'sofia.mamani@student.test': 'Estudiante123',
    'lucas.aguilar@student.test': 'Estudiante123',
  };

  /// Latencia simulada para que el spinner no parpadee.
  static const Duration _latency = Duration(milliseconds: 600);

  // ─────────────────────────────────────────────────────────────
  // SIGN IN
  // ─────────────────────────────────────────────────────────────
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    final normalized = email.trim().toLowerCase();
    final user = _findByEmail(normalized);

    if (user == null) {
      throw AuthException('No existe una cuenta con ese correo.', code: 'user-not-found');
    }

    if (user.status == UserStatus.preregistered) {
      throw AuthException(
        'Tu cuenta aún no está activada. Usa "Activar mi cuenta" con el código que te dio el colegio.',
        code: 'preregistered',
      );
    }

    if (user.status == UserStatus.suspended) {
      throw AuthException(
        'Tu cuenta está suspendida. Comunícate con la secretaría del colegio.',
        code: 'suspended',
      );
    }

    if (user.status == UserStatus.graduated) {
      throw AuthException(
        'Esta cuenta ya egresó. El acceso está cerrado.',
        code: 'graduated',
      );
    }

    final expected = _passwords[normalized];
    if (expected == null || expected != password) {
      throw AuthException('Contraseña incorrecta.', code: 'wrong-password');
    }

    return user;
  }

  // ─────────────────────────────────────────────────────────────
  // ACTIVATE ACCOUNT
  // ─────────────────────────────────────────────────────────────

  /// Activa una cuenta `preregistered` validando email + código + setea contraseña.
  /// Devuelve el [AppUser] ya en estado `active`.
  Future<AppUser> activateAccount({
    required String email,
    required String activationCode,
    required String newPassword,
  }) async {
    await Future<void>.delayed(_latency);

    final normalized = email.trim().toLowerCase();
    final user = _findByEmail(normalized);

    if (user == null) {
      throw AuthException(
        'No encontramos una cuenta pre-registrada con ese correo.',
        code: 'user-not-found',
      );
    }

    if (user.status == UserStatus.active) {
      throw AuthException(
        'Esta cuenta ya está activada. Inicia sesión normalmente.',
        code: 'already-active',
      );
    }

    if (user.status != UserStatus.preregistered) {
      throw AuthException(
        'Esta cuenta no puede ser activada (estado: ${user.status.displayName}).',
        code: 'invalid-status',
      );
    }

    final code = activationCode.trim().toUpperCase();
    if (user.activationCode != code) {
      throw AuthException(
        'El código de activación no es correcto.',
        code: 'wrong-code',
      );
    }

    if (!user.isActivationCodeValid()) {
      throw AuthException(
        'El código expiró. Solicita uno nuevo en la secretaría.',
        code: 'expired-code',
      );
    }

    // Mutamos el usuario en memoria: lo activamos y guardamos contraseña.
    final activated = user.copyWith(
      status: UserStatus.active,
      clearActivationCode: true,
    );
    _replaceUser(activated);
    _passwords[normalized] = newPassword;

    return activated;
  }

  // ─────────────────────────────────────────────────────────────
  // PASSWORD RESET (mock)
  // ─────────────────────────────────────────────────────────────

  /// Mock: simulamos el envío de correo. Si el email no existe, igual
  /// retornamos OK (defensivo, no revelamos qué emails están en el sistema).
  Future<void> sendPasswordResetEmail(String email) async {
    await Future<void>.delayed(_latency);
    // No-op: en producción enviará un correo real.
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────
  AppUser? _findByEmail(String normalizedEmail) {
    for (final u in _users) {
      if (u.email.toLowerCase() == normalizedEmail) return u;
    }
    return null;
  }

  void _replaceUser(AppUser updated) {
    final i = _users.indexWhere((u) => u.uid == updated.uid);
    if (i >= 0) _users[i] = updated;
  }
}
