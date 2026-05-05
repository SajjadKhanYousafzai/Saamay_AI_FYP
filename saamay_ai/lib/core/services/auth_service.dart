import 'package:flutter/foundation.dart';
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

  // Platform specific redirect URL
  String get _redirectUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'com.saamayai.app://login-callback/';
    }
  }

  // Sign up with email & password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
        emailRedirectTo: _redirectUrl,
      );
      return response;
    } on AuthApiException catch (e) {
      throw Exception(_friendlyError(e));
    } catch (e) {
      throw Exception('Something went wrong. Please check your connection and try again.');
    }
  }

  // Sign in with email & password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthApiException catch (e) {
      throw Exception(_friendlyError(e));
    } catch (e) {
      throw Exception('Something went wrong. Please check your connection and try again.');
    }
  }

  // Reset password (send email)
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: _redirectUrl,
      );
    } on AuthApiException catch (e) {
      throw Exception(_friendlyError(e));
    } catch (e) {
      throw Exception('Something went wrong. Please check your connection and try again.');
    }
  }

  // Update password (after recovery email clicked)
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _client.auth.updateUser(UserAttributes(
        password: newPassword,
      ));
    } on AuthApiException catch (e) {
      throw Exception(_friendlyError(e));
    } catch (e) {
      throw Exception('Something went wrong. Please check your connection and try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Maps Supabase AuthApiException to user-friendly messages
  String _friendlyError(AuthApiException e) {
    final code = e.code?.toLowerCase() ?? '';
    final msg = e.message.toLowerCase();

    // Invalid credentials (wrong email or password)
    if (code == 'invalid_credentials' || msg.contains('invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }

    // User not found
    if (code == 'user_not_found' || msg.contains('user not found')) {
      return 'No account found with this email. Please sign up first.';
    }

    // Email already registered
    if (code == 'user_already_exists' || msg.contains('already registered')) {
      return 'This email is already registered. Try logging in instead.';
    }

    // Email not confirmed
    if (code == 'email_not_confirmed' || msg.contains('email not confirmed')) {
      return 'Please verify your email before logging in. Check your inbox.';
    }

    // Too many requests
    if (code == 'over_request_rate_limit' || msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    // Weak password
    if (msg.contains('password') && (msg.contains('weak') || msg.contains('short'))) {
      return 'Password is too weak. Use at least 6 characters.';
    }

    // Invalid email format
    if (msg.contains('invalid') && msg.contains('email')) {
      return 'Please enter a valid email address.';
    }

    // Network / connection errors
    if (msg.contains('network') || msg.contains('connection') || msg.contains('socket')) {
      return 'No internet connection. Please check your network.';
    }

    // Fallback — show a clean version of the original message
    return e.message.isNotEmpty
        ? e.message
        : 'Something went wrong. Please try again.';
  }
}
