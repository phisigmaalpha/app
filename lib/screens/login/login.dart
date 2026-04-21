import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/password/changePassword.dart';
import 'package:app/screens/components/inputEmail.dart';
import 'package:app/screens/components/inputPassword.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/screens/login/register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final localizations = AppLocalizations.of(context);

    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Verificar suscripción antes de ir al home
      final profile = await _authService.getCurrentUserProfile();
      if (!mounted) return;

      if (profile == null) {
        // Usuario autenticado pero sin fila en tabla users
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations?.invalidCredentials ?? 'Credenciales inválidas',
            ),
          ),
        );
        await _authService.signOut();
        setState(() => _isLoading = false);
        return;
      }

      final isActive = profile['is_active'] as bool? ?? false;
      final expiresAt = profile['subscription_expires_at'] as String?;
      final isSubscribed = expiresAt != null &&
          DateTime.parse(expiresAt).isAfter(DateTime.now());

      if (isActive && isSubscribed) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Inactivo (pendiente de aprobación) o sin suscripción → membership
        Navigator.pushReplacementNamed(context, '/membership');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.invalidCredentials ?? 'Credenciales inválidas',
          ),
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 40),
                Container(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/logo.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  localizations?.phiSigmaAlpha ?? 'PHI SIGMA ALPHA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(24, 41, 163, 1),
                  ),
                ),
                SizedBox(height: 30),
                CustomEmailField(
                  controller: _emailController,
                  label: localizations?.email ?? 'Email',
                  errorMessage:
                      localizations?.emailRequired ?? 'Email required',
                ),
                SizedBox(height: 10),
                CustomPasswordField(
                  controller: _passwordController,
                  label: localizations?.password ?? 'Password',
                  errorMessage:
                      localizations?.passwordRequired ?? 'Password required',
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(231, 182, 43, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            localizations?.login ?? 'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    localizations?.forgotPassword ?? 'Forgot my password',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(231, 182, 43, 1),
                    ),
                  ),
                ),
                SizedBox(height: 100),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    localizations?.wantToBecome ?? 'I want to become a member',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(231, 182, 43, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
