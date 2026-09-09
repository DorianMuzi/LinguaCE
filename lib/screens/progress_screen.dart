import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_components.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_theme.dart';
import '../design/lingua_tokens.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../models/models.dart';
import '../services/profile_service.dart';

class ProgressScreen extends StatefulWidget {
  /// Notifié à chaque retour sur l'onglet : re-télécharge les données en
  /// gardant les valeurs affichées (pas de skeleton après le 1er chargement).
  final Listenable? refresh;

  const ProgressScreen({super.key, this.refresh});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic>? _profile;
  List<LeagueUser> _leaderboard = [];
  List<int> _weeklyXp = const [0, 0, 0, 0, 0, 0, 0];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.refresh?.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.refresh?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ProfileService.getOrCreateProfile(),
      ProfileService.fetchLeaderboard(),
      ProfileService.fetchWeeklyXp(),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = results[0] as Map<String, dynamic>?;
      _leaderboard = results[1] as List<LeagueUser>;
      _weeklyXp = results[2] as List<int>;
      _loading = false;
    });
  }

  int get _streak => ProfileService.effectiveStreak(_profile);
  int get _xp => _profile?['xp'] as int? ?? 0;
  int get _level => _profile?['level'] as int? ?? 1;
  String get _league =>
      ProfileService.normalizeLeague(_profile?['league'] as String?);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: ContentClamp(
        padding: EdgeInsets.fromLTRB(
          Responsive.isMobile(context)
              ? LinguaSpacing.screen
              : LinguaSpacing.xxxl,
          LinguaSpacing.sm,
          Responsive.isMobile(context)
              ? LinguaSpacing.screen
              : LinguaSpacing.xxxl,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: LinguaSpacing.xl),
            _buildWeeklyChart(),
            const SizedBox(height: LinguaSpacing.stackSection),
            // L'emoji de ligue disparaît du libellé : l'écusson le porte.
            SectionLabel(tr('progress.league', {'l': tr('league.$_league')})),
            const SizedBox(height: LinguaSpacing.md),
            _buildLeague(),
            const SizedBox(height: LinguaSpacing.stackSection),
            SectionLabel(tr('progress.stats')),
            const SizedBox(height: LinguaSpacing.md),
            _loading ? _buildStatsLoading() : _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenTitle(tr('progress.title'), size: 30),
        const SizedBox(height: 2),
        Text(
          tr('progress.this_week'),
          style: GoogleFonts.manrope(color: t.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  // Initiale du jour de la semaine (L M M J V S D) pour les 7 derniers jours.
  String _dayLabel(int i) {
    final d = DateTime.now().subtract(Duration(days: 6 - i));
    return const ['L', 'M', 'M', 'J', 'V', 'S', 'D'][d.weekday - 1];
  }

  Widget _buildWeeklyChart() {
    final t = context.tokens;
    final xpData = _weeklyXp;
    final maxXp = xpData.reduce((a, b) => a > b ? a : b);
    final totalWeek = xpData.fold(0, (a, b) => a + b);

    return CopilotCard(
      padding: const EdgeInsets.all(LinguaSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // L'XP est or, pas bleu : le bleu est la couleur de
                  // l'interaction.
                  Text(
                    '$totalWeek XP',
                    style: LinguaType.number(t.goldInk, size: 26),
                  ),
                  Text(
                    tr('progress.week_xp'),
                    style: GoogleFonts.manrope(
                      color: t.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Icon(Icons.trending_up_rounded, size: 22, color: t.textTertiary),
            ],
          ),
          const SizedBox(height: LinguaSpacing.xl),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final xp = xpData[i];
                final height = maxXp > 0 ? (xp / maxXp) * 72 : 0.0;
                final isToday = i == 6;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LinguaSpacing.xs,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isToday)
                          Text(
                            '$xp',
                            style: LinguaType.number(t.goldInk, size: 9),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 60),
                          curve: LinguaCurves.out,
                          height: height,
                          decoration: BoxDecoration(
                            color: isToday
                                ? t.gold
                                : t.gold.withValues(alpha: 0.35),
                            borderRadius: LinguaRadius.rXs,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dayLabel(i),
                          style: GoogleFonts.jetBrainsMono(
                            color: isToday ? t.goldInk : t.textTertiary,
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeague() {
    final t = context.tokens;
    if (_loading) {
      return CopilotCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(LinguaSpacing.lg),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: t.accent),
            ),
          ),
        ),
      );
    }
    if (_leaderboard.isEmpty) {
      return CopilotCard(
        child: Text(
          tr('progress.empty_league'),
          style: GoogleFonts.manrope(
            color: t.textSecondary,
            fontSize: 14,
            height: 1.55,
          ),
        ),
      );
    }
    return CopilotCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _leaderboard.length; i++) ...[
            // Saut de rangs (ligne de l'utilisateur hors top) → ellipse.
            if (i > 0)
              if (_leaderboard[i].rank > _leaderboard[i - 1].rank + 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    '· · ·',
                    style: GoogleFonts.jetBrainsMono(
                      color: t.textFaint,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Divider(height: 1, color: t.outlineSubtle),
            _LeagueRow(user: _leaderboard[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsLoading() {
    final t = context.tokens;
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Container(
            height: 90,
            margin: EdgeInsets.only(right: i == 2 ? 0 : LinguaSpacing.md),
            decoration: BoxDecoration(
              color: t.surfaceRaised,
              borderRadius: LinguaRadius.rCard,
              border: Border.all(color: t.outlineSubtle),
            ),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: t.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    // Chaque compteur prend le registre de ce qu'il mesure : la série la
    // flamme, l'XP et le niveau l'or.
    return Row(
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.local_fire_department_rounded,
            value: '${_streak}j',
            label: tr('stat.streak'),
            tone: ChipTone.streak,
          ),
        ),
        const SizedBox(width: LinguaSpacing.md),
        Expanded(
          child: StatTile(
            icon: Icons.star_rounded,
            value: '$_xp',
            label: tr('stat.xp_total'),
            tone: ChipTone.reward,
          ),
        ),
        const SizedBox(width: LinguaSpacing.md),
        Expanded(
          child: StatTile(
            icon: Icons.military_tech_rounded,
            value: '$_level',
            label: tr('stat.level'),
            tone: ChipTone.reward,
          ),
        ),
      ],
    );
  }
}

class _LeagueRow extends StatelessWidget {
  final dynamic user;
  const _LeagueRow({required this.user});

  /// Le podium dans les rampes de marque plutôt qu'en emoji : or, acier,
  /// flamme. Un emoji ne suit ni le thème ni la couleur de marque, et son
  /// dessin change d'un appareil à l'autre.
  static Color? _podium(int rank, LinguaTokens t) => switch (rank) {
        1 => t.gold,
        2 => t.steel,
        3 => t.ember,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rank = user.rank as int;
    final isCurrentUser = user.isCurrentUser as bool;
    final podium = _podium(rank, t);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LinguaSpacing.lg,
        vertical: LinguaSpacing.md,
      ),
      decoration: isCurrentUser
          ? BoxDecoration(
              color: t.accentTint,
              borderRadius: LinguaRadius.rCard,
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: podium != null
                ? Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: podium.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: podium, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$rank',
                        style: GoogleFonts.jetBrainsMono(
                          color: t.isDark ? podium : t.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      color: t.textTertiary,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: LinguaSpacing.md),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: user.avatarColor as Color,
              shape: BoxShape.circle,
              border:
                  isCurrentUser ? Border.all(color: t.accent, width: 2) : null,
            ),
            child: Center(
              child: Text(
                user.avatarInitials as String,
                style: GoogleFonts.oswald(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: LinguaSpacing.md),
          Expanded(
            child: Text(
              user.name as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: isCurrentUser ? t.textPrimary : t.textSecondary,
                fontSize: 15,
                fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            '${user.xp} XP',
            style: LinguaType.number(
              isCurrentUser ? t.goldInk : t.textTertiary,
              size: 13,
            ),
          ),
        ],
      ),
    );
  }
}
