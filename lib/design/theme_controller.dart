import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrôle le mode de thème (clair / sombre / système) et le persiste.
///
/// Usage :
/// ```dart
/// final themeController = ThemeController();
/// await themeController.load();          // au démarrage
/// // ...
/// ValueListenableBuilder<ThemeMode>(
///   valueListenable: themeController,
///   builder: (_, mode, __) => MaterialApp(
///     theme: LinguaTheme.light(),
///     darkTheme: LinguaTheme.dark(),
///     themeMode: mode,
///     ...
///   ),
/// );
/// ```
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  static const _key = 'theme_mode';

  /// Charge le mode sauvegardé (défaut : système — suit le réglage du tél.).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      value = _fromString(prefs.getString(_key));
    } catch (_) {
      value = ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // Persistance best-effort
    }
  }

  /// Bascule clair ↔ sombre.
  void toggle() =>
      setMode(value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  static ThemeMode _fromString(String? v) => switch (v) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.system,
      };
}
