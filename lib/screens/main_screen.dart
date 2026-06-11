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

  // Signaux de rafraîchissement : quand on revient sur Accueil / Progrès,
  // l'écran re-télécharge ses données EN PLACE (les valeurs affichées
  // restent visibles pendant le chargement — pas de skeleton qui clignote,
  // contrairement à l'ancien mécanisme de graines qui recréait l'écran).
  final _refreshHome = ValueNotifier(0);
  final _refreshProgress = ValueNotifier(0);

  @override
  void dispose() {
    _refreshHome.dispose();
    _refreshProgress.dispose();
    super.dispose();
  }

  void _setTab(int index) => setState(() {
        _currentIndex = index;
        if (index == 0) _refreshHome.value++;
        if (index == 3) _refreshProgress.value++;
      });

  List<Widget> get _screens => [
        HomeScreen(onTabChange: _setTab, refresh: _refreshHome),
        ChatScreen(key: ValueKey('chat-${localeController.value}')),
        LearnScreen(key: ValueKey('learn-${localeController.value}')),
        ProgressScreen(refresh: _refreshProgress),
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
        return PopScope(
          // Retour Android : depuis un autre onglet, revenir d'abord à
          // l'Accueil au lieu de quitter l'application.
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _setTab(0);
          },
          child: Scaffold(
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
      // Hamburger explicite : taper sur le logo ouvrait le drawer, mais
      // personne ne devine cette affordance — l'icône standard la rend
      // visible (le logo reste cliquable).
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: Icon(Icons.menu_rounded, color: t.textPrimary, size: 22),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            behavior: HitTestBehavior.opaque,
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
        ],
      ),
      leadingWidth: 168,
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
