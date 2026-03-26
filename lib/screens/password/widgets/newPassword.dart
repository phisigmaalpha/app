import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import '../../components/inputPassword.dart';

class NewPasswordWidget extends StatefulWidget {
  final VoidCallback onNext;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  const NewPasswordWidget({
    super.key,
    required this.onNext,
    required this.controller,
    required this.formKey,
  });

  @override
  State<NewPasswordWidget> createState() => _NewPasswordWidgetState();
}

class _NewPasswordWidgetState extends State<NewPasswordWidget> {
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            Text(
              localizations?.enterNewPasswordDescription ?? 'Enter the new password you want to apply',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(24, 41, 163, 1),
              ),
            ),
            const SizedBox(height: 20),
            CustomPasswordField(
              controller: widget.controller,
              label: localizations?.newPassword ?? 'New password',
              errorMessage: localizations?.passwordRequired ?? 'Password is required',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations?.passwordRequired ?? 'Password is required';
                }
                if (value.length < 6) {
                  return localizations?.passwordMinLength ?? 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            CustomPasswordField(
              controller: _confirmController,
              label: localizations?.confirmPassword ?? 'Confirm password',
              errorMessage: localizations?.confirmYourPassword ?? 'Confirm your password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations?.confirmYourPassword ?? 'Confirm your password';
                }
                if (value != widget.controller.text) {
                  return localizations?.passwordsDoNotMatch ?? 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(231, 182, 43, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  localizations?.changePassword ?? 'Change password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
