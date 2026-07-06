import 'package:flutter/foundation.dart';
import 'package:project_uts/features/user_management/data/user_management_repository.dart';
import 'package:project_uts/features/auth/domain/user_model.dart';

class UserManagementProvider extends ChangeNotifier {
  final _repository = UserManagementRepository();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalUsers => _users.length;
  int countByRole(String role) => _users.where((u) => u.role == role).length;

  // =========================
  // LOAD ALL USERS
  // =========================
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _repository.getAllUsers();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar pengguna';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // TOGGLE AKTIF / NONAKTIF
  // =========================
  Future<void> toggleActive(String userId, bool isActive) async {
    // Optimistic update supaya switch langsung responsif
    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    final previous = _users[index];
    _users[index] = previous.copyWith(isActive: isActive);
    notifyListeners();

    try {
      await _repository.setUserActive(userId, isActive);
    } catch (e) {
      // rollback kalau gagal
      _users[index] = previous;
      _errorMessage = 'Gagal mengubah status pengguna';
      notifyListeners();
    }
  }
}