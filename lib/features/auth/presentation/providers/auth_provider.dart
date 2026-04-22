import 'package:flutter/material.dart';
import 'package:project_uts/features/auth/domain/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // =====================
  // LOGIN
  // =====================
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    await Future.delayed(const Duration(milliseconds: 500));

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email & password wajib diisi';
      _setStatus(AuthStatus.error);
      return false;
    }

    // 🔥 ROLE LOGIC
    String role;
    if (email == 'admin@mail.com') {
      role = 'admin';
    } else if (email == 'helpdesk@mail.com') {
      role = 'helpdesk';
    } else {
      role = 'user';
    }

    _user = UserModel(
      id: DateTime.now().toString(),
      name: email.split('@')[0],
      email: email,
      role: role,
    );

    _setStatus(AuthStatus.authenticated);
    return true;
  }

  // =====================
  // REGISTER (dummy)
  // =====================
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 500));

    _user = UserModel(
      id: DateTime.now().toString(),
      name: name,
      email: email,
      role: 'user',
    );

    _setStatus(AuthStatus.authenticated);
    return true;
  }

  // =====================
  // FORGOT PASSWORD (dummy)
  // =====================
  Future<bool> forgotPassword(String email) async {
    _setStatus(AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 500));

    _setStatus(AuthStatus.unauthenticated);
    return true;
  }

  // =====================
  // LOGOUT (HARUS Future)
  // =====================
  Future<void> logout() async {
    _setStatus(AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 300));

    _user = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  // =====================
  // SESSION
  // =====================
  Future<void> checkSession() async {
    _setStatus(AuthStatus.unauthenticated);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}