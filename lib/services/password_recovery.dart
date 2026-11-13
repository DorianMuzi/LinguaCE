import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Réinitialisation du mot de passe par lien email (tâche #4).
///
/// Parcours : l'écran « Mot de passe oublié » appelle [sendEmail] avec une
/// URL de retour ; le lien de l'email rouvre l'app ; supabase_flutter
/// échange le code (flux PKCE) et émet [AuthChangeEvent.passwordRecovery] ;
/// [pending] passe à `true` et l'app affiche l'écran de nouveau mot de passe.
///
/// ⚠️ PKCE : le lien doit être ouvert sur l'appareil (ou le navigateur) qui
/// a fait la demande — c'est là qu'est stocké le vérificateur de code.
abstract final class PasswordRecovery {
  /// Lien profond Android, déclaré dans `AndroidManifest.xml`. À ajouter
  /// aussi dans Supabase › Authentication › URL Configuration › Redirect URLs.
  static const mobileRedirect = 'linguace://reset-password';

  /// Vrai entre l'ouverture du lien et l'enregistrement du nouveau mot de
  /// passe : l'app doit alors afficher l'écran de réinitialisation.
  static final pending = ValueNotifier<bool>(false);

  static StreamSubscription<AuthState>? _sub;

  /// URL de retour envoyée avec l'email : l'origine de la page sur le web
  /// (ex. http://localhost:59106/), le lien profond sur mobile.
  @visibleForTesting
  static String redirectUrl({required bool web, Uri? base}) =>
      web ? '${(base ?? Uri.base).origin}/' : mobileRedirect;

  /// Écoute les événements d'authentification. Le flux de supabase_flutter
  /// rejoue le dernier événement aux abonnés tardifs : un lien qui a ouvert
  /// l'app à froid n'est donc pas perdu.
  static void listen(Stream<AuthState> authEvents) {
    _sub ??= authEvents.listen((state) {
      if (state.event == AuthChangeEvent.passwordRecovery) {
        pending.value = true;
      }
    });
  }

  static Future<void> sendEmail(String email) =>
      Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectUrl(web: kIsWeb),
      );

  /// Enregistre le nouveau mot de passe (la session de récupération est
  /// active à ce stade) et clôt le parcours.
  static Future<void> updatePassword(String password) async {
    await Supabase.instance.client.auth
        .updateUser(UserAttributes(password: password));
    pending.value = false;
  }

  @visibleForTesting
  static Future<void> reset() async {
    await _sub?.cancel();
    _sub = null;
    pending.value = false;
  }
}
