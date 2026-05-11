import 'dart:async';
import 'dart:math';

import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

/// Datasource en memoria para gestión de usuarios.
///
/// Opera directamente sobre [MockUsers.all] (lista mutable) para que
/// los cambios sean visibles también en `auth`, `documents`, etc. sin
/// necesidad de sincronizar copias.
class UsersMockDataSource {
  UsersMockDataSource();

  StreamController<List<AppUser>>? _controller;

  static const Duration _initialLatency = Duration(milliseconds: 450);
  static const Duration _writeLatency = Duration(milliseconds: 600);

  /// Sin caracteres ambiguos (sin O/0, I/1) para que el código se
  /// pueda dictar por teléfono sin confusión.
  static const String _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final _random = Random();

  Stream<List<AppUser>> watchAllUsers() {
    final controller =
        _controller ??= StreamController<List<AppUser>>.broadcast();

    Future<void>.delayed(_initialLatency, () {
      if (!controller.isClosed) controller.add(_sortedAll());
    });

    return controller.stream;
  }

  Future<AppUser> createUser({
    required String email,
    required String displayName,
    required UserRole role,
    String? phoneNumber,
    List<String> parentOfStudentIds = const [],
    String? classroomCode,
    String? gradeLevel,
  }) async {
    await Future<void>.delayed(_writeLatency);

    final normalizedEmail = email.trim().toLowerCase();
    if (MockUsers.findByEmail(normalizedEmail) != null) {
      throw StateError('Ya existe una cuenta con ese correo.');
    }

    final now = DateTime.now();
    final user = AppUser(
      uid: 'usr_${role.value}_${now.millisecondsSinceEpoch}',
      email: normalizedEmail,
      displayName: displayName.trim(),
      role: role,
      status: UserStatus.preregistered,
      phoneNumber: phoneNumber?.trim().isEmpty ?? true
          ? null
          : phoneNumber!.trim(),
      activationCode: _generateActivationCode(),
      activationCodeExpiresAt: now.add(const Duration(days: 90)),
      parentOfStudentIds: parentOfStudentIds,
      classroomCode: classroomCode?.trim().isEmpty ?? true
          ? null
          : classroomCode!.trim(),
      gradeLevel: gradeLevel?.trim().isEmpty ?? true
          ? null
          : gradeLevel!.trim(),
      createdAt: now,
    );

    MockUsers.all.add(user);
    _emit();
    return user;
  }

  Future<AppUser> updateStatus(String uid, UserStatus newStatus) async {
    await Future<void>.delayed(_writeLatency);
    final index = MockUsers.all.indexWhere((u) => u.uid == uid);
    if (index == -1) {
      throw StateError('Usuario $uid no encontrado.');
    }
    final updated = MockUsers.all[index].copyWith(
      status: newStatus,
      // Si pasamos a active, limpiamos el código de activación.
      clearActivationCode: newStatus == UserStatus.active,
    );
    MockUsers.all[index] = updated;
    _emit();
    return updated;
  }

  Future<AppUser> regenerateActivationCode(String uid) async {
    await Future<void>.delayed(_writeLatency);
    final index = MockUsers.all.indexWhere((u) => u.uid == uid);
    if (index == -1) {
      throw StateError('Usuario $uid no encontrado.');
    }
    final current = MockUsers.all[index];
    if (current.status != UserStatus.preregistered) {
      throw StateError(
        'Sólo se puede regenerar el código de cuentas preregistradas.',
      );
    }
    final updated = current.copyWith(
      activationCode: _generateActivationCode(),
      activationCodeExpiresAt:
          DateTime.now().add(const Duration(days: 90)),
    );
    MockUsers.all[index] = updated;
    _emit();
    return updated;
  }

  // ─────────────────────── helpers ───────────────────────

  String _generateActivationCode() {
    return List.generate(
      8,
      (_) => _codeAlphabet[_random.nextInt(_codeAlphabet.length)],
    ).join();
  }

  /// Lista ordenada: preregistrados primero (acción pendiente), luego
  /// activos, suspendidos y egresados. Dentro de cada grupo, por
  /// fecha de creación descendente.
  List<AppUser> _sortedAll() {
    int rank(UserStatus s) {
      switch (s) {
        case UserStatus.preregistered:
          return 0;
        case UserStatus.active:
          return 1;
        case UserStatus.suspended:
          return 2;
        case UserStatus.graduated:
          return 3;
      }
    }

    final list = [...MockUsers.all];
    list.sort((a, b) {
      final byStatus = rank(a.status).compareTo(rank(b.status));
      if (byStatus != 0) return byStatus;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  void _emit() {
    final controller = _controller;
    if (controller != null && !controller.isClosed) {
      controller.add(_sortedAll());
    }
  }
}
