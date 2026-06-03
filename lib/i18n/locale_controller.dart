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

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_key);
      if (v != null && supported.contains(v)) value = v;
    } catch (_) {}
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
