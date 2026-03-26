import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';

class CodeWidget extends StatelessWidget {
  final VoidCallback onNext;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  const CodeWidget({
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
              localizations?.codeSentDescription ?? 'We have sent a 4-digit code to your email valid for 5 minutes, enter the code received below',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(24, 41, 163, 1),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: localizations?.code ?? 'Code',
                hintText: '1234',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations?.codeRequired ?? 'Code is required';
                }
                if (value.length != 4) {
                  return localizations?.codeMustBe4Digits ?? 'Code must be 4 digits';
                }
                return null;
              },
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
                  localizations?.validateCode ?? 'Validate code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(localizations?.resendCode ?? 'Resend code'),
          ],
        ),
      ),
    );
  }
}
