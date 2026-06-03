import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../data/mock_data.dart';
import '../i18n/app_strings.dart';
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
        const ChatScreen(),
        const LearnScreen(),
        ProgressScreen(key: ValueKey('progress-$_progressSeed')),
      ];

  static const _titleKeys = ['', 'title.chat', 'title.learn', 'title.progress'];

  @override
  Widget build(BuildContext context) {
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
  }

  AppBar _buildAppBar() {
    final t = context.tokens;
    return AppBar(
      backgroundColor: t.surfaceBase,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
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
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildAvatarButton(t),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarButton(LinguaTokens t) {
    final user = MockData.user;
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
          user.avatarInitials,
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
