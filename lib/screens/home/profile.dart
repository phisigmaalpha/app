import 'package:flutter/material.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/supabase_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getCurrentUserProfile();
      if (mounted && profile != null) {
        setState(() {
          _profile = profile;
          _nameController.text = profile['full_name'] ?? '';
          _phoneController.text = profile['phone'] ?? '';
          _bioController.text = profile['biography'] ?? '';
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await supabase
          .from('users')
          .update({
            'full_name': _nameController.text.trim(),
            'phone': _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            'biography': _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
          })
          .eq('auth_uid', supabase.auth.currentUser!.id);

      await _loadProfile();
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Perfil actualizado')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar')));
      }
    }
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _changePassword() async {
    final emailController = TextEditingController(
      text: _profile?['email'] ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cambiar contraseña'),
        content: Text(
          'Se enviará un enlace de recuperación a tu correo electrónico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await supabase.auth.resetPasswordForEmail(emailController.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Revisa tu correo para cambiar la contraseña',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al enviar el correo')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(231, 182, 43, 1),
              foregroundColor: Colors.white,
            ),
            child: Text('Enviar'),
          ),
        ],
      ),
    );
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.fromRGBO(231, 182, 43, 1),
          ),
        ),
      );
    }

    if (_profile == null) {
      return Center(
        child: Text(
          'No se pudo cargar el perfil',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final subscriptionExpires = _profile!['subscription_expires_at'] as String?;
    final isSubscribed =
        subscriptionExpires != null &&
        DateTime.parse(subscriptionExpires).isAfter(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),

          // Suscripción
          _buildCard(
            icon: Icons.card_membership,
            title: 'Suscripción',
            child: Row(
              children: [
                Icon(
                  isSubscribed ? Icons.check_circle : Icons.warning,
                  color: isSubscribed ? Colors.green : Colors.orange,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  isSubscribed
                      ? 'Activa hasta ${_formatDate(subscriptionExpires!)}'
                      : 'Sin suscripción activa',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSubscribed
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Datos personales
          _buildCard(
            icon: Icons.person_outline,
            title: 'Datos personales',
            trailing: IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: Color.fromRGBO(231, 182, 43, 1),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    // Cancelar: restaurar valores
                    _nameController.text = _profile!['full_name'] ?? '';
                    _phoneController.text = _profile!['phone'] ?? '';
                    _bioController.text = _profile!['biography'] ?? '';
                  }
                  _isEditing = !_isEditing;
                });
              },
            ),
            child: _isEditing ? _buildEditForm() : _buildProfileInfo(),
          ),
          SizedBox(height: 12),

          // Cambiar contraseña
          _buildCard(
            icon: Icons.lock_outline,
            title: 'Cambiar contraseña',
            onTap: _changePassword,
            child: Text(
              'Enviar enlace de recuperación al correo',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 24),

          // Cerrar sesión
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: Icon(Icons.logout, color: Colors.red[400]),
              label: Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red[400]),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Nombre', _profile!['full_name'] ?? '-'),
        _infoRow('Teléfono', _profile!['phone'] ?? 'No registrado'),
        _infoRow('Biografía', _profile!['biography'] ?? 'Sin biografía'),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nombre completo',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Teléfono',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Biografía',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(231, 182, 43, 1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSaving
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text('Guardar'),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(24, 41, 163, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color.fromRGBO(24, 41, 163, 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: Color.fromRGBO(231, 182, 43, 1)),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(24, 41, 163, 1),
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                  if (trailing != null) trailing,
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                ],
              ),
              SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
  }
}
