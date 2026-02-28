import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Current user
  User? get currentUser => _client.auth.currentUser;

  // Session
  Session? get currentSession => _client.auth.currentSession;

  // Auth state changes stream
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  // Sign up with email & password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
    return response;
  }

  // Sign in with email & password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
