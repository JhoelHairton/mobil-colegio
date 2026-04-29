/// Estados del ciclo de vida de una cuenta institucional (v2.0).
///
/// Flujo típico:
/// `preregistered` → (activación con código) → `active`
/// `active` → (decisión institucional) → `suspended` o `graduated`
enum UserStatus {
  /// Pre-cargado por el admin desde Excel. No puede iniciar sesión
  /// hasta activar con email + código de 8 caracteres.
  preregistered('preregistered', 'Pre-registrado'),

  /// Cuenta activada y operativa.
  active('active', 'Activo'),

  /// Suspendido por la institución (pago, conducta, etc).
  /// No puede iniciar sesión.
  suspended('suspended', 'Suspendido'),

  /// El estudiante egresó. Cuenta histórica, sin acceso.
  graduated('graduated', 'Egresado');

  const UserStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Convierte un valor crudo a [UserStatus]. Si no encaja, retorna
  /// [preregistered] como fallback conservador.
  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => UserStatus.preregistered,
    );
  }

  /// Si la cuenta puede iniciar sesión.
  bool get canSignIn => this == UserStatus.active;

  /// Si la cuenta está pendiente de activación con código.
  bool get needsActivation => this == UserStatus.preregistered;
}
