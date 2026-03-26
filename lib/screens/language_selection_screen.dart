import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  Future<void> _saveLanguageAndContinue() async {
    if (_selectedLanguage == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage!);
    await prefs.setBool('first_time', false);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange[400],
                  border: Border.all(
                    color: const Color.fromRGBO(231, 182, 43, 1),
                    width: 4,
                  ),
                ),
                child: const Icon(Icons.school, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 40),
              Text(
                localizations?.selectLanguage ?? 'Select Language',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(24, 41, 163, 1),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizations?.selectLanguageDesc ?? 'Choose your preferred language',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              _buildLanguageOption(
                'es',
                localizations?.spanish ?? 'Español',
                Icons.flag,
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                'en',
                localizations?.english ?? 'English',
                Icons.flag,
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _selectedLanguage != null ? _saveLanguageAndContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(231, 182, 43, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    localizations?.continueText ?? 'Continue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String label, IconData icon) {
    final isSelected = _selectedLanguage == code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color.fromRGBO(231, 182, 43, 1)
                : Colors.grey[300]!,
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? const Color.fromRGBO(231, 182, 43, 0.1)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? const Color.fromRGBO(231, 182, 43, 1)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color.fromRGBO(24, 41, 163, 1)
                      : Colors.grey[800],
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color.fromRGBO(231, 182, 43, 1),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
