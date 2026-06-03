import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  static Future<void> initialize() => Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );

  static SupabaseClient get _client => Supabase.instance.client;

  // ── Session ──────────────────────────────────────────────────────────────
  static User? get currentUser => _client.auth.currentUser;
  static Session? get currentSession => _client.auth.currentSession;
  static bool get isLoggedIn => currentSession != null;

  static String get userDisplayName {
    final user = currentUser;
    if (user == null) return 'Utilisateur';
    final meta = user.userMetadata;
    return (meta?['full_name'] as String?) ??
        (meta?['name'] as String?) ??
        user.email?.split('@').first ??
        'Utilisateur';
  }

  static String get userInitials {
    final name = userDisplayName.trim();
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) =>
      _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

  static Future<void> signOut() => _client.auth.signOut();

  static Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email.trim());
}
