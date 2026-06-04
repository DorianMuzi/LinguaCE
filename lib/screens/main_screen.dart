import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_controller.dart';
import '../services/profile_service.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/app_drawer.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'learn_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Profil réel (pseudo → initiale de l'avatar de l'AppBar).
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getOrCreateProfile();
    if (mounted) setState(() => _profile = profile);
  }

  String get _avatarInitial {
    final name = (_profile?['username'] as String?)?.trim() ?? '';
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // Graines incrémentées à chaque visite → forcent le rechargement des
  // données (série, XP, progression) quand on revient sur Accueil / Progrès.
  int _homeSeed = 0;
  int _progressSeed = 0;

  void _setTab(int index) => setState(() {
        _currentIndex = index;
        if (index == 0) _homeSeed++;
        if (index == 3) _progressSeed++;
      });

  List<Widget> get _screens => [
        HomeScreen(key: ValueKey('home-$_homeSeed'), onTabChange: _setTab),
        ChatScreen(key: ValueKey('chat-${localeController.value}')),
        LearnScreen(key: ValueKey('learn-${localeController.value}')),
        ProgressScreen(key: ValueKey('progress-$_progressSeed')),
      ];

  static const _titleKeys = ['', 'title.chat', 'title.learn', 'title.progress'];

  @override
  Widget build(BuildContext context) {
    // Abonnement à la langue : reconstruit la coque (+ onglets, AppBar, nav)
    // quand l'utilisateur change la langue d'interface.
    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        final t = context.tokens;
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: t.surfaceBase,
          extendBody: true,
          drawer: const AppDrawer(),
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: FloatingNavBar(
                  currentIndex: _currentIndex,
                  onTap: _setTab,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    final t = context.tokens;
    return AppBar(
      backgroundColor: t.surfaceBase,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Lingua',
                style: GoogleFonts.cormorantGaramond(
                  color: t.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'CE',
                style: GoogleFonts.cormorantGaramond(
                  color: t.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      leadingWidth: 130,
      title: _currentIndex == 0
          ? null
          : Text(
              tr(_titleKeys[_currentIndex]),
              style: GoogleFonts.playfairDisplay(
                color: t.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
      centerTitle: true,
      actions: [
        Semantics(
          button: true,
          label: tr('nav.profile'),
          child: Tooltip(
            message: tr('nav.profile'),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
                // Le pseudo a pu changer dans l'écran Profil → on rafraîchit.
                _loadProfile();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 16, 6),
                child: _buildAvatarButton(t),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarButton(LinguaTokens t) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: t.accentSoft,
        shape: BoxShape.circle,
        border: Border.all(color: t.accent, width: 1.5),
      ),
      child: Center(
        child: Text(
          _avatarInitial,
          style: GoogleFonts.playfairDisplay(
            color: t.accentStrong,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
