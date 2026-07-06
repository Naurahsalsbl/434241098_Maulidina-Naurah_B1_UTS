import 'package:project_uts/features/user_management/data/user_management_datasource.dart';
import 'package:project_uts/features/auth/domain/user_model.dart';

class UserManagementRepository {
  final _datasource = UserManagementDatasource();

  Future<List<UserModel>> getAllUsers() => _datasource.getAllUsers();

  Future<void> setUserActive(String userId, bool isActive) =>
      _datasource.setUserActive(userId, isActive);
}