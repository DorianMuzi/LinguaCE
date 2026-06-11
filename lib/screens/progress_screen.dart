import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_components.dart';
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
          Responsive.isMobile(context) ? 20 : 32,
          8,
          Responsive.isMobile(context) ? 20 : 32,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildWeeklyChart(),
            const SizedBox(height: 28),
            SectionLabel(
                '${tr('progress.league', {'l': tr('league.$_league')})} ${ProfileService.leagueEmoji(_league)}'),
            const SizedBox(height: 12),
            _buildLeague(),
            const SizedBox(height: 28),
            SectionLabel(tr('progress.stats')),
            const SizedBox(height: 12),
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
        Text(tr('progress.title'),
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        Text(tr('progress.this_week'),
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14)),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$totalWeek XP',
                      style: GoogleFonts.playfairDisplay(
                          color: t.accent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text(tr('progress.week_xp'),
                      style: GoogleFonts.inter(
                          color: t.textSecondary, fontSize: 13)),
                ],
              ),
              const Text('📈', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isToday)
                          Text('$xp',
                              style: GoogleFonts.spaceMono(
                                  color: t.accent, fontSize: 9)),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 60),
                          height: height,
                          decoration: BoxDecoration(
                            color: isToday
                                ? t.accent
                                : t.accent.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_dayLabel(i),
                            style: GoogleFonts.spaceMono(
                                color:
                                    isToday ? t.accent : t.textSecondary,
                                fontSize: 11)),
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
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 22,
              height: 22,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: t.accent),
            ),
          ),
        ),
      );
    }
    if (_leaderboard.isEmpty) {
      return CopilotCard(
        child: Text(tr('progress.empty_league'),
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14)),
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
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('· · ·',
                      style: GoogleFonts.inter(
                          color: t.textTertiary, fontSize: 12)),
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
        (_) => Expanded(
          child: Container(
            height: 90,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: t.surfaceRaised,
              borderRadius: LinguaRadius.rMd,
              border: Border.all(color: t.outlineSubtle),
            ),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: t.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
            child: StatTile(
                emoji: '🔥',
                value: '${_streak}j',
                label: tr('stat.streak'))),
        const SizedBox(width: 12),
        Expanded(
            child: StatTile(
                emoji: '⭐', value: '$_xp', label: tr('stat.xp_total'))),
        const SizedBox(width: 12),
        Expanded(
            child: StatTile(
                emoji: '🏆', value: '$_level', label: tr('stat.level'))),
      ],
    );
  }
}

class _LeagueRow extends StatelessWidget {
  final dynamic user;
  const _LeagueRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rank = user.rank as int;
    final isCurrentUser = user.isCurrentUser as bool;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: isCurrentUser
          ? BoxDecoration(
              color: t.accentSoft,
              borderRadius: LinguaRadius.rLg,
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
              style: GoogleFonts.spaceMono(
                color: rank <= 3 ? null : t.textSecondary,
                fontSize: rank <= 3 ? 18 : 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: user.avatarColor as Color,
              shape: BoxShape.circle,
              border: isCurrentUser
                  ? Border.all(color: t.accent, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                user.avatarInitials as String,
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: isCurrentUser ? t.textPrimary : t.textSecondary,
                fontSize: 15,
                fontWeight:
                    isCurrentUser ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${user.xp} XP',
            style: GoogleFonts.spaceMono(
              color: isCurrentUser ? t.accent : t.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
