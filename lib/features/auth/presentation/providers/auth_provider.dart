import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_uts/features/auth/domain/user_model.dart';
import 'package:project_uts/core/constant/api_endpoints.dart';
import 'package:project_uts/core/network/supabase_client.dart';
import 'package:project_uts/core/storage/local_storage.dart' show AppStorage;

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

    try {
      final response = await SupabaseClientHelper.auth.signInWithPassword(
        email: email,
        password: password,
      );
      

      if (response.user == null) {
        _errorMessage = 'Login gagal, coba lagi';
        _setStatus(AuthStatus.error);
        return false;
      }

      await _loadUserProfile(response.user!.id);
      return _status == AuthStatus.authenticated;
    } on AuthException catch (e) {
      _errorMessage = _parseAuthError(e.message);
      _setStatus(AuthStatus.error);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan, coba lagi';
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // =====================
  // REGISTER
  // =====================
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      final response = await SupabaseClientHelper.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': 'user'},
      );

      if (response.user == null) {
        _errorMessage = 'Registrasi gagal, coba lagi';
        _setStatus(AuthStatus.error);
        return false;
      }

      // Insert ke tabel users
      await SupabaseClientHelper.client
          .from(ApiEndpoints.usersTable)
          .insert({
            'id': response.user!.id,
            'name': name,
            'email': email,
            'role': 'user',
          });

      _user = UserModel(
        id: response.user!.id,
        name: name,
        email: email,
        role: 'user',
      );

      await AppStorage.saveUserSession(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        role: _user!.role,
      );

      _setStatus(AuthStatus.authenticated);
      return true;
    } on AuthException catch (e) {
      _errorMessage = _parseAuthError(e.message);
      _setStatus(AuthStatus.error);
      return false;
    } catch (e) {
      print('REGISTER ERROR: $e');
      _errorMessage = 'Terjadi kesalahan, coba lagi';
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // =====================
  // FORGOT PASSWORD
  // =====================
  Future<bool> forgotPassword(String email) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      await SupabaseClientHelper.auth.resetPasswordForEmail(email);
      _setStatus(AuthStatus.unauthenticated);
      return true;
    } on AuthException catch (e) {
      _errorMessage = _parseAuthError(e.message);
      _setStatus(AuthStatus.error);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan, coba lagi';
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // =====================
  // LOGOUT
  // =====================
  Future<void> logout() async {
    _setStatus(AuthStatus.loading);

    try {
      await SupabaseClientHelper.auth.signOut();
      await AppStorage.clearUserSession();
    } catch (_) {
      // Tetap lanjut logout meski error
    } finally {
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // =====================
  // CEK SESSION (dipanggil di splash)
  // =====================
  Future<void> checkSession() async {
    _setStatus(AuthStatus.loading);

    try {
      final session = SupabaseClientHelper.auth.currentSession;

      

      if (session == null) {
        _setStatus(AuthStatus.unauthenticated);
        return;
      }

      final userId = session.user.id;
      await _loadUserProfile(userId);
    } catch (_) {
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // =====================
  // INTERNAL HELPERS
  // =====================

  /// Ambil profil user dari tabel `users` di Supabase
  Future<void> _loadUserProfile(String userId) async {
    try {
      final data = await SupabaseClientHelper.client
          .from(ApiEndpoints.usersTable)
          .select()
          .eq('id', userId)
          .single();

      _user = UserModel(
        id: data['id'],
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? 'user',
        avatar: data['avatar'],
        isActive: data['is_active'] ?? true,
      );

      // Akun dinonaktifkan Admin → paksa logout, tidak boleh masuk
      if (!_user!.isActive) {
        await SupabaseClientHelper.auth.signOut();
        await AppStorage.clearUserSession();
        _user = null;
        _errorMessage = 'Akun Anda telah dinonaktifkan. Hubungi Admin.';
        _setStatus(AuthStatus.error);
        return;
      }

      await AppStorage.saveUserSession(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        role: _user!.role,
        avatar: _user!.avatar,
      );

      _setStatus(AuthStatus.authenticated);
    } catch (_) {
      // Profil belum ada di tabel (misal baru register)
      // Fallback ke data dari auth
      final authUser = SupabaseClientHelper.auth.currentUser;
      if (authUser != null) {
        _user = UserModel(
          id: authUser.id,
          name: authUser.userMetadata?['name'] ?? '',
          email: authUser.email ?? '',
          role: authUser.userMetadata?['role'] ?? 'user',
        );
        _setStatus(AuthStatus.authenticated);
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    }
  }

  String _parseAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email atau password salah';
    } else if (message.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi, cek inbox kamu';
    } else if (message.contains('User already registered')) {
      return 'Email sudah terdaftar';
    } else if (message.contains('Password should be')) {
      return 'Password minimal 6 karakter';
    }
    return message;
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