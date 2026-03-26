import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import '../../components/inputEmail.dart';

class ValidateEmailWidget extends StatelessWidget {
  final VoidCallback onNext;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  const ValidateEmailWidget({
    super.key,
    required this.onNext,
    required this.controller,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Text(
              localizations?.enterRegisteredEmail ?? 'Enter the email address registered in the App',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(24, 41, 163, 1),
              ),
            ),
            const SizedBox(height: 20),
            CustomEmailField(
              controller: controller,
              label: localizations?.email ?? 'Email',
              errorMessage: localizations?.emailRequired ?? 'Email required',
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(231, 182, 43, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  localizations?.send ?? 'Send',
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
