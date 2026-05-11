import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';
import 'package:agenda_escolar_adventista/features/users_management/data/datasources/users_mock_datasource.dart';
import 'package:agenda_escolar_adventista/features/users_management/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl(this._dataSource);

  final UsersMockDataSource _dataSource;

  @override
  Stream<List<AppUser>> watchAllUsers() => _dataSource.watchAllUsers();

  @override
  Future<AppUser> createUser({
    required String email,
    required String displayName,
    required UserRole role,
    String? phoneNumber,
    List<String> parentOfStudentIds = const [],
    String? classroomCode,
    String? gradeLevel,
  }) {
    return _dataSource.createUser(
      email: email,
      displayName: displayName,
      role: role,
      phoneNumber: phoneNumber,
      parentOfStudentIds: parentOfStudentIds,
      classroomCode: classroomCode,
      gradeLevel: gradeLevel,
    );
  }

  @override
  Future<AppUser> updateStatus(String uid, UserStatus newStatus) =>
      _dataSource.updateStatus(uid, newStatus);

  @override
  Future<AppUser> regenerateActivationCode(String uid) =>
      _dataSource.regenerateActivationCode(uid);
}
