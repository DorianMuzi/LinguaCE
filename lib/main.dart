import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'design/lingua_theme.dart';
import 'design/theme_controller.dart';
import 'screens/splash_screen.dart';

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
  runApp(const LinguaCEApp());
}

class LinguaCEApp extends StatelessWidget {
  const LinguaCEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'LinguaCE',
          debugShowCheckedModeBanner: false,
          theme: LinguaTheme.light(),
          darkTheme: LinguaTheme.dark(),
          themeMode: mode,
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
