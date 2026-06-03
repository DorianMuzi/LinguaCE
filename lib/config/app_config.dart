/// Configuration de l'application — secrets injectés au build.
///
/// Les valeurs proviennent de variables passées via `--dart-define` ou, plus
/// pratique, d'un fichier : `--dart-define-from-file=env.json`.
///
/// AUCUN secret n'est codé en dur ici : `env.json` est ignoré par git.
/// Voir `env.example.json` pour le format attendu.
class AppConfig {
  AppConfig._();

  /// Clé API Anthropic (Claude). Requise pour le chat IA.
  static const anthropicApiKey =
      String.fromEnvironment('ANTHROPIC_API_KEY');

  /// Modèle Claude utilisé.
  static const anthropicModel = String.fromEnvironment(
    'ANTHROPIC_MODEL',
    defaultValue: 'claude-haiku-4-5-20251001',
  );

  /// URL du projet Supabase.
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Clé publique (anon) Supabase — protégée côté serveur par les
  /// politiques RLS, donc publiable, mais externalisée par propreté.
  static const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasAnthropicKey => anthropicApiKey.isNotEmpty;
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
