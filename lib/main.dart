import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'design/lingua_theme.dart';
import 'design/theme_controller.dart';
import 'i18n/locale_controller.dart';
import 'screens/reset_password_screen.dart';
import 'screens/splash_screen.dart';
import 'services/onboarding_service.dart';
import 'services/password_recovery.dart';

/// Contrôleur de thème global (clair / sombre / système), persisté.
final themeController = ThemeController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.hasSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }
  await themeController.load();
  await localeController.load();
  await OnboardingService.load();
  if (AppConfig.hasSupabase) {
    // Lien « mot de passe oublié » : supabase_flutter traite le lien
    // (profond sur Android, URL sur le web) et émet passwordRecovery.
    PasswordRecovery.listen(Supabase.instance.client.auth.onAuthStateChange);
  }
  runApp(const LinguaCEApp());
}

/// Navigator racine : permet d'ouvrir l'écran de nouveau mot de passe quel
/// que soit l'écran affiché quand le lien arrive.
final rootNavigatorKey = GlobalKey<NavigatorState>();

class LinguaCEApp extends StatefulWidget {
  const LinguaCEApp({super.key});

  @override
  State<LinguaCEApp> createState() => _LinguaCEAppState();
}

class _LinguaCEAppState extends State<LinguaCEApp> {
  @override
  void initState() {
    super.initState();
    PasswordRecovery.pending.addListener(_onRecovery);
  }

  @override
  void dispose() {
    PasswordRecovery.pending.removeListener(_onRecovery);
    super.dispose();
  }

  /// Lien ouvert pendant que l'app tourne : on bascule sur l'écran de
  /// nouveau mot de passe. Au démarrage à froid, le Navigator n'existe pas
  /// encore : c'est le splash qui s'en charge (il lit `pending`).
  void _onRecovery() {
    if (!PasswordRecovery.pending.value) return;
    rootNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, localeController]),
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'LinguaCE',
          debugShowCheckedModeBanner: false,
          theme: LinguaTheme.light(),
          darkTheme: LinguaTheme.dark(),
          themeMode: themeController.value,
          // Ajuste la barre de statut selon la luminosité résolue.
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ));
            return child!;
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
