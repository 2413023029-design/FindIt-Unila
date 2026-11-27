/// Konfigurasi Supabase menggunakan --dart-define (tanpa service_role key).
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Callback deep link Android untuk verifikasi email & auth PKCE Supabase.
  static const String authCallbackScheme = 'io.supabase.finditunila';
  static const String authCallbackHost = 'login-callback';
  static const String authCallbackUrl =
      '$authCallbackScheme://$authCallbackHost/';

  static bool get isConfigured =>
      url.trim().isNotEmpty && anonKey.trim().isNotEmpty;
}
