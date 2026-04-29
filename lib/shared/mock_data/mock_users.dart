import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';

/// Catálogo central de usuarios mock para todo el frontend-first.
///
/// Cubre los 5 roles, varios estados y un par de [UserStatus.preregistered]
/// con códigos válidos para probar el flujo de activación.
///
/// Contraseñas mock para usuarios `active`:
/// - `padres` y `apoderado@familia.com` → `Padre123`
/// - docentes → `Docente123`
/// - estudiantes → `Estudiante123`
/// - admin/secretary → `Admin123` (no usan app móvil)
///
/// Códigos de activación válidos (8 chars):
/// - `lucia.quispe@parent.test` → `KX72MN8P`
/// - `mateo.vargas@student.test` → `RJ4QH9LB`
/// - `prof.luna@teacher.test`    → `ZF31NX7C`
class MockUsers {
  MockUsers._();

  static final DateTime _baseDate = DateTime(2026, 1, 15);

  static final List<AppUser> all = [
    // ────────────────── ADMINISTRACIÓN (panel web) ──────────────────
    AppUser(
      uid: 'usr_admin_001',
      email: 'director@colegioadventistajuliaca.edu.pe',
      displayName: 'Pastor Jorge Mamani',
      role: UserRole.admin,
      status: UserStatus.active,
      phoneNumber: '+51 951 234 567',
      createdAt: _baseDate.subtract(const Duration(days: 365)),
    ),
    AppUser(
      uid: 'usr_secretary_001',
      email: 'secretaria@colegioadventistajuliaca.edu.pe',
      displayName: 'Lic. Rosario Apaza',
      role: UserRole.secretary,
      status: UserStatus.active,
      phoneNumber: '+51 951 234 568',
      createdAt: _baseDate.subtract(const Duration(days: 320)),
    ),

    // ─────────────────────── DOCENTES ───────────────────────
    AppUser(
      uid: 'usr_teacher_001',
      email: 'profesora.flores@teacher.test',
      displayName: 'Mg. Elena Flores Ccama',
      role: UserRole.teacher,
      status: UserStatus.active,
      phoneNumber: '+51 952 100 001',
      createdAt: _baseDate.subtract(const Duration(days: 280)),
    ),
    AppUser(
      uid: 'usr_teacher_002',
      email: 'profesor.huanca@teacher.test',
      displayName: 'Lic. Néstor Huanca Quispe',
      role: UserRole.teacher,
      status: UserStatus.active,
      phoneNumber: '+51 952 100 002',
      createdAt: _baseDate.subtract(const Duration(days: 210)),
    ),
    // Docente preregistrada — pendiente de activación
    AppUser(
      uid: 'usr_teacher_003',
      email: 'prof.luna@teacher.test',
      displayName: 'Mg. Patricia Luna Ticona',
      role: UserRole.teacher,
      status: UserStatus.preregistered,
      phoneNumber: '+51 952 100 003',
      activationCode: 'ZF31NX7C',
      activationCodeExpiresAt: _baseDate.add(const Duration(days: 88)),
      createdAt: _baseDate.subtract(const Duration(days: 2)),
    ),

    // ─────────────────────── PADRES ───────────────────────
    AppUser(
      uid: 'usr_parent_001',
      email: 'apoderado@familia.com',
      displayName: 'Carlos Mamani Condori',
      role: UserRole.parent,
      status: UserStatus.active,
      phoneNumber: '+51 953 200 001',
      parentOfStudentIds: ['usr_student_001', 'usr_student_002'],
      createdAt: _baseDate.subtract(const Duration(days: 240)),
    ),
    AppUser(
      uid: 'usr_parent_002',
      email: 'maria.aguilar@familia.com',
      displayName: 'María Aguilar de Vargas',
      role: UserRole.parent,
      status: UserStatus.active,
      phoneNumber: '+51 953 200 002',
      parentOfStudentIds: ['usr_student_003'],
      createdAt: _baseDate.subtract(const Duration(days: 180)),
    ),
    // Padre preregistrado — pendiente de activación
    AppUser(
      uid: 'usr_parent_003',
      email: 'lucia.quispe@parent.test',
      displayName: 'Lucía Quispe Mamani',
      role: UserRole.parent,
      status: UserStatus.preregistered,
      phoneNumber: '+51 953 200 003',
      parentOfStudentIds: ['usr_student_004'],
      activationCode: 'KX72MN8P',
      activationCodeExpiresAt: _baseDate.add(const Duration(days: 90)),
      createdAt: _baseDate.subtract(const Duration(days: 1)),
    ),
    // Padre suspendido (deuda institucional) — bloqueo de login
    AppUser(
      uid: 'usr_parent_004',
      email: 'pedro.choque@parent.test',
      displayName: 'Pedro Choque Mamani',
      role: UserRole.parent,
      status: UserStatus.suspended,
      phoneNumber: '+51 953 200 004',
      createdAt: _baseDate.subtract(const Duration(days: 200)),
    ),

    // ─────────────────────── ESTUDIANTES ───────────────────────
    AppUser(
      uid: 'usr_student_001',
      email: 'mateo.mamani@student.test',
      displayName: 'Mateo Mamani Vargas',
      role: UserRole.student,
      status: UserStatus.active,
      classroomCode: '5SEC-A',
      gradeLevel: '5° Secundaria',
      createdAt: _baseDate.subtract(const Duration(days: 240)),
    ),
    AppUser(
      uid: 'usr_student_002',
      email: 'sofia.mamani@student.test',
      displayName: 'Sofía Mamani Vargas',
      role: UserRole.student,
      status: UserStatus.active,
      classroomCode: '3SEC-B',
      gradeLevel: '3° Secundaria',
      createdAt: _baseDate.subtract(const Duration(days: 240)),
    ),
    AppUser(
      uid: 'usr_student_003',
      email: 'lucas.aguilar@student.test',
      displayName: 'Lucas Aguilar Vargas',
      role: UserRole.student,
      status: UserStatus.active,
      classroomCode: '4SEC-A',
      gradeLevel: '4° Secundaria',
      createdAt: _baseDate.subtract(const Duration(days: 180)),
    ),
    // Estudiante preregistrado
    AppUser(
      uid: 'usr_student_004',
      email: 'mateo.vargas@student.test',
      displayName: 'Mateo Vargas Quispe',
      role: UserRole.student,
      status: UserStatus.preregistered,
      classroomCode: '1SEC-A',
      gradeLevel: '1° Secundaria',
      activationCode: 'RJ4QH9LB',
      activationCodeExpiresAt: _baseDate.add(const Duration(days: 89)),
      createdAt: _baseDate.subtract(const Duration(days: 1)),
    ),
    // Estudiante egresado
    AppUser(
      uid: 'usr_student_005',
      email: 'andrea.luna@student.test',
      displayName: 'Andrea Luna Apaza',
      role: UserRole.student,
      status: UserStatus.graduated,
      classroomCode: '5SEC-B',
      gradeLevel: '5° Secundaria',
      createdAt: _baseDate.subtract(const Duration(days: 730)),
    ),
  ];

  /// Búsqueda por email (case-insensitive). Útil para el datasource mock.
  static AppUser? findByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final u in all) {
      if (u.email.toLowerCase() == normalized) return u;
    }
    return null;
  }
}
