import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_components.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_controller.dart';
import 'main_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _langOpen = false;

  /// La langue de l'écran d'auth suit la langue d'interface globale.
  String get _selectedLang => localeController.value;

  // ── Labels localisés ─────────────────────────────────────────────────────
  String get _tagline => switch (_selectedLang) {
        'EN' => 'Learn Chechen',
        'RU' => 'Учите чеченский',
        'CE' => 'Noxçiyŋ mott jamabe',
        _ => 'Apprends le tchétchène',
      };
  String get _emailLabel => switch (_selectedLang) {
        'EN' => 'Email address',
        'RU' => 'Электронная почта',
        'CE' => 'Elektronni poşt',
        _ => 'Adresse email',
      };
  String get _passwordLabel => switch (_selectedLang) {
        'EN' => 'Password',
        'RU' => 'Пароль',
        'CE' => 'Doġanaŋ doş',
        _ => 'Mot de passe',
      };
  String get _forgotLabel => switch (_selectedLang) {
        'EN' => 'Forgot password?',
        'RU' => 'Забыли пароль?',
        'CE' => 'Doġanaŋ doş dicdella?',
        _ => 'Mot de passe oublié ?',
      };
  String get _signInLabel => switch (_selectedLang) {
        'EN' => 'Sign in',
        'RU' => 'Войти',
        'CE' => 'Çuvaxa',
        _ => 'Se connecter',
      };
  String get _signUpLabel => switch (_selectedLang) {
        'EN' => 'Create account',
        'RU' => 'Создать аккаунт',
        'CE' => 'Akkaunt qolla',
        _ => 'Créer un compte',
      };
  String get _orLabel => switch (_selectedLang) {
        'EN' => 'or',
        'RU' => 'или',
        'CE' => 'ya',
        _ => 'ou',
      };
  String get _googleLabel => switch (_selectedLang) {
        'EN' => 'Continue with Google',
        'RU' => 'Войти через Google',
        'CE' => 'Google-ca djadaẋa',
        _ => 'Continuer avec Google',
      };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    final t = context.tokens;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: t.danger,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError(tr('err.fill_fields'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService.signIn(email, password);
      _navigateToMain();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(tr('err.generic'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signInWithGoogle();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Connexion Google échouée.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.surfaceBase,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (_langOpen) setState(() => _langOpen = false);
          },
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            child: ContentClamp(
              maxWidth: 440,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildLangSelector(t),
                  ),
                  const SizedBox(height: 28),

                  // Logo + titre
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: t.shadowMd,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/images/IconeApp.png',
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            color: t.accentSoft,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(Icons.language, size: 44, color: t.accent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'LinguaCE',
                    style: GoogleFonts.spaceMono(
                      color: t.accent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_tagline,
                      style: GoogleFonts.inter(
                          color: t.textSecondary, fontSize: 14)),

                  const SizedBox(height: 36),

                  // Champs
                  _buildTextField(
                    t,
                    controller: _emailController,
                    label: _emailLabel,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    t,
                    controller: _passwordController,
                    label: _passwordLabel,
                    icon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: t.textTertiary,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(_forgotLabel,
                          style: GoogleFonts.inter(
                              color: t.accent, fontSize: 13)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Boutons
                  CopilotButton(
                    label: _signInLabel,
                    expand: true,
                    loading: _isLoading,
                    onPressed: _signIn,
                  ),
                  const SizedBox(height: 12),
                  CopilotButton(
                    label: _signUpLabel,
                    variant: CopilotButtonVariant.ghost,
                    expand: true,
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RegisterScreen(lang: _selectedLang),
                              ),
                            ),
                  ),

                  const SizedBox(height: 26),
                  _buildDivider(t),
                  const SizedBox(height: 26),
                  _buildGoogleButton(t),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Sélecteur de langue repliable ────────────────────────────────────────
  Widget _buildLangSelector(LinguaTokens t) {
    const langs = ['FR', 'EN', 'RU', 'CE'];
    return GestureDetector(
      onTap: () => setState(() => _langOpen = !_langOpen),
      child: AnimatedSize(
        duration: LinguaDuration.base,
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: t.surfaceSunken,
            borderRadius: LinguaRadius.rPill,
            border: Border.all(color: t.accent, width: 1.2),
            boxShadow: t.shadowSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _langOpen
                ? langs.map((lang) => _buildChip(t, lang)).toList()
                : [
                    _buildChip(t, _selectedLang),
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_left_rounded,
                        color: t.accent, size: 16),
                    const SizedBox(width: 4),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(LinguaTokens t, String lang) {
    final selected = _selectedLang == lang;
    return GestureDetector(
      onTap: _langOpen
          ? () {
              localeController.setLang(lang);
              setState(() => _langOpen = false);
            }
          : null,
      child: AnimatedContainer(
        duration: LinguaDuration.fast,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? t.accent : Colors.transparent,
          borderRadius: LinguaRadius.rMd,
        ),
        child: Text(
          lang,
          style: GoogleFonts.spaceMono(
            color: selected ? t.onAccent : t.accent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Champ texte ──────────────────────────────────────────────────────────
  Widget _buildTextField(
    LinguaTokens t, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: t.textTertiary, fontSize: 14),
        prefixIcon: Icon(icon, color: t.textTertiary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: t.surfaceSunken,
        border: OutlineInputBorder(
          borderRadius: LinguaRadius.rMd,
          borderSide: BorderSide(color: t.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: LinguaRadius.rMd,
          borderSide: BorderSide(color: t.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: LinguaRadius.rMd,
          borderSide: BorderSide(color: t.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDivider(LinguaTokens t) {
    return Row(
      children: [
        Expanded(child: Divider(color: t.outline, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(_orLabel,
              style: GoogleFonts.inter(color: t.textTertiary, fontSize: 13)),
        ),
        Expanded(child: Divider(color: t.outline, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton(LinguaTokens t) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: t.outline, width: 1.5),
          backgroundColor: t.surfaceSunken,
          shape:
              const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _googleLabel,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: t.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
