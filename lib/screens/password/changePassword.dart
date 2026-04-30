import 'package:flutter/material.dart';
// import 'package:app/l10n/app_localizations.dart';
import 'widgets/validateEmail.dart';
import 'widgets/code.dart';
import 'widgets/newPassword.dart';
import 'widgets/navbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  int currentStep = 1;

  // Controllers que persisten durante toda la vida del widget
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  // Keys para validar cada formulario
  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void nextStep() {
    setState(() {
      currentStep++;
    });
  }

  // Valida y avanza al siguiente paso
  void validateAndNext(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      // Aquí puedes acceder a los valores:
      // _emailController.text, _codeController.text, etc.
      nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomNavbarWidget(
              onBack: () {
                if (currentStep > 1) {
                  setState(() => currentStep--);
                } else {
                  Navigator.pop(context);
                }
              },
            ),

            Expanded(child: _buildCurrentStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 1:
        return ValidateEmailWidget(
          formKey: _emailFormKey,
          controller: _emailController,
          onNext: () => validateAndNext(_emailFormKey),
        );
      case 2:
        return CodeWidget(
          formKey: _codeFormKey,
          controller: _codeController,
          onNext: () => validateAndNext(_codeFormKey),
        );
      case 3:
        return NewPasswordWidget(
          formKey: _passwordFormKey,
          controller: _passwordController,
          onNext: () => validateAndNext(_passwordFormKey),
        );
      default:
        return ValidateEmailWidget(
          formKey: _emailFormKey,
          controller: _emailController,
          onNext: () => validateAndNext(_emailFormKey),
        );
    }
  }
}
