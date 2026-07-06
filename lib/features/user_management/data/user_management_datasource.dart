import 'package:project_uts/core/constant/api_endpoints.dart';
import 'package:project_uts/core/network/supabase_client.dart';
import 'package:project_uts/features/auth/domain/user_model.dart';

class UserManagementDatasource {
  final _client = SupabaseClientHelper.client;

  // =========================
  // GET ALL USERS
  // =========================
  Future<List<UserModel>> getAllUsers() async {
    final response = await _client
        .from(ApiEndpoints.usersTable)
        .select()
        .order('name', ascending: true);

    return (response as List).map((e) => UserModel.fromJson(e)).toList();
  }

  // =========================
  // TOGGLE AKTIF / NONAKTIF
  // =========================
  Future<void> setUserActive(String userId, bool isActive) async {
    await _client
        .from(ApiEndpoints.usersTable)
        .update({'is_active': isActive})
        .eq('id', userId);
  }
}