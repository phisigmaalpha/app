import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    // Lista de archivos JSON a cargar por módulo
    final List<String> modules = [
      'common',
      'login',
      'passwords',
      'subscription',
      'chapters',
    ];

    // Cargar y combinar todos los JSONs
    for (String module in modules) {
      try {
        String jsonString = await rootBundle.loadString(
          'lib/l10n/translations/${locale.languageCode}/$module.json',
        );
        Map<String, dynamic> jsonMap = json.decode(jsonString);
        jsonMap.forEach((key, value) {
          _localizedStrings[key] = value.toString();
        });
      } catch (e) {
        // Si un archivo no existe, simplemente continuar
        debugPrint('Could not load $module.json for ${locale.languageCode}: $e');
      }
    }
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Common translations
  String get appTitle => translate('appTitle');
  String get selectLanguage => translate('selectLanguage');
  String get selectLanguageDesc => translate('selectLanguageDesc');
  String get english => translate('english');
  String get spanish => translate('spanish');
  String get continueText => translate('continue');

  // Login translations
  String get phiSigmaAlpha => translate('phiSigmaAlpha');
  String get email => translate('email');
  String get password => translate('password');
  String get emailRequired => translate('emailRequired');
  String get passwordRequired => translate('passwordRequired');
  String get login => translate('login');
  String get forgotPassword => translate('forgotPassword');
  String get wantToBecome => translate('wantToBecome');
  String get invalidCredentials => translate('invalidCredentials');

  // Password translations
  String get enterRegisteredEmail => translate('enterRegisteredEmail');
  String get send => translate('send');
  String get codeSentDescription => translate('codeSentDescription');
  String get code => translate('code');
  String get codeRequired => translate('codeRequired');
  String get codeMustBe4Digits => translate('codeMustBe4Digits');
  String get validateCode => translate('validateCode');
  String get resendCode => translate('resendCode');
  String get enterNewPasswordDescription => translate('enterNewPasswordDescription');
  String get newPassword => translate('newPassword');
  String get passwordMinLength => translate('passwordMinLength');
  String get confirmPassword => translate('confirmPassword');
  String get confirmYourPassword => translate('confirmYourPassword');
  String get passwordsDoNotMatch => translate('passwordsDoNotMatch');
  String get changePassword => translate('changePassword');

  // Registration translations
  String get register => translate('register');
  String get fullName => translate('fullName');
  String get nameRequired => translate('nameRequired');
  String get phone => translate('phone');
  String get addPhoto => translate('addPhoto');
  String get registrationError => translate('registrationError');
  String get passwordMismatch => translate('passwordMismatch');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get accountPendingApproval => translate('accountPendingApproval');
  String get accountPendingApprovalMessage => translate('accountPendingApprovalMessage');
  String get validateActivation => translate('validateActivation');
  String get accountStillPending => translate('accountStillPending');
  String get backToLogin => translate('backToLogin');
  String get ok => translate('ok');
  String get paymentNumberLabel => translate('paymentNumberLabel');
  String get copyNumber => translate('copyNumber');
  String get numberCopied => translate('numberCopied');
  String get paymentNoteInstruction => translate('paymentNoteInstruction');

  // Subscription translations
  // Agrega aquí los getters para tus traducciones de subscription

  // Chapter translations
  String get joinChapter => translate('joinChapter');
  String get joinChapterConfirmTitle => translate('joinChapterConfirmTitle');
  String get joinChapterConfirmMessage => translate('joinChapterConfirmMessage');
  String get joinChapterSuccess => translate('joinChapterSuccess');
  String get joinChapterError => translate('joinChapterError');
  String get alreadyMember => translate('alreadyMember');
  String get pendingMember => translate('pendingMember');
  String get myChapters => translate('myChapters');
  String get noMyChapters => translate('noMyChapters');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
