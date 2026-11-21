import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrôle la langue de l'interface (FR / EN / RU / CE) et la persiste.
///
/// Instance globale : [localeController]. L'app entière se reconstruit quand
/// la valeur change (voir `main.dart`).
class LocaleController extends ValueNotifier<String> {
  LocaleController() : super('FR');

  static const _key = 'interface_language';
  static const supported = ['FR', 'EN', 'RU', 'CE'];

  /// Nom affiché de chaque langue.
  static const names = {
    'FR': 'Français',
    'EN': 'English',
    'RU': 'Русский',
    'CE': 'Noxçiyŋ',
  };

  /// Langue choisie par l'utilisateur si elle existe ; sinon celle du
  /// téléphone (tant qu'il n'a rien choisi, l'app suit le téléphone).
  Future<void> load() async {
    String? saved;
    try {
      final prefs = await SharedPreferences.getInstance();
      saved = prefs.getString(_key);
    } catch (_) {}
    if (saved != null && supported.contains(saved)) {
      value = saved;
    } else {
      value = fromDevice(
          PlatformDispatcher.instance.locales.map((l) => l.languageCode));
    }
  }

  /// Première langue du téléphone que l'app parle (dans l'ordre de
  /// préférence de l'utilisateur) ; sinon l'anglais, le plus largement
  /// compris par la diaspora (Allemagne, Autriche, Turquie…).
  static String fromDevice(Iterable<String> languageCodes) {
    for (final code in languageCodes) {
      final c = code.toUpperCase();
      if (supported.contains(c)) return c;
    }
    return 'EN';
  }

  Future<void> setLang(String lang) async {
    if (!supported.contains(lang) || lang == value) return;
    value = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, lang);
    } catch (_) {}
  }
}

/// Instance globale partagée par toute l'app.
final localeController = LocaleController();
