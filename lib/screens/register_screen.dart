import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_components.dart';
import '../design/responsive.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String lang;
  const RegisterScreen({super.key, this.lang = 'FR'});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String get _l => widget.lang;

  String get _title => switch (_l) {
        'EN' => 'Create account',
        'RU' => 'Создать аккаунт',
        'CE' => 'Akkaunt qolla',
        _ => 'Créer un compte',
      };
  String get _subtitle => switch (_l) {
        'EN' => 'Join LinguaCE and start learning Chechen.',
        'RU' => 'Присоединяйся к LinguaCE и начни учить чеченский.',
        'CE' => 'Djaxotta LinguaCE-na ṫe, noxçiyŋ mott jamabaŋ vola a lo.',
        _ => 'Rejoins LinguaCE et commence à apprendre le tchétchène.',
      };
  String get _nameLabel => switch (_l) {
        'EN' => 'Username',
        'RU' => 'Имя пользователя',
        'CE' => 'Deq̇aşxoçuŋ ċe',
        _ => 'Nom d\'utilisateur',
      };
  String get _emailLabel => switch (_l) {
        'EN' => 'Email address',
        'RU' => 'Электронная почта',
        'CE' => 'Elektronni poşt',
        _ => 'Adresse email',
      };
  String get _passwordLabel => switch (_l) {
        'EN' => 'Password',
        'RU' => 'Пароль',
        'CE' => 'Doġanaŋ doş',
        _ => 'Mot de passe',
      };
  String get _passwordHint => switch (_l) {
        'EN' => 'At least 6 characters',
        'RU' => 'Минимум 6 символов',
        'CE' => '6-l k̇ezig ca xila deza elp/surt',
        _ => 'Au moins 6 caractères',
      };
  String get _confirmLabel => switch (_l) {
        'EN' => 'Confirm password',
        'RU' => 'Подтвердить пароль',
        'CE' => 'Doġanaŋ doş ç̇aġde',
        _ => 'Confirmer le mot de passe',
      };
  String get _submitLabel => switch (_l) {
        'EN' => 'Create my account',
        'RU' => 'Создать аккаунт',
        'CE' => 'Saŋ akkaunt qolla',
        _ => 'Créer mon compte',
      };
  String get _alreadyLabel => switch (_l) {
        'EN' => 'Already have an account? ',
        'RU' => 'Уже есть аккаунт? ',
        'CE' => 'Akkaunt yuy ẋaŋ? ',
        _ => 'Déjà un compte ? ',
      };
  String get _signInLabel => switch (_l) {
        'EN' => 'Sign in',
        'RU' => 'Войти',
        'CE' => 'Çuvaxa',
        _ => 'Se connecter',
      };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('Veuillez remplir tous les champs.');
      return;
    }
    if (password.length < 6) {
      _showError('Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }
    if (password != confirm) {
      _showError('Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService.signUp(email, password);
      if (!mounted) return;

      if (response.session != null) {
        await ProfileService.createProfile(name);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (_) => false,
        );
      } else {
        if (!mounted) return;
        final t = context.tokens;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vérifie ton email pour confirmer ton compte.',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: t.accentStrong,
            behavior: SnackBarBehavior.floating,
            shape:
                const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Une erreur est survenue. Réessaie.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.surfaceBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: t.textSecondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ContentClamp(
            maxWidth: 440,
            padding: const EdgeInsets.fromLTRB(28, 4, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title,
                    style: GoogleFonts.playfairDisplay(
                        color: t.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(_subtitle,
                    style: GoogleFonts.inter(
                        color: t.textSecondary, fontSize: 14, height: 1.4)),
                const SizedBox(height: 36),

                _buildTextField(t,
                    controller: _nameController,
                    label: _nameLabel,
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name),
                const SizedBox(height: 14),
                _buildTextField(t,
                    controller: _emailController,
                    label: _emailLabel,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
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
                        size: 20),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(_passwordHint,
                      style: GoogleFonts.inter(
                          color: t.textTertiary, fontSize: 12)),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  t,
                  controller: _confirmController,
                  label: _confirmLabel,
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: t.textTertiary,
                        size: 20),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),

                const SizedBox(height: 32),

                CopilotButton(
                  label: _submitLabel,
                  expand: true,
                  loading: _isLoading,
                  onPressed: _signUp,
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                            fontSize: 13, color: t.textSecondary),
                        children: [
                          TextSpan(text: _alreadyLabel),
                          TextSpan(
                            text: _signInLabel,
                            style: GoogleFonts.inter(
                                color: t.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}
