import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_components.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_tokens.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_controller.dart';
import '../models/models.dart';
import '../services/lexeme_audio.dart';
import '../services/lexicon_service.dart';
import 'submit_word_screen.dart';

/// Premier dictionnaire de LinguaCE, alimenté par le lexique commun du Core
/// (mots validés par un natif). Recherche en latin — avec ou sans
/// diacritiques —, en cyrillique ou dans la langue d'interface.
class DictionaryScreen extends StatefulWidget {
  /// Source des mots — injectable pour les tests.
  final Future<List<Lexeme>> Function()? load;

  /// Lecture d'une prononciation — injectable pour les tests.
  final Future<void> Function(String audioUrl)? play;

  const DictionaryScreen({super.key, this.load, this.play});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _query = TextEditingController();
  List<Lexeme>? _all;
  bool _failed = false;

  String get _lang => localeController.value;

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final words = await (widget.load ?? LexiconService.fetchAll)();
      if (mounted) setState(() => _all = words);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
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
        title: Text(tr('dict.title'),
            style: GoogleFonts.oswald(
                color: t.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: tr('submit.title'),
            icon: Icon(Icons.add_rounded, color: t.textPrimary),
            onPressed: () => _propose(''),
          ),
        ],
      ),
      body: SafeArea(
        child: ContentClamp(
          maxWidth: 640,
          padding: const EdgeInsets.fromLTRB(
              LinguaSpacing.screen, LinguaSpacing.sm, LinguaSpacing.screen, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _query,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: tr('dict.search_hint'),
                  prefixIcon: Icon(Icons.search_rounded, color: t.textTertiary),
                  suffixIcon: _query.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: tr('common.delete'),
                          icon: Icon(Icons.close_rounded, color: t.textTertiary),
                          onPressed: _query.clear,
                        ),
                ),
              ),
              const SizedBox(height: LinguaSpacing.md),
              Expanded(child: _buildBody(t)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LinguaTokens t) {
    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('err.generic'),
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.manrope(color: t.textSecondary, fontSize: 14)),
            const SizedBox(height: LinguaSpacing.md),
            CopilotButton(
              label: tr('common.retry'),
              variant: CopilotButtonVariant.tonal,
              onPressed: _load,
            ),
          ],
        ),
      );
    }
    final all = _all;
    if (all == null) {
      return Center(child: CircularProgressIndicator(color: t.accent));
    }

    final results = LexiconService.search(all, _query.text, _lang);
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(tr('dict.empty'),
                  style: GoogleFonts.manrope(color: t.textSecondary, fontSize: 15)),
            ),
            const SizedBox(height: LinguaSpacing.md),
            // Mot absent : l'utilisateur peut le proposer (relu avant ajout).
            CopilotButton(
              label: tr('dict.propose'),
              icon: Icons.add_rounded,
              variant: CopilotButtonVariant.tonal,
              onPressed: () => _propose(_query.text),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: LinguaSpacing.xl),
      itemCount: results.length + 1,
      separatorBuilder: (_, i) =>
          SizedBox(height: i == 0 ? LinguaSpacing.sm : LinguaSpacing.sm + 2),
      itemBuilder: (_, i) {
        if (i == 0) {
          return Semantics(
            liveRegion: true,
            child: SectionLabel(
                tr('dict.count', {'n': '${results.length}'})),
          );
        }
        return _entry(results[i - 1]);
      },
    );
  }

  void _propose(String initial) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SubmitWordScreen(initial: initial)),
      );

  Future<void> _play(String audioUrl) async {
    try {
      await (widget.play ?? LexemeAudio.play)(audioUrl);
    } catch (_) {
      // Son indisponible (réseau) : le mot reste lisible, rien à signaler.
    }
  }

  Widget _entry(Lexeme l) {
    final t = context.tokens;
    final cls = Lexeme.classLetter(l.nounClass);
    return CopilotCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ChechenWord(
              latin: l.latin,
              cyrillic: l.cyrillic,
              gloss: l.translationsFor(_lang).join(', '),
              // 26 : le cyrillique (moitié de la taille) reste lisible à 13.
              size: 26,
            ),
          ),
          if (l.audioUrl case final audio?)
            IconButton(
              tooltip: tr('audio.play'),
              icon: Icon(Icons.volume_up_rounded, color: t.accent),
              onPressed: () => _play(audio),
            ),
          const SizedBox(width: LinguaSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AccentChip(label: tr('pos.${l.pos}'), tone: ChipTone.neutral),
              if (cls != null) ...[
                const SizedBox(height: LinguaSpacing.xs),
                AccentChip(label: tr('dict.class', {'c': cls})),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
