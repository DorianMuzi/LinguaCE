import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show themeController;
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import '../screens/auth_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await ProfileService.getOrCreateProfile();
      if (mounted) setState(() => _profile = p);
    } catch (_) {}
  }

  String get _username => _profile?['username'] as String? ?? 'Apprenant';
  int get _level => _profile?['level'] as int? ?? 1;
  String get _league => _profile?['league'] as String? ?? 'Aigle';
  String get _initials =>
      _username.isNotEmpty ? _username[0].toUpperCase() : 'A';

  String _leagueEmoji(String l) => switch (l) {
        'Diamant' => '💎',
        'Or' => '🥇',
        'Argent' => '🥈',
        _ => '🦅',
      };

  void _info(String message) {
    final t = context.tokens;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(message, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: t.accentStrong,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _signOut() async {
    final t = context.tokens;
    Navigator.pop(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
        title: Text('Se déconnecter ?',
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary, fontSize: 18)),
        content: Text('Tu devras te reconnecter pour accéder à ton profil.',
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
                style: GoogleFonts.inter(color: t.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Déconnecter',
                style: GoogleFonts.inter(
                    color: t.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  void _showAbout() {
    final t = context.tokens;
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: t.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
        title: Row(children: [
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
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0',
                style:
                    GoogleFonts.spaceMono(color: t.accent, fontSize: 12)),
            const SizedBox(height: 12),
            Text(
              'LinguaCE est une application mobile d\'apprentissage de la langue tchétchène (нохчийн мотт) assistée par intelligence artificielle.',
              style: GoogleFonts.inter(
                  color: t.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Développée avec ❤️ pour préserver et diffuser la langue tchétchène.',
              style: GoogleFonts.inter(
                  color: t.textTertiary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer',
                style: GoogleFonts.inter(color: t.accent)),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    final t = context.tokens;
    Navigator.pop(context);
    const langs = [
      {'code': 'FR', 'label': 'Français'},
      {'code': 'EN', 'label': 'English'},
      {'code': 'RU', 'label': 'Русский'},
      {'code': 'CE', 'label': 'Нохчийн'},
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: t.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
        title: Text('Langue de l\'interface',
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: langs.map((l) {
            return ListTile(
              title: Text('${l['code']} — ${l['label']}',
                  style:
                      GoogleFonts.inter(color: t.textPrimary, fontSize: 14)),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: t.textTertiary, size: 18),
              onTap: () {
                Navigator.pop(context);
                _info('${l['label']} sélectionné');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Drawer(
      backgroundColor: t.surfaceBase,
      child: SafeArea(
        child: Column(
          children: [
            // ── En-tête ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('Lingua',
                        style: GoogleFonts.playfairDisplay(
                            color: t.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    Text('CE',
                        style: GoogleFonts.playfairDisplay(
                            color: t.accent,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 4),
                  Text('Apprendre le tchétchène',
                      style: GoogleFonts.spaceMono(
                          color: t.textSecondary,
                          fontSize: 11,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.surfaceRaised,
                      borderRadius: LinguaRadius.rMd,
                      border: Border.all(color: t.outlineSubtle),
                      boxShadow: t.shadowSm,
                    ),
                    child: Row(children: [
                      _Avatar(initials: _initials, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_username,
                                style: GoogleFonts.inter(
                                    color: t.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            Text(
                              '${_leagueEmoji(_league)} Niveau $_level · Ligue $_league',
                              style: GoogleFonts.spaceMono(
                                  color: t.accent, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: t.outlineSubtle),

            // ── Items ────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Accueil',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    label: 'À propos',
                    onTap: _showAbout,
                  ),
                  _DrawerItem(
                    icon: Icons.language_outlined,
                    label: 'Langue de l\'interface',
                    onTap: _showLanguagePicker,
                  ),
                  _DrawerItem(
                    icon: t.isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    label: 'Thème sombre',
                    trailing: Switch(
                      value: t.isDark,
                      onChanged: (v) => themeController
                          .setMode(v ? ThemeMode.dark : ThemeMode.light),
                      activeColor: t.accent,
                    ),
                    onTap: () {},
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      _info('Notifications — Bientôt disponible !');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.share_outlined,
                    label: 'Partager l\'app',
                    onTap: () {
                      Navigator.pop(context);
                      _info('Partage — Bientôt disponible !');
                    },
                  ),
                ],
              ),
            ),

            // ── Bouton déconnexion ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: GestureDetector(
                onTap: _signOut,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: t.surfaceRaised,
                    borderRadius: LinguaRadius.rMd,
                    border: Border.all(
                        color: t.danger.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: t.danger, size: 16),
                      const SizedBox(width: 8),
                      Text('Se déconnecter',
                          style: GoogleFonts.inter(
                              color: t.danger,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('LinguaCE v1.0.0',
                  style: GoogleFonts.spaceMono(
                      color: t.textTertiary, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets helpers ──────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListTile(
      leading: Icon(icon, color: t.textSecondary, size: 20),
      title: Text(label,
          style: GoogleFonts.inter(color: t.textPrimary, fontSize: 15)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const _Avatar({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.accentSoft,
        shape: BoxShape.circle,
        border: Border.all(color: t.accent, width: 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.playfairDisplay(
            color: t.accentStrong,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
