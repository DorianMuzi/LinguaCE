import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_components.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_tokens.dart';
import '../i18n/app_strings.dart';
import '../services/notification_service.dart';
import '../services/onboarding_service.dart';
import 'main_screen.dart';

enum _Step { pkharmat, naxci, level, reminder }

/// Premier lancement : accueil narratif (Pkharmat), présentation de Naxçi,
/// choix du niveau (transmis à Naxçi), puis rappel quotidien.
///
/// Chaque choix a un effet réel : le niveau adapte les réponses de Naxçi, le
/// rappel pilote [NotificationService]. Le niveau ne change PAS le déblocage
/// des leçons. L'étape du rappel est absente sur le web (pas de
/// notifications locales).
class OnboardingScreen extends StatefulWidget {
  /// Visible depuis les tests : permet de forcer l'étape du rappel.
  final bool showReminderStep;

  const OnboardingScreen({super.key, this.showReminderStep = !kIsWeb});

  /// Écran à ouvrir une fois l'utilisateur connecté : l'onboarding s'il n'a
  /// pas encore été fait sur cet appareil, sinon l'app.
  static Widget entry() =>
      OnboardingService.done ? const MainScreen() : const OnboardingScreen();

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final List<_Step> _steps = [
    _Step.pkharmat,
    _Step.naxci,
    _Step.level,
    if (widget.showReminderStep) _Step.reminder,
  ];

  int _index = 0;
  LearnerLevel _level = OnboardingService.level;
  bool _reminder = true;
  bool _finishing = false;

  _Step get _step => _steps[_index];
  bool get _isLast => _index == _steps.length - 1;

  void _back() => setState(() => _index--);

  Future<void> _next() async {
    if (!_isLast) {
      setState(() => _index++);
      return;
    }
    setState(() => _finishing = true);
    await OnboardingService.complete(_level);
    if (widget.showReminderStep) {
      // Demande la permission système au bon moment (choix explicite) ; un
      // refus laisse simplement le rappel désactivé, sans bloquer l'entrée.
      await NotificationService.setEnabled(_reminder);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: t.surfaceBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              LinguaSpacing.screen, 8, LinguaSpacing.screen, 24),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _index > 0 && !_finishing
                      ? TextButton.icon(
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text(tr('onb.back')),
                          style: TextButton.styleFrom(
                              foregroundColor: t.textSecondary),
                        )
                      : null,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 260),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(t),
                  ),
                ),
              ),
              _Dots(count: _steps.length, index: _index),
              const SizedBox(height: 18),
              CopilotButton(
                label: tr(_isLast ? 'onb.start' : 'onb.next'),
                onPressed: _finishing ? null : _next,
                loading: _finishing,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(LinguaTokens t) => switch (_step) {
        _Step.pkharmat => _Centered(
            visual: ClipRRect(
              borderRadius: LinguaRadius.rLg,
              child: Image.asset(
                BrandAssets.pkharmat(1),
                width: 220,
                height: 220,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.4),
                cacheWidth:
                    (220 * MediaQuery.devicePixelRatioOf(context)).round(),
                excludeFromSemantics: true,
              ),
            ),
            title: tr('onb.p1_title'),
            body: tr('onb.p1_body'),
          ),
        _Step.naxci => _Centered(
            visual: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: t.gold, width: 2),
                boxShadow: t.shadowMd,
              ),
              child: const NaxciAvatar(size: 140),
            ),
            title: tr('onb.p2_title'),
            body: tr('onb.p2_body'),
          ),
        _Step.level => _buildLevelStep(t),
        _Step.reminder => _buildReminderStep(t),
      };

  Widget _buildLevelStep(LinguaTokens t) {
    const options = [
      (LearnerLevel.beginner, Icons.spa_rounded),
      (LearnerLevel.intermediate, Icons.eco_rounded),
      (LearnerLevel.advanced, Icons.park_rounded),
    ];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _Title(tr('onb.p3_title')),
          const SizedBox(height: 8),
          _Body(tr('onb.p3_body')),
          const SizedBox(height: 22),
          for (final (level, icon) in options) ...[
            _ChoiceCard(
              icon: icon,
              title: tr('onb.lvl.${level.key}'),
              subtitle: tr('onb.lvl.${level.key}_desc'),
              selected: _level == level,
              onTap: () => setState(() => _level = level),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildReminderStep(LinguaTokens t) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Center(child: NaxciAvatar(size: 96)),
          const SizedBox(height: 22),
          _Title(tr('onb.p4_title')),
          const SizedBox(height: 8),
          _Body(tr('onb.p4_body')),
          const SizedBox(height: 22),
          CopilotCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.notifications_active_outlined,
                  color: t.textSecondary),
              title: Text(tr('onb.p4_switch'),
                  style:
                      GoogleFonts.manrope(color: t.textPrimary, fontSize: 15)),
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
              activeColor: t.accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Étape narrative : visuel centré, titre, texte.
class _Centered extends StatelessWidget {
  final Widget visual;
  final String title;
  final String body;

  const _Centered(
      {required this.visual, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            visual,
            const SizedBox(height: 26),
            _Title(title),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: _Body(body),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.oswald(
          color: context.tokens.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.manrope(
        color: context.tokens.textSecondary,
        fontSize: 15,
        height: 1.5,
      ),
    );
  }
}

/// Carte de choix (niveau) : bordure et fond accentués quand sélectionnée.
class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? t.accentTint : t.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: LinguaRadius.rLg,
          side: BorderSide(
            color: selected ? t.accent : t.outlineSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: LinguaRadius.rLg,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon,
                    color: selected ? t.accent : t.textSecondary, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.oswald(
                              color: t.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: GoogleFonts.manrope(
                              color: t.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: t.accent, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicateur d'étape : la pastille active s'allonge.
class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      label: '${index + 1} / $count',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == index ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == index ? t.accent : t.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
