/// Roles del sistema (modelo institucional v2.0 — 5 roles).
///
/// Plataforma:
/// - [admin], [secretary] → panel web.
/// - [teacher], [parent], [student] → app móvil.
enum UserRole {
  admin('admin', 'Administrador'),
  secretary('secretary', 'Secretaría'),
  teacher('teacher', 'Docente'),
  parent('parent', 'Padre de familia'),
  student('student', 'Estudiante');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Convierte un valor crudo a [UserRole]. Si no encaja, retorna [parent].
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => UserRole.parent,
    );
  }

  // Helpers booleanos
  bool get isAdmin => this == UserRole.admin;
  bool get isSecretary => this == UserRole.secretary;
  bool get isTeacher => this == UserRole.teacher;
  bool get isParent => this == UserRole.parent;
  bool get isStudent => this == UserRole.student;

  /// Roles con acceso al panel web administrativo.
  bool get hasAdminAccess => isAdmin || isSecretary;

  /// Roles que usan la app móvil (no el panel web).
  bool get isMobileUser => isTeacher || isParent || isStudent;
}
