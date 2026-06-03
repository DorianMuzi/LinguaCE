import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_components.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError(tr('forgot.err_empty'));
      return;
    }
    if (!RegExp(r'^[\w\-.]+@[\w\-]+\.\w+$').hasMatch(email)) {
      _showError(tr('forgot.err_invalid'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } on AuthException catch (e) {
      if (mounted) {
        _showError(e.message);
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        _showError(tr('err.generic'));
        setState(() => _isLoading = false);
      }
    }
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
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
            child: _emailSent ? _buildSuccessView(t) : _buildFormView(t),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(LinguaTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: t.accentSoft,
            shape: BoxShape.circle,
            border: Border.all(color: t.accent.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Icon(Icons.lock_reset_rounded, color: t.accent, size: 30),
        ),
        const SizedBox(height: 24),
        Text(tr('forgot.title'),
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
          tr('forgot.desc'),
          style:
              GoogleFonts.inter(color: t.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 36),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: tr('forgot.email'),
            labelStyle: GoogleFonts.inter(color: t.textTertiary, fontSize: 14),
            prefixIcon:
                Icon(Icons.email_outlined, color: t.textTertiary, size: 20),
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
          onSubmitted: (_) => _resetPassword(),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 28),
        CopilotButton(
          label: tr('forgot.send'),
          expand: true,
          loading: _isLoading,
          onPressed: _resetPassword,
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('forgot.back'),
                style: GoogleFonts.inter(
                  color: t.textSecondary,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: t.textSecondary,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(LinguaTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: t.accentSoft,
            shape: BoxShape.circle,
            border: Border.all(color: t.accent, width: 2),
          ),
          child:
              Icon(Icons.mark_email_read_outlined, color: t.accent, size: 44),
        ),
        const SizedBox(height: 28),
        Text(tr('forgot.sent_title'),
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 14),
        Text(tr('forgot.sent_to'),
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(_emailController.text.trim(),
            style: GoogleFonts.spaceMono(
                color: t.accent, fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(
          tr('forgot.check_inbox'),
          style:
              GoogleFonts.inter(color: t.textTertiary, fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        CopilotButton(
          label: tr('forgot.back'),
          expand: true,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() {
            _emailSent = false;
            _emailController.clear();
          }),
          child: Text(tr('forgot.other_email'),
              style: GoogleFonts.inter(
                color: t.textSecondary,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: t.textSecondary,
              )),
        ),
      ],
    );
  }
}
