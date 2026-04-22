import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientInstance {
  static SupabaseClient get client => Supabase.instance.client;
}