import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/services/athmovil_service.dart';
import 'package:app/services/supabase_config.dart';

class Membership extends StatefulWidget {
  @override
  _MembershipState createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _athMovilService = ATHMovilService();
  bool _isProcessing = false;
  String _paymentStatus = '';

  Future<void> _startPayment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isProcessing = true;
      _paymentStatus = '';
    });

    try {
      final success = await _athMovilService.processPayment(
        total: 50.00, // TODO: monto de la membresía
        phoneNumber: _phoneController.text.trim(),
        onStatusChange: (status) {
          if (mounted) {
            setState(() => _paymentStatus = status);
          }
        },
      );

      if (!mounted) return;

      if (success) {
        // Actualizar suscripción en la base de datos
        final now = DateTime.now().toIso8601String();
        final expiresAt = DateTime.now()
            .add(const Duration(days: 365))
            .toIso8601String();

        await supabase
            .from('users')
            .update({
              'last_subscription_payment': now,
              'subscription_expires_at': expiresAt,
              'is_active': true,
            })
            .eq('auth_uid', supabase.auth.currentUser!.id);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _paymentStatus == 'CANCEL'
                  ? 'Pago cancelado o expirado'
                  : 'Error en el pago',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  String _statusMessage() {
    switch (_paymentStatus) {
      case 'CREATING':
        return 'Creando transacción...';
      case 'OPEN':
        return 'Confirma el pago en tu app ATH Móvil';
      case 'CONFIRM':
        return 'Pago confirmado, autorizando...';
      case 'AUTHORIZING':
        return 'Procesando pago...';
      case 'COMPLETED':
        return 'Pago completado';
      case 'CANCEL':
        return 'Pago cancelado';
      default:
        return '';
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
                SizedBox(height: 40),
                Container(
                  width: 160,
                  height: 160,
                  child: Image.asset(
                    'assets/logo.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  localizations?.translate('subscriptionTitle') ??
                      'Suscripción Anual',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(24, 41, 163, 1),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  localizations?.translate('subscriptionDesc') ??
                      'Para acceder a la app necesitas una suscripción activa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                // Monto
                Text(
                  '\$50.00',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(24, 41, 163, 1),
                  ),
                ),
                Text(
                  localizations?.translate('perYear') ?? 'por año',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 32),
                // Teléfono ATH Movil
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: localizations?.translate('athPhone') ??
                        'Teléfono ATH Móvil',
                    hintText: '787-123-4567',
                    prefixIcon: Icon(
                      Icons.phone_android,
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
                      return 'Teléfono requerido';
                    }
                    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digits.length < 10) {
                      return 'Teléfono inválido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Botón ATH Movil
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _startPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEC7625), // ATH Movil orange
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                _statusMessage(),
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment, size: 24),
                              SizedBox(width: 8),
                              Text(
                                localizations?.translate('payWithATH') ??
                                    'Pagar con ATH Móvil',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 12),
                // Mensaje de seguridad
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
                    SizedBox(width: 4),
                    Text(
                      localizations?.translate('securePayment') ??
                          'Procesado de forma segura',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // Cerrar sesión
                GestureDetector(
                  onTap: _logout,
                  child: Text(
                    localizations?.translate('logout') ?? 'Cerrar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
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
