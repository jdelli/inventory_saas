import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  
  static const String supabaseServiceRole = String.fromEnvironment(
    'SUPABASE_SERVICE_ROLE',
    defaultValue: '',
  );

  static Future<void> initialize() async {
    print('🔧 SupabaseConfig: Initializing Supabase...');
    print('🔧 SupabaseConfig: URL: ${supabaseUrl.isNotEmpty ? "✅ Set" : "❌ Empty"}');
    print('🔧 SupabaseConfig: Anon Key: ${supabaseAnonKey.isNotEmpty ? "✅ Set" : "❌ Empty"}');
    
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      print('⚠️ SupabaseConfig: Missing environment variables - running in offline mode');
      print('⚠️ SupabaseConfig: SUPABASE_URL: ${supabaseUrl.isEmpty ? "MISSING" : "OK"}');
      print('⚠️ SupabaseConfig: SUPABASE_ANON_KEY: ${supabaseAnonKey.isEmpty ? "MISSING" : "OK"}');
      print('💡 SupabaseConfig: To enable database features, set these environment variables:');
      print('💡 SupabaseConfig: SUPABASE_URL=your_supabase_url');
      print('💡 SupabaseConfig: SUPABASE_ANON_KEY=your_supabase_anon_key');
      return; // Don't throw exception, just skip initialization
    }
    
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true, // Enable debug for development
      );
      print('✅ SupabaseConfig: Successfully initialized');
    } catch (e) {
      print('❌ SupabaseConfig: Failed to initialize: $e');
      print('⚠️ SupabaseConfig: Continuing in offline mode...');
      // Don't rethrow, allow app to continue
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
