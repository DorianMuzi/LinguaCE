import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_theme.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_components.dart';
import '../design/responsive.dart';
import 'splash_screen.dart';

/// Vitrine du système de design LinguaCE.
///
/// Écran AUTONOME : il applique localement le thème clair ou sombre via un
/// [Theme] wrapper, indépendamment du thème global de l'app. Sert à valider
/// le langage visuel (façon Copilot) avant de l'appliquer aux écrans réels.
class DesignShowcaseScreen extends StatefulWidget {
  const DesignShowcaseScreen({super.key});

  @override
  State<DesignShowcaseScreen> createState() => _DesignShowcaseScreenState();
}

class _DesignShowcaseScreenState extends State<DesignShowcaseScreen> {
  bool _dark = false; // démarre en clair pour montrer le look Copilot

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _dark ? LinguaTheme.dark() : LinguaTheme.light(),
      child: Builder(
        builder: (context) {
          final t = context.tokens;
          return Scaffold(
            backgroundColor: t.surfaceBase,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ContentClamp(
                        padding: EdgeInsets.all(
                          Responsive.isMobile(context)
                              ? LinguaSpacing.lg
                              : LinguaSpacing.xxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _hero(context),
                            _gap,
                            _section('Couleurs', _colors(context)),
                            _gap,
                            _section('Typographie', _typography(context)),
                            _gap,
                            _section('Boutons', _buttons(context)),
                            _gap,
                            _section('Cartes & statistiques', _stats(context)),
                            _gap,
                            _section('Chips & étiquettes', _chips(context)),
                            _gap,
                            _section('Champ de saisie', _input(context)),
                            _gap,
                            _section('Responsive', _responsive(context)),
                            const SizedBox(height: LinguaSpacing.xl),
                            CopilotButton(
                              label: 'Entrer dans l\'app',
                              icon: Icons.arrow_forward_rounded,
                              expand: true,
                              onPressed: () => Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (_) => const SplashScreen())),
                            ),
                            const SizedBox(height: LinguaSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static const _gap = SizedBox(height: LinguaSpacing.xxl);

  // ── En-tête avec bascule clair/sombre ──────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LinguaSpacing.lg, vertical: LinguaSpacing.md),
      decoration: BoxDecoration(
        color: t.surfaceBase,
        border: Border(bottom: BorderSide(color: t.outlineSubtle)),
      ),
      child: Row(
        children: [
          Text('Lingua',
              style: GoogleFonts.playfairDisplay(
                  color: t.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text('CE',
              style: GoogleFonts.playfairDisplay(
                  color: t.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text('· Design system',
              style: GoogleFonts.spaceMono(
                  color: t.textTertiary, fontSize: 11)),
          const Spacer(),
          _themeToggle(context),
        ],
      ),
    );
  }

  Widget _themeToggle(BuildContext context) {
    final t = context.tokens;
    Widget seg(String label, IconData icon, bool active, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: LinguaDuration.fast,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? t.accent : Colors.transparent,
            borderRadius: LinguaRadius.rPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14,
                  color: active ? t.onAccent : t.textSecondary),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.spaceMono(
                      color: active ? t.onAccent : t.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: LinguaRadius.rPill,
        border: Border.all(color: t.outline),
      ),
      child: Row(
        children: [
          seg('Clair', Icons.light_mode_outlined, !_dark,
              () => setState(() => _dark = false)),
          seg('Sombre', Icons.dark_mode_outlined, _dark,
              () => setState(() => _dark = true)),
        ],
      ),
    );
  }

  // ── Sections ───────────────────────────────────────────────────────────
  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        const SizedBox(height: LinguaSpacing.md),
        child,
      ],
    );
  }

  Widget _hero(BuildContext context) {
    final t = context.tokens;
    return CopilotCard(
      gradient: t.heroGradient,
      padding: const EdgeInsets.all(LinguaSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AccentChip(label: 'НОХЧИЙН МОТТ', emoji: '🏔'),
          const SizedBox(height: LinguaSpacing.md),
          Text('Apprends le tchétchène',
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: LinguaSpacing.sm),
          Text(
            'Un assistant IA pour maîtriser une langue millénaire du Caucase, '
            'à ton rythme.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: t.textSecondary),
          ),
          const SizedBox(height: LinguaSpacing.lg),
          Row(
            children: [
              CopilotButton(label: 'Commencer', onPressed: () {}),
              const SizedBox(width: LinguaSpacing.md),
              CopilotButton(
                  label: 'En savoir plus',
                  variant: CopilotButtonVariant.ghost,
                  onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colors(BuildContext context) {
    final t = context.tokens;
    final swatches = <(String, Color)>[
      ('accent', t.accent),
      ('accentSoft', t.accentSoft),
      ('accentStrong', t.accentStrong),
      ('surfaceRaised', t.surfaceRaised),
      ('surfaceSunken', t.surfaceSunken),
      ('outline', t.outline),
      ('success', t.success),
      ('danger', t.danger),
    ];
    return Wrap(
      spacing: LinguaSpacing.md,
      runSpacing: LinguaSpacing.md,
      children: swatches.map((s) {
        return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: s.$2,
                borderRadius: LinguaRadius.rMd,
                border: Border.all(color: t.outline),
              ),
            ),
            const SizedBox(height: 6),
            Text(s.$1,
                style: GoogleFonts.spaceMono(
                    color: t.textSecondary, fontSize: 9)),
          ],
        );
      }).toList(),
    );
  }

  Widget _typography(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return CopilotCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Display — Playfair', style: tt.displaySmall),
          const SizedBox(height: 8),
          Text('Titre — Playfair', style: tt.titleLarge),
          const SizedBox(height: 8),
          Text(
              'Corps de texte en Inter : lisible, neutre, confortable sur de '
              'longues lignes comme dans les réponses de l\'IA.',
              style: tt.bodyLarge),
          const SizedBox(height: 8),
          Text('LABEL — SPACE MONO', style: tt.labelLarge),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Wrap(
      spacing: LinguaSpacing.md,
      runSpacing: LinguaSpacing.md,
      children: [
        CopilotButton(label: 'Plein', onPressed: () {}),
        CopilotButton(
            label: 'Tonal',
            variant: CopilotButtonVariant.tonal,
            onPressed: () {}),
        CopilotButton(
            label: 'Fantôme',
            variant: CopilotButtonVariant.ghost,
            onPressed: () {}),
        CopilotButton(
            label: 'Avec icône',
            icon: Icons.bolt_rounded,
            onPressed: () {}),
        const CopilotButton(label: 'Chargement', onPressed: null, loading: true),
      ],
    );
  }

  Widget _stats(BuildContext context) {
    final tiles = const [
      StatTile(emoji: '⭐', value: '2 847', label: 'XP TOTAL'),
      StatTile(emoji: '🔥', value: '12 j', label: 'SÉRIE'),
      StatTile(emoji: '🏆', value: 'Niv. 4', label: 'NIVEAU'),
      StatTile(emoji: '📚', value: '18', label: 'LEÇONS'),
    ];
    final cols = Responsive.value(context, mobile: 2, tablet: 4, desktop: 4);
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: LinguaSpacing.md,
      mainAxisSpacing: LinguaSpacing.md,
      childAspectRatio: 2.4,
      children: tiles,
    );
  }

  Widget _chips(BuildContext context) {
    return Wrap(
      spacing: LinguaSpacing.sm,
      runSpacing: LinguaSpacing.sm,
      children: const [
        AccentChip(label: 'Ligue Aigle', emoji: '🦅'),
        AccentChip(label: 'Niveau 4', icon: Icons.star_rounded),
        AccentChip(label: '12 jours', emoji: '🔥'),
        AccentChip(label: 'IA Tchétchène', icon: Icons.psychology_outlined),
      ],
    );
  }

  Widget _input(BuildContext context) {
    return CopilotCard(
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Adresse email',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
          ),
          const SizedBox(height: LinguaSpacing.md),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Écris ton message à l\'IA…',
              prefixIcon: Icon(Icons.chat_bubble_outline_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsive(BuildContext context) {
    final t = context.tokens;
    final cls = Responsive.classOf(context);
    final width = MediaQuery.sizeOf(context).width;
    return CopilotCard(
      child: Row(
        children: [
          Icon(
            switch (cls) {
              DeviceClass.mobile => Icons.smartphone_rounded,
              DeviceClass.tablet => Icons.tablet_rounded,
              DeviceClass.desktop => Icons.desktop_windows_rounded,
            },
            color: t.accent,
            size: 28,
          ),
          const SizedBox(width: LinguaSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Classe : ${cls.name}',
                  style: Theme.of(context).textTheme.titleLarge),
              Text('Largeur : ${width.toInt()} px',
                  style: GoogleFonts.spaceMono(
                      color: t.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
