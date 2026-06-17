import 'package:supabase_flutter/supabase_flutter.dart';

/// Shortcut global untuk akses Supabase client di mana saja
/// Penggunaan: SupabaseClientHelper.client
class SupabaseClientHelper {
  SupabaseClientHelper._();

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  /// Cek apakah user sedang login
  static bool get isLoggedIn => client.auth.currentUser != null;

  /// Ambil user yang sedang login
  static User? get currentUser => client.auth.currentUser;

  /// Ambil user ID yang sedang login
  static String? get currentUserId => client.auth.currentUser?.id;
}