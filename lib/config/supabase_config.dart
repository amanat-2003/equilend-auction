import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase configuration.
/// Replace [supabaseUrl] and [supabaseAnonKey] with your project credentials.
class SupabaseConfig {
  static const String supabaseUrl = 'https://mbnmouzzvmgygvacnlip.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ibm1vdXp6dm1neWd2YWNubGlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxODgxNDIsImV4cCI6MjA4Nzc2NDE0Mn0.X1fb0Fc6ko7wC9dTqNUtmrxhu1jXZQS4IjtIMaogmvw';

  static Future<void> init() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
