import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../design/lingua_components.dart';
import '../design/lingua_tokens.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../services/password_recovery.dart';
import 'onboarding_screen.dart';

/// Écran ouvert par le lien de réinitialisation de l'email (tâche #4) :
/// l'utilisateur choisit un nouveau mot de passe, puis entre dans l'app,
/// déjà connecté par la session de récupération.
class ResetPasswordScreen extends StatefulWidget {
  /// Enregistre le mot de passe — injectable pour les tests.
  final Future<void> Function(String password)? update;

  /// Suite du parcours une fois le mot de passe changé — injectable aussi.
  final void Function(BuildContext context)? onDone;

  const ResetPasswordScreen({super.key, this.update, this.onDone});

  /// Règles identiques à l'inscription (6 caractères minimum). Renvoie le
  /// message d'erreur, ou `null` si tout est bon.
  static String? validate(String password, String confirm) {
    if (password.isEmpty || confirm.isEmpty) return tr('err.fill_fields');
    if (password.length < 6) return tr('reg.err_password_short');
    if (password != confirm) return tr('reg.err_password_mismatch');
    return null;
  }

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = ResetPasswordScreen.validate(_password.text, _confirm.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await (widget.update ?? PasswordRecovery.updatePassword)(_password.text);
    } on AuthException catch (e) {
      // Ex. « le nouveau mot de passe doit être différent de l'ancien ».
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = tr('err.generic'));
    }
    if (!mounted) return;
    if (_error != null) {
      setState(() => _saving = false);
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr('reset.done'))));
    (widget.onDone ?? _enterApp)(context);
  }

  static void _enterApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OnboardingScreen.entry()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    InputDecoration field(String label) => InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock_outline, color: t.textTertiary, size: 20),
          filled: true,
          fillColor: t.surfaceSunken,
        );

    return Scaffold(
      backgroundColor: t.surfaceBase,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ContentClamp(
            maxWidth: 440,
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(tr('reset.title'),
                        style: GoogleFonts.oswald(
                            color: t.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  Text(tr('reset.subtitle'),
                      style: GoogleFonts.manrope(
                          color: t.textSecondary, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    enabled: !_saving,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    decoration: field(tr('reset.password')).copyWith(
                      suffixIcon: IconButton(
                        tooltip: tr(_obscure ? 'reset.show' : 'reset.hide'),
                        icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: t.textTertiary,
                            size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _confirm,
                    obscureText: _obscure,
                    enabled: !_saving,
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) => _save(),
                    decoration: field(tr('reset.confirm')),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      child: Text(_error!,
                          style: GoogleFonts.manrope(
                              color: t.danger, fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: 28),
                  CopilotButton(
                    label: tr('common.save'),
                    expand: true,
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
