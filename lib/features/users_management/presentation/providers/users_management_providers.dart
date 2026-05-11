import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';
import 'package:agenda_escolar_adventista/features/users_management/data/datasources/users_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/users_management/data/repositories/users_repository_impl.dart';
import 'package:agenda_escolar_adventista/features/users_management/domain/repositories/users_repository.dart';

// ─────────────────────────────────────────────────────────────────────────
// REPO + DATASOURCE
// ─────────────────────────────────────────────────────────────────────────

final usersMockDataSourceProvider = Provider<UsersMockDataSource>((ref) {
  return UsersMockDataSource();
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl(ref.watch(usersMockDataSourceProvider));
});

// ─────────────────────────────────────────────────────────────────────────
// STREAM Y FILTROS
// ─────────────────────────────────────────────────────────────────────────

final allUsersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(usersRepositoryProvider).watchAllUsers();
});

/// Filtro por rol. `null` = todos los roles.
final usersFilterRoleProvider = StateProvider<UserRole?>((ref) => null);

/// Búsqueda libre por nombre o email.
final usersSearchQueryProvider = StateProvider<String>((ref) => '');

/// Lista filtrada según rol seleccionado y búsqueda.
final filteredUsersProvider = Provider<AsyncValue<List<AppUser>>>((ref) {
  final asyncList = ref.watch(allUsersStreamProvider);
  final role = ref.watch(usersFilterRoleProvider);
  final query = ref.watch(usersSearchQueryProvider).trim().toLowerCase();

  return asyncList.whenData((users) {
    Iterable<AppUser> result = users;
    if (role != null) {
      result = result.where((u) => u.role == role);
    }
    if (query.isNotEmpty) {
      result = result.where(
        (u) =>
            u.displayName.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query),
      );
    }
    return result.toList(growable: false);
  });
});

/// Conteos por rol para mostrar en chips.
final usersCountByRoleProvider = Provider<Map<UserRole, int>>((ref) {
  final asyncList = ref.watch(allUsersStreamProvider);
  final base = {for (final r in UserRole.values) r: 0};
  return asyncList.maybeWhen(
    data: (users) {
      final counts = Map<UserRole, int>.from(base);
      for (final u in users) {
        counts[u.role] = (counts[u.role] ?? 0) + 1;
      }
      return counts;
    },
    orElse: () => base,
  );
});

/// Cantidad de cuentas preregistradas pendientes de activar (KPI).
final pendingActivationsCountProvider = Provider<int>((ref) {
  final asyncList = ref.watch(allUsersStreamProvider);
  return asyncList.maybeWhen(
    data: (users) =>
        users.where((u) => u.status == UserStatus.preregistered).length,
    orElse: () => 0,
  );
});
