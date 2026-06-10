import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_components.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/xp_bar.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getOrCreateProfile();
    if (mounted) setState(() { _profile = profile; _loading = false; });
  }

  String get _username => _profile?['username'] as String? ?? 'Apprenant';
  String get _initials =>
      _username.isNotEmpty ? _username[0].toUpperCase() : 'A';
  int get _xp => _profile?['xp'] as int? ?? 0;
  int get _level => _profile?['level'] as int? ?? 1;
  int get _xpToNext => _level * 1000;
  int get _streak => ProfileService.effectiveStreak(_profile);
  int get _lessonsCompleted => _profile?['lessons_completed'] as int? ?? 0;
  String get _league =>
      ProfileService.normalizeLeague(_profile?['league'] as String?);

  Future<void> _editUsername() async {
    final t = context.tokens;
    final controller = TextEditingController(text: _username);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
        title: Text(tr('profile.edit_name'),
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary, fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: tr('profile.username'),
            hintStyle: GoogleFonts.inter(color: t.textTertiary),
            filled: true,
            fillColor: t.surfaceSunken,
            border: OutlineInputBorder(
              borderRadius: LinguaRadius.rSm,
              borderSide: BorderSide(color: t.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: LinguaRadius.rSm,
              borderSide: BorderSide(color: t.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: LinguaRadius.rSm,
              borderSide: BorderSide(color: t.accent, width: 1.5),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('common.cancel'),
                style: GoogleFonts.inter(color: t.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(tr('common.save'),
                style: GoogleFonts.inter(
                    color: t.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newName == null || newName.isEmpty || newName == _username) return;
    await ProfileService.updateUsername(newName);
    _loadProfile();
  }

  Future<void> _signOut() async {
    final t = context.tokens;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
        title: Text(tr('profile.logout_q'),
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary, fontSize: 18)),
        content: Text(tr('profile.logout_desc'),
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('common.cancel'),
                style: GoogleFonts.inter(color: t.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('profile.logout'),
                style: GoogleFonts.inter(
                    color: t.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _signingOut = true);
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('title.profile'),
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: t.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: t.accent))
          : SingleChildScrollView(
              child: ContentClamp(
                maxWidth: 560,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildAvatar(t),
                    const SizedBox(height: 20),
                    CopilotCard(
                        child: XpBar(
                            xp: _xp, xpToNext: _xpToNext, level: _level)),
                    const SizedBox(height: 24),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildSettingsSection(t),
                    const SizedBox(height: 20),
                    _buildLogoutButton(t),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatar(LinguaTokens t) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: t.accentSoft,
                shape: BoxShape.circle,
                border: Border.all(color: t.accent, width: 3),
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: GoogleFonts.playfairDisplay(
                    color: t.accentStrong,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _editUsername,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: t.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.surfaceBase, width: 2),
                  ),
                  child: Icon(Icons.edit_rounded,
                      color: t.onAccent, size: 13),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_username,
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AccentChip(
                label: tr('progress.league', {'l': tr('league.$_league')}),
                emoji: ProfileService.leagueEmoji(_league)),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: t.surfaceSunken,
                borderRadius: LinguaRadius.rPill,
                border: Border.all(color: t.outline),
              ),
              child: Text(
                  '🔥 $_streak ${tr(_streak != 1 ? 'profile.days' : 'profile.day')}',
                  style: GoogleFonts.spaceMono(
                      color: t.textSecondary, fontSize: 11)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final cols = Responsive.value(context, mobile: 2, tablet: 4, desktop: 4);
    final stats = [
      ('⭐', '$_xp', tr('stat.xp_total')),
      ('🏆', '$_level', tr('stat.level')),
      ('🔥', '${_streak}j', tr('stat.streak')),
      ('📚', '$_lessonsCompleted', tr('stat.lessons')),
    ];
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: stats
          .map((s) => StatTile(emoji: s.$1, value: s.$2, label: s.$3))
          .toList(),
    );
  }

  Widget _buildSettingsSection(LinguaTokens t) {
    final items = [
      (Icons.notifications_outlined, tr('set.notifications'), true),
      (Icons.language_outlined, tr('set.interface_lang'), false),
      (Icons.volume_up_outlined, tr('set.sounds'), true),
      (Icons.privacy_tip_outlined, tr('set.privacy'), false),
      (Icons.help_outline_rounded, tr('set.help'), false),
    ];
    return CopilotCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((e) {
          final (icon, label, hasSwitch) = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(icon, color: t.textSecondary, size: 20),
                title: Text(label,
                    style:
                        GoogleFonts.inter(color: t.textPrimary, fontSize: 15)),
                trailing: hasSwitch
                    ? Switch(
                        value: true,
                        onChanged: (_) {},
                        activeColor: t.accent,
                      )
                    : Icon(Icons.chevron_right_rounded,
                        color: t.textSecondary, size: 20),
                onTap: () {},
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (!isLast)
                Divider(height: 1, color: t.outlineSubtle, indent: 52),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(LinguaTokens t) {
    return GestureDetector(
      onTap: _signingOut ? null : _signOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: t.surfaceRaised,
          borderRadius: LinguaRadius.rMd,
          border: Border.all(color: t.danger.withValues(alpha: 0.4)),
        ),
        child: _signingOut
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: t.danger),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: t.danger, size: 18),
                  const SizedBox(width: 8),
                  Text(tr('profile.logout_btn'),
                      style: GoogleFonts.inter(
                          color: t.danger,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                ],
              ),
      ),
    );
  }
}
