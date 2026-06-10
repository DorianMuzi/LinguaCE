import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show themeController;
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_controller.dart';
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
  String get _league =>
      ProfileService.normalizeLeague(_profile?['league'] as String?);
  String get _initials =>
      _username.isNotEmpty ? _username[0].toUpperCase() : 'A';

  /// Partage : copie le lien de l'app dans le presse-papier + confirmation.
  Future<void> _shareApp() async {
    final messenger = ScaffoldMessenger.of(context);
    final t = context.tokens;
    Navigator.pop(context); // ferme le drawer
    await Clipboard.setData(const ClipboardData(
      text: 'LinguaCE — noxçiyŋ mott jamabe 📚\n'
          'https://github.com/DorianMuzi/LinguaCE',
    ));
    messenger.showSnackBar(SnackBar(
      content: Text(tr('chat.copied'),
          style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: t.accentStrong,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _info(String message) {
    if (!mounted) return;
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
            Text(tr('about.version'),
                style:
                    GoogleFonts.spaceMono(color: t.accent, fontSize: 12)),
            const SizedBox(height: 12),
            Text(
              tr('about.desc'),
              style: GoogleFonts.inter(
                  color: t.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              tr('about.made'),
              style: GoogleFonts.inter(
                  color: t.textTertiary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('common.close'),
                style: GoogleFonts.inter(color: t.accent)),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    final t = context.tokens;
    // Capturé tant que le drawer est monté : reste valide après sa fermeture.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context); // ferme le drawer
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: t.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
        title: Text(tr('set.interface_lang'),
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocaleController.supported.map((code) {
            final selected = localeController.value == code;
            return ListTile(
              title: Text('$code — ${LocaleController.names[code]}',
                  style: GoogleFonts.inter(
                      color: selected ? t.accent : t.textPrimary,
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal)),
              trailing: selected
                  ? Icon(Icons.check_rounded, color: t.accent, size: 18)
                  : null,
              onTap: () {
                Navigator.of(dialogContext).pop(); // ferme la boîte de dialogue
                localeController.setLang(code);
                messenger.showSnackBar(SnackBar(
                  content: Text(
                      tr('lang.selected',
                          {'lang': LocaleController.names[code]!}),
                      style: GoogleFonts.inter(color: Colors.white)),
                  backgroundColor: t.accentStrong,
                  behavior: SnackBarBehavior.floating,
                  shape: const RoundedRectangleBorder(
                      borderRadius: LinguaRadius.rMd),
                  margin: const EdgeInsets.all(16),
                ));
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
                  Text(tr('drawer.tagline'),
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
                              tr('drawer.profile_meta', {
                                'emoji': ProfileService.leagueEmoji(_league),
                                'l': '$_level',
                                'league': tr('league.$_league'),
                              }),
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
                    label: tr('drawer.home'),
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    label: tr('drawer.about'),
                    onTap: _showAbout,
                  ),
                  _DrawerItem(
                    icon: Icons.language_outlined,
                    label: tr('set.interface_lang'),
                    onTap: _showLanguagePicker,
                  ),
                  _DrawerItem(
                    icon: t.isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    label: tr('drawer.theme'),
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
                    label: tr('set.notifications'),
                    onTap: () {
                      Navigator.pop(context);
                      _info(tr('common.soon'));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.share_outlined,
                    label: tr('drawer.share'),
                    onTap: _shareApp,
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
                      Text(tr('profile.logout_btn'),
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
