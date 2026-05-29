import 'dart:math';

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

  // Tutorial guiado: 0 = resaltar botón copiar, 1 = resaltar botón ATH Móvil,
  // 2 = tutorial completado (sin animaciones).
  int _tutorialStep = 0;

  Future<void> _openATHMovil() async {
    // El prefill (phone/amount/note) requiere cuenta ATH Business con
    // publicToken. Sin eso, solo podemos abrir la app en su pantalla por
    // defecto. El scheme real de ATH Móvil es `athm://`, extraído del SDK
    // open-source de Evertec (athmovil-ios-sdk).
    final athUri = Uri.parse('athm://');

    // Avanza el tutorial: ya se pulsó el botón de ATH Móvil, lo damos por hecho.
    if (_tutorialStep == 1) {
      setState(() => _tutorialStep = 2);
    }

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
    // Avanza el tutorial: tras copiar, resaltamos el botón de ATH Móvil.
    if (_tutorialStep == 0) {
      setState(() => _tutorialStep = 1);
    }
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
                    _ShakeAttention(
                      active: _tutorialStep == 0,
                      child: IconButton(
                        onPressed: _copyPhoneNumber,
                        icon: Icon(Icons.copy, size: 20),
                        color: Color(0xFF1A3D96),
                        tooltip:
                            localizations?.copyNumber ?? 'Copiar número',
                        constraints: BoxConstraints(),
                        padding: EdgeInsets.all(6),
                      ),
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
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(231, 182, 43, 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color.fromRGBO(231, 182, 43, 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 18, color: Color(0xFFB8860B)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations?.activationDelayNote ??
                            'Si en 24 horas tu cuenta no ha sido activada, por favor envía un mensaje a este número de Phi Sigma Alpha con tu correo, nombre y fecha de pago.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        _ShakeAttention(
          active: _tutorialStep == 1,
          child: SizedBox(
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

/// Envuelve un widget y lo hace "vibrar" (shake horizontal + háptica rítmica)
/// mientras [active] sea true, para guiar al usuario en el tutorial de pago.
class _ShakeAttention extends StatefulWidget {
  final Widget child;
  final bool active;

  const _ShakeAttention({required this.child, required this.active});

  @override
  State<_ShakeAttention> createState() => _ShakeAttentionState();
}

class _ShakeAttentionState extends State<_ShakeAttention>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _controller.addListener(_maybeHaptic);
    if (widget.active) _controller.repeat();
  }

  void _maybeHaptic() {
    // Al reiniciar el ciclo (value vuelve cerca de 0), damos un toque háptico
    // para que el teléfono "vibre" de forma rítmica junto con el shake.
    if (_controller.value < _lastValue) {
      HapticFeedback.lightImpact();
    }
    _lastValue = _controller.value;
  }

  @override
  void didUpdateWidget(covariant _ShakeAttention oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      HapticFeedback.mediumImpact();
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
      _lastValue = 0;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeHaptic);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Tres oscilaciones por ciclo con amplitud decreciente al final.
        final envelope = sin(_controller.value * pi); // 0 -> 1 -> 0
        final dx = sin(_controller.value * pi * 6) * 6 * envelope;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
