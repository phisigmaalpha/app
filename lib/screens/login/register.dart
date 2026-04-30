import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/components/inputEmail.dart';
import 'package:app/screens/components/inputPassword.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/supabase_config.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final localizations = AppLocalizations.of(context);

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      // Subir foto de perfil si se seleccionó
      if (_profileImage != null && _authService.currentUser != null) {
        final userId = _authService.currentUser!.id;
        final ext = _profileImage!.path.split('.').last;
        final path = 'avatars/$userId.$ext';

        await supabase.storage.from('documents').upload(path, _profileImage!);

        await supabase
            .from('users')
            .update({
              'biography': path,
            }) // usar biography como avatar_path temporalmente
            .eq('email', _emailController.text.trim());
      }

      if (!mounted) return;
      // Usuario queda inactivo hasta que un admin lo apruebe tras pagar.
      // Lo mandamos a la pantalla de pago.
      Navigator.pushReplacementNamed(context, '/membership');
    } catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.registrationError ??
                'Error al registrar. Intenta de nuevo.',
          ),
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                SizedBox(height: 20),
                // Foto de perfil
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Color.fromRGBO(24, 41, 163, 0.1),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: Color.fromRGBO(24, 41, 163, 1),
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  localizations?.addPhoto ?? 'Agregar foto (opcional)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                Text(
                  localizations?.register ?? 'Registro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(24, 41, 163, 1),
                  ),
                ),
                SizedBox(height: 24),
                // Nombre completo
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: localizations?.fullName ?? 'Nombre completo',
                    prefixIcon: Icon(
                      Icons.person_outlined,
                      color: Color.fromRGBO(231, 182, 43, 1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(231, 182, 43, 1),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return localizations?.nameRequired ?? 'Nombre requerido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                // Email
                CustomEmailField(
                  controller: _emailController,
                  label: localizations?.email ?? 'Email',
                  errorMessage:
                      localizations?.emailRequired ?? 'Email requerido',
                ),
                SizedBox(height: 12),
                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: localizations?.phone ?? 'Teléfono (opcional)',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: Color.fromRGBO(231, 182, 43, 1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(231, 182, 43, 1),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Contraseña
                CustomPasswordField(
                  controller: _passwordController,
                  label: localizations?.password ?? 'Contraseña',
                  errorMessage:
                      localizations?.passwordRequired ?? 'Contraseña requerida',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.passwordRequired ??
                          'Contraseña requerida';
                    }
                    if (value.length < 6) {
                      return localizations?.passwordMinLength ??
                          'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                // Confirmar contraseña
                CustomPasswordField(
                  controller: _confirmPasswordController,
                  label:
                      localizations?.confirmPassword ?? 'Confirmar contraseña',
                  errorMessage:
                      localizations?.passwordRequired ??
                      'Confirma tu contraseña',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.passwordRequired ??
                          'Confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return localizations?.passwordMismatch ??
                          'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                // Botón registrar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            localizations?.register ?? 'Registrarse',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                // Link a login
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    localizations?.alreadyHaveAccount ?? 'Ya tengo una cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(231, 182, 43, 1),
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
