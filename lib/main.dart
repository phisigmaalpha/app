import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/screens/login/login.dart';
import 'package:app/screens/home/home.dart';
import 'package:app/screens/language_selection_screen.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/login/membership.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('es'); // Default to Spanish

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'es';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGMA',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('es', '')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/languageSelection': (context) => const LanguageSelectionScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/membership': (context) => Membership(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time') ?? true;

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (supabase.auth.currentSession != null) {
      // Verificar si el usuario tiene suscripción activa
      final authService = AuthService();
      final profile = await authService.getCurrentUserProfile();

      if (!mounted) return;

      if (profile == null) {
        // Usuario inactivo o no existe
        await supabase.auth.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final expiresAt = profile['subscription_expires_at'] as String?;
        final isSubscribed = expiresAt != null &&
            DateTime.parse(expiresAt).isAfter(DateTime.now());

        if (isSubscribed) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/membership');
        }
      }
    } else if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/languageSelection');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromRGBO(231, 182, 43, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
