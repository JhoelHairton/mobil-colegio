import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/repositories/auth_repository.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/usecases/activate_account.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/usecases/sign_in.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/usecases/sign_out.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

// ─────────────────────────────────────────────────────────────
// DATA SOURCES
// ─────────────────────────────────────────────────────────────
final authMockDataSourceProvider = Provider<AuthMockDataSource>((ref) {
  return AuthMockDataSource();
});

// ─────────────────────────────────────────────────────────────
// REPOSITORY
// ─────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authMockDataSourceProvider));
});

// ─────────────────────────────────────────────────────────────
// USE CASES
// ─────────────────────────────────────────────────────────────
final signInUseCaseProvider = Provider<SignIn>((ref) {
  return SignIn(ref.read(authRepositoryProvider));
});

final activateAccountUseCaseProvider = Provider<ActivateAccount>((ref) {
  return ActivateAccount(ref.read(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  return SignOut(ref.read(authRepositoryProvider));
});

// ─────────────────────────────────────────────────────────────
// AUTH STATE
// ─────────────────────────────────────────────────────────────

/// Stream del estado de autenticación.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

/// Usuario actual sincronizado (sin loading/error).
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Hijos vinculados al padre actualmente autenticado.
///
/// Lista vacía si no hay sesión, si el rol no es [UserRole.parent] o si
/// los uids declarados en [AppUser.parentOfStudentIds] no resuelven a
/// usuarios del catálogo mock. Cuando se conecte Firebase, se reemplaza
/// por una consulta al repositorio de usuarios.
final currentParentChildrenProvider = Provider<List<AppUser>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role != UserRole.parent) {
    return const <AppUser>[];
  }
  return user.parentOfStudentIds
      .map(MockUsers.findById)
      .whereType<AppUser>()
      .toList(growable: false);
});
