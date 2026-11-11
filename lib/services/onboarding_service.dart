import 'package:shared_preferences/shared_preferences.dart';

/// Niveau déclaré par l'apprenant à l'onboarding (modifiable dans le profil).
///
/// N'influence PAS le déblocage des leçons (séquentiel) : il sert à Naxçi,
/// qui adapte ses explications au niveau (cf. ClaudeService).
enum LearnerLevel {
  beginner,
  intermediate,
  advanced;

  /// Clé persistée — stable, indépendante de l'ordre de l'énumération.
  String get key => name;

  static LearnerLevel? fromKey(String? raw) {
    for (final l in values) {
      if (l.key == raw) return l;
    }
    return null;
  }
}

/// État de l'onboarding (premier lancement) et niveau de l'apprenant.
///
/// Persisté par appareil via `shared_preferences`, même patron que
/// ThemeController / LocaleController : chargé une fois dans `main()`, puis
/// lu de façon synchrone par les écrans.
class OnboardingService {
  OnboardingService._();

  static const _doneKey = 'onboarding_done';
  static const _levelKey = 'learner_level';

  static bool _done = false;
  static LearnerLevel _level = LearnerLevel.beginner;

  /// `true` une fois l'onboarding terminé sur cet appareil.
  static bool get done => _done;

  /// Niveau courant (débutant par défaut, tant que rien n'a été choisi).
  static LearnerLevel get level => _level;

  /// À appeler dans `main()`, avant le premier écran.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _done = prefs.getBool(_doneKey) ?? false;
      _level = LearnerLevel.fromKey(prefs.getString(_levelKey)) ??
          LearnerLevel.beginner;
    } catch (_) {
      // Préférences indisponibles : on montrera l'onboarding, sans bloquer.
    }
  }

  static Future<void> setLevel(LearnerLevel level) async {
    _level = level;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_levelKey, level.key);
    } catch (_) {}
  }

  /// Termine l'onboarding : enregistre le niveau choisi et ne le remontre plus.
  static Future<void> complete(LearnerLevel level) async {
    await setLevel(level);
    _done = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_doneKey, true);
    } catch (_) {}
  }
}
