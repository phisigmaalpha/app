import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/supabase_config.dart';

class Membership extends StatefulWidget {
  @override
  State<Membership> createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  static const String _athMovilPhone = '9394993256';

  final _authService = AuthService();
  bool _paymentInitiated = false;
  bool _isValidating = false;

  Future<void> _openATHMovil() async {
    // El prefill (phone/amount/note) requiere cuenta ATH Business con
    // publicToken. Sin eso, solo podemos abrir la app en su pantalla por
    // defecto. El scheme real de ATH Móvil es `athm://`, extraído del SDK
    // open-source de Evertec (athmovil-ios-sdk).
    final athUri = Uri.parse('athm://');

    if (await canLaunchUrl(athUri)) {
      await launchUrl(athUri);
    } else {
      final storeUrl = Uri.parse(
        'https://apps.apple.com/app/ath-movil/id658539297',
      );
      await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copyPhoneNumber() async {
    final localizations = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: _athMovilPhone));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations?.numberCopied ?? 'Número copiado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _markPaymentDone() async {
    try {
      await supabase.rpc('request_payment_verification');
    } catch (_) {
      // No bloqueamos al usuario si el incremento falla.
    }
    if (!mounted) return;
    setState(() => _paymentInitiated = true);
  }

  Future<void> _validateActivation() async {
    final localizations = AppLocalizations.of(context);

    // Sin sesión activa no hay forma de validar: volver al login.
    if (_authService.currentSession == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() => _isValidating = true);

    try {
      final profile = await _authService.getCurrentUserProfile();
      if (!mounted) return;

      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations?.accountStillPending ??
                  'Tu cuenta aún no ha sido activada. Intenta más tarde.',
            ),
          ),
        );
        setState(() => _isValidating = false);
        return;
      }

      final isActive = profile['is_active'] as bool? ?? false;
      final expiresAt = profile['subscription_expires_at'] as String?;
      final isSubscribed =
          expiresAt != null &&
          DateTime.parse(expiresAt).isAfter(DateTime.now());

      if (isActive && isSubscribed) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Aún pendiente de activación o sin suscripción vigente.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations?.accountStillPending ??
                  'Tu cuenta aún no ha sido activada. Intenta más tarde.',
            ),
          ),
        );
        setState(() => _isValidating = false);
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final userEmail = supabase.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: _paymentInitiated
              ? _buildPendingApprovalView(localizations)
              : _buildPaymentView(localizations, userEmail),
        ),
      ),
    );
  }

  Widget _buildPaymentView(AppLocalizations? localizations, String userEmail) {
    return Column(
      children: [
        SizedBox(height: 40),
        SizedBox(
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
          localizations?.translate('subscriptionTitle') ?? 'Suscripcion Anual',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(24, 41, 163, 1),
          ),
        ),
        SizedBox(height: 8),
        Text(
          localizations?.translate('subscriptionDesc') ??
              'Para acceder a la app necesitas una suscripcion activa.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        Text(
          '\$20.00',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(24, 41, 163, 1),
          ),
        ),
        Text(
          localizations?.translate('perYear') ?? 'por ano',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
        SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(24, 41, 163, 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color.fromRGBO(24, 41, 163, 0.15)),
          ),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1A3D96), size: 24),
              SizedBox(height: 8),
              Text(
                localizations?.paymentNumberLabel ??
                    'Envía el pago al siguiente número:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color.fromRGBO(231, 182, 43, 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableText(
                      '939-499-3256',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3D96),
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: _copyPhoneNumber,
                      icon: Icon(Icons.copy, size: 20),
                      color: Color(0xFF1A3D96),
                      tooltip:
                          localizations?.copyNumber ?? 'Copiar número',
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(6),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                localizations?.paymentNoteInstruction ??
                    'Importante: agrega tu nombre o correo electrónico en la nota del pago para que podamos identificar tu transferencia y activar tu cuenta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF1A3D96),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _openATHMovil,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEC7625),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 24),
                SizedBox(width: 8),
                Text(
                  'Abrir ATH Movil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Tu cuenta se activara una vez verificado el pago',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
            SizedBox(width: 4),
            Text(
              'Procesado de forma segura',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
        SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _markPaymentDone,
            style: OutlinedButton.styleFrom(
              foregroundColor: Color.fromRGBO(24, 41, 163, 1),
              side: BorderSide(
                color: Color.fromRGBO(24, 41, 163, 1),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ya realicé el pago',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),
        GestureDetector(
          onTap: _logout,
          child: Text(
            localizations?.translate('logout') ?? 'Cerrar sesion',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPendingApprovalView(AppLocalizations? localizations) {
    return Column(
      children: [
        SizedBox(height: 60),
        Icon(
          Icons.hourglass_top,
          size: 96,
          color: Color.fromRGBO(231, 182, 43, 1),
        ),
        SizedBox(height: 24),
        Text(
          localizations?.accountPendingApproval ??
              'Cuenta pendiente de aprobación',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(24, 41, 163, 1),
          ),
        ),
        SizedBox(height: 16),
        Text(
          localizations?.accountPendingApprovalMessage ??
              'Tu cuenta fue creada correctamente. Un administrador debe aprobarla antes de que puedas ingresar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isValidating ? null : _validateActivation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(231, 182, 43, 1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isValidating
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    localizations?.validateActivation ?? 'Validar activación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: _logout,
          child: Text(
            localizations?.backToLogin ?? 'Volver al login',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(231, 182, 43, 1),
            ),
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }
}
