import 'package:app/services/supabase_config.dart';

class AccountService {
  /// Elimina permanentemente la cuenta del usuario autenticado.
  /// Borra el perfil de la tabla `users` (CASCADE a memberships) y
  /// la cuenta en auth.users vía RPC con SECURITY DEFINER.
  Future<void> deleteAccount() async {
    await supabase.rpc('delete_user_account');
    await supabase.auth.signOut();
  }
}
