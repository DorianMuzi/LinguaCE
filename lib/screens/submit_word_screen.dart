import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_components.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_tokens.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../services/word_submission_service.dart';
import '../widgets/letter_bar.dart';

/// « Proposer un mot » : l'utilisateur envoie un mot qu'il connaît (cyrillique
/// et/ou latin, sens, remarque). Relu par l'auteur avant d'entrer dans le
/// lexique et les suggestions.
class SubmitWordScreen extends StatefulWidget {
  /// Mot cherché dans le dictionnaire, pour pré-remplir le bon champ.
  final String initial;

  /// Envoi — injectable pour les tests.
  final Future<bool> Function({
    required String cyrillic,
    required String latin,
    required String meaning,
    String note,
  })? submit;

  const SubmitWordScreen({super.key, this.initial = '', this.submit});

  @override
  State<SubmitWordScreen> createState() => _SubmitWordScreenState();
}

class _SubmitWordScreenState extends State<SubmitWordScreen> {
  final _cyrillic = TextEditingController();
  final _latin = TextEditingController();
  final _meaning = TextEditingController();
  final _note = TextEditingController();
  final _latinFocus = FocusNode();
  String? _error;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final q = widget.initial.trim();
    if (q.isNotEmpty) {
      (RegExp('[Ѐ-ӿ]').hasMatch(q) ? _cyrillic : _latin).text = q;
    }
  }

  @override
  void dispose() {
    for (final c in [_cyrillic, _latin, _meaning, _note]) {
      c.dispose();
    }
    _latinFocus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final error = WordSubmissionService.validate(
      cyrillic: _cyrillic.text,
      latin: _latin.text,
      meaning: _meaning.text,
    );
    if (error != null) {
      setState(() => _error = tr(error));
      return;
    }
    setState(() {
      _error = null;
      _sending = true;
    });
    final ok = await (widget.submit ?? WordSubmissionService.submit)(
      cyrillic: _cyrillic.text,
      latin: _latin.text,
      meaning: _meaning.text,
      note: _note.text,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _sending = false;
        _error = tr('err.generic');
      });
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, true);
    messenger.showSnackBar(SnackBar(content: Text(tr('submit.thanks'))));
  }

  Widget _field(LinguaTokens t, String label, TextEditingController c,
      {FocusNode? focus, int maxLength = 80, int maxLines = 1}) {
    return TextField(
      controller: c,
      focusNode: focus,
      maxLength: maxLength,
      maxLines: maxLines,
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      style: GoogleFonts.manrope(color: t.textPrimary, fontSize: 17),
      decoration: InputDecoration(labelText: label, counterText: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.surfaceBase,
      appBar: AppBar(
        backgroundColor: t.surfaceBase,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.textPrimary),
          tooltip: tr('common.back'),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('submit.title'),
            style: GoogleFonts.oswald(
                color: t.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ContentClamp(
          maxWidth: 640,
          padding: const EdgeInsets.fromLTRB(
              LinguaSpacing.screen, LinguaSpacing.sm, LinguaSpacing.screen, 0),
          child: ListView(
            padding: const EdgeInsets.only(bottom: LinguaSpacing.xl),
            children: [
              Text(tr('submit.intro'),
                  style: GoogleFonts.manrope(
                      color: t.textSecondary, fontSize: 14, height: 1.5)),
              const SizedBox(height: LinguaSpacing.lg),
              _field(t, tr('submit.cyrillic'), _cyrillic),
              const SizedBox(height: LinguaSpacing.md),
              _field(t, tr('submit.latin'), _latin, focus: _latinFocus),
              const SizedBox(height: LinguaSpacing.sm),
              LetterBar(controller: _latin, focusNode: _latinFocus),
              const SizedBox(height: LinguaSpacing.md),
              _field(t, tr('submit.meaning'), _meaning, maxLength: 200),
              const SizedBox(height: LinguaSpacing.md),
              _field(t, tr('submit.note'), _note, maxLength: 500, maxLines: 3),
              if (_error != null) ...[
                const SizedBox(height: LinguaSpacing.md),
                Semantics(
                  liveRegion: true,
                  child: Text(_error!,
                      style: GoogleFonts.manrope(
                          color: t.danger,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ],
              const SizedBox(height: LinguaSpacing.lg),
              CopilotButton(
                label: tr('submit.send'),
                icon: Icons.send_rounded,
                loading: _sending,
                expand: true,
                onPressed: _sending ? null : _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
