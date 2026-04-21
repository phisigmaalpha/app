import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/supabase_config.dart';

class AuthService {
  /// Sign in with email and password using Supabase Auth.
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Get the current authenticated user.
  User? get currentUser => supabase.auth.currentUser;

  /// Get the current session.
  Session? get currentSession => supabase.auth.currentSession;

  /// Fetch the user profile for the currently logged-in user.
  /// Uses RPC to link auth_uid (bypasses RLS), then fetches profile by auth_uid.
  /// Returns null solo si el usuario no existe en la tabla `users`.
  /// El flag `is_active` se devuelve en el perfil para que el caller decida
  /// si puede entrar al home o debe ver la pantalla de pendiente.
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    // Vincular auth_uid via RPC (SECURITY DEFINER, bypasa RLS)
    await supabase.rpc('link_auth_uid');

    final response = await supabase
        .from('users')
        .select('*')
        .eq('auth_uid', user.id)
        .maybeSingle();

    return response;
  }

  /// Register a new user: creates Supabase Auth account + users table record.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    // 1. Crear cuenta en Supabase Auth
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Error al crear la cuenta');
    }

    // 2. Hacer login para tener sesión activa (signUp puede no auto-loguear)
    if (response.session == null) {
      await supabase.auth.signInWithPassword(email: email, password: password);
    }

    // 3. Crear perfil en tabla users via RPC (bypasa RLS)
    await supabase.rpc(
      'register_user',
      params: {'p_full_name': fullName, 'p_email': email, 'p_phone': phone},
    );

    // 4. Vincular auth_uid
    await supabase.rpc('link_auth_uid');
  }

  /// Check if the current user has an active subscription.
  Future<bool> isSubscriptionActive() async {
    final profile = await getCurrentUserProfile();
    if (profile == null) return false;

    final expiresAt = profile['subscription_expires_at'] as String?;
    if (expiresAt == null) return false;

    return DateTime.parse(expiresAt).isAfter(DateTime.now());
  }
}
