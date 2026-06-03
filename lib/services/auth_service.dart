import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  static Future<AuthResponse> signIn(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  static Future<AuthResponse> signUp(String email, String password) =>
      _client.auth.signUp(email: email, password: password);

  static Future<void> signOut() => _client.auth.signOut();

  static User? getCurrentUser() => _client.auth.currentUser;

  static Future<bool> signInWithGoogle() =>
      _client.auth.signInWithOAuth(OAuthProvider.google);
}
