import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_components.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../i18n/app_strings.dart';
import '../models/models.dart';
import '../services/exercise_service.dart';
import '../services/lesson_service.dart';

// ═══════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════

class ExerciseScreen extends StatefulWidget {
  final LessonModel lesson;
  const ExerciseScreen({super.key, required this.lesson});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with SingleTickerProviderStateMixin {
  /// Chargés depuis la base au montage (repli hors-ligne dans le service).
  List<Exercise> _exercises = [];

  /// Nombre d'exercices de base (hors rattrapages ajoutés en fin de file) :
  /// la progression persistée reste bornée à cette valeur.
  int _baseCount = 0;
  bool _loading = true;
  int _currentIndex = 0;
  int _xpEarned = 0;
  int _mistakes = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isCompleted = false;
  bool _saveFailed = false;
  bool _retrying = false;

  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _isFlipped = false;

  int? _selectedChoice;
  final _translCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
    _translCtrl.addListener(() => setState(() {}));
    _load();
  }

  Future<void> _load() async {
    // `List.of` : copie modifiable — la boucle de rattrapage ajoute en
    // fin de file.
    final list = List.of(await ExerciseService.fetchForLesson(
      widget.lesson.id,
    ));
    if (!mounted) return;
    setState(() {
      _exercises = list;
      _baseCount = list.length;
      _loading = false;

      // Reprise : on repart de la progression partielle sauvegardée.
      // Une leçon déjà terminée (mode révision) recommence du début.
      if (list.isNotEmpty && widget.lesson.status != LessonStatus.completed) {
        _currentIndex =
            widget.lesson.completedExercises.clamp(0, list.length - 1);
      }
    });
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _translCtrl.dispose();
    super.dispose();
  }

  Exercise get _current => _exercises[_currentIndex];
  bool get _isLast => _currentIndex >= _exercises.length - 1;

  // ─── Actions ─────────────────────────────────────────────
  void _flip() {
    setState(() => _isFlipped = !_isFlipped);
    // Respecte le réglage système « animations réduites » (accessibilité).
    if (MediaQuery.of(context).disableAnimations) {
      _flipCtrl.value = _isFlipped ? 1.0 : 0.0;
    } else {
      _isFlipped ? _flipCtrl.forward() : _flipCtrl.reverse();
    }
  }

  void _confirmFlashcard() {
    setState(() => _xpEarned += 5);
    _next();
  }

  void _answerQcm(int index) {
    if (_isAnswered) return;
    final correct = index == _current.correctIndex;
    correct ? HapticFeedback.lightImpact() : HapticFeedback.mediumImpact();
    setState(() {
      _selectedChoice = index;
      _isAnswered = true;
      _isCorrect = correct;
      if (correct) {
        _xpEarned += 10;
      } else {
        _mistakes++;
      }
    });
  }

  void _checkTranslation() {
    final correct =
        _normalize(_translCtrl.text) == _normalize(_current.translit);
    correct ? HapticFeedback.lightImpact() : HapticFeedback.mediumImpact();
    setState(() {
      _isAnswered = true;
      _isCorrect = correct;
      if (correct) {
        _xpEarned += 20;
      } else {
        _mistakes++;
        _xpEarned += 5;
      }
    });
  }

  /// Comparaison tolérante : ignore la casse, les espaces multiples et les
  /// signes diacritiques du latin Muziŋ Dar (ş→s, ġ→g, ʔ/ʼ ignorés…) pour
  /// que la saisie reste réaliste avec un clavier standard.
  static String _normalize(String s) {
    const folds = {
      'ş': 's', 'ẋ': 'x', 'ç': 'c', 'ġ': 'g', 'ŋ': 'n', 'ƶ': 'z', 'ċ': 'c',
      'ü': 'u', 'ö': 'o', 'ä': 'a', 'ə': 'e',
      'ʔ': '', 'ʼ': '', 'ʻ': '', '\'': '', '`': '',
    };
    var out = s.trim().toLowerCase();
    folds.forEach((k, v) => out = out.replaceAll(k, v));
    // Retire les diacritiques combinants (ex. point suscrit de k̇, q̇).
    out = out.replaceAll(RegExp('[̀-ͯ]'), '');
    return out.replaceAll(RegExp(r'\s+'), ' ');
  }

  void _next() {
    // Boucle de rattrapage : un exercice raté revient en fin de file
    // jusqu'à être réussi (les flashcards, elles, ne se ratent pas).
    if (_isAnswered && !_isCorrect) {
      _exercises.add(_current);
    }
    if (_isLast) {
      _complete();
      return;
    }
    setState(() {
      _currentIndex++;
      _isAnswered = false;
      _isCorrect = false;
      _selectedChoice = null;
      _isFlipped = false;
      _translCtrl.clear();
    });
    _flipCtrl.reset();
  }

  Future<void> _complete() async {
    HapticFeedback.heavyImpact(); // petite célébration tactile
    setState(() => _isCompleted = true);
    final saved = await _saveCompletion();
    if (mounted && !saved) setState(() => _saveFailed = true);
  }

  Future<bool> _saveCompletion() => LessonService.completeLesson(
        lessonId: widget.lesson.id,
        completedExercises: _exercises.length,
        totalExercises: _exercises.length,
        xpEarned: _xpEarned,
      );

  /// Nouvelle tentative de sauvegarde depuis le bandeau hors-ligne.
  /// Idempotent : la garde `wasCompleted` du service empêche tout double XP.
  Future<void> _retrySave() async {
    setState(() => _retrying = true);
    final saved = await _saveCompletion();
    if (!mounted) return;
    setState(() {
      _retrying = false;
      _saveFailed = !saved;
    });
  }

  /// Progression entamée mais leçon ni terminée ni en simple révision.
  bool get _hasUnsavedProgress => !_isCompleted && _currentIndex > 0;

  /// Sortie de la leçon : confirme si une progression serait interrompue,
  /// puis la sauvegarde (best-effort) avant de fermer l'écran.
  Future<void> _requestExit() async {
    if (!_hasUnsavedProgress) {
      Navigator.pop(context);
      return;
    }
    final t = context.tokens;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
        title: Text(tr('ex.quit_q'),
            style: GoogleFonts.oswald(
                color: t.textPrimary, fontSize: 17)),
        content: Text(tr('ex.quit_desc'),
            style: GoogleFonts.manrope(color: t.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('common.continue'),
                style: GoogleFonts.manrope(
                    color: t.accentStrong, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('ex.quit_leave'),
                style: GoogleFonts.manrope(color: t.textSecondary)),
          ),
        ],
      ),
    );
    if (leave != true || !mounted) return;

    // Fire-and-forget, cohérent avec les autres écritures de l'app : on ne
    // bloque pas la fermeture sur le réseau.
    LessonService.saveProgress(
      lessonId: widget.lesson.id,
      completedExercises: _currentIndex.clamp(0, _baseCount - 1),
    );
    Navigator.pop(context);
  }

  // ─── États de chargement et de leçon vide ────────────────
  Widget _buildLoading(LinguaTokens t) => Scaffold(
        backgroundColor: t.surfaceBase,
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: t.accent),
        ),
      );

  Widget _buildEmpty(LinguaTokens t) => Scaffold(
        backgroundColor: t.surfaceBase,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(LinguaSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty_rounded,
                      size: 48, color: t.textTertiary),
                  const SizedBox(height: LinguaSpacing.lg),
                  ScreenTitle(tr('ex.empty_title'), size: 24),
                  const SizedBox(height: LinguaSpacing.sm),
                  Text(
                    tr('ex.empty_desc'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                        color: t.textSecondary, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: LinguaSpacing.xl),
                  CopilotButton(
                    label: tr('common.close'),
                    variant: CopilotButtonVariant.tonal,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // ─── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (_loading) return _buildLoading(t);
    // Leçon sans contenu : on l'explique au lieu de refermer l'écran
    // (l'ancien comportement donnait un écran qui « clignotait »).
    if (_exercises.isEmpty) return _buildEmpty(t);
    return PopScope(
      // Intercepte le retour système (geste / bouton Android) tant qu'une
      // progression serait perdue, pour passer par la confirmation.
      canPop: !_hasUnsavedProgress,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        backgroundColor: t.surfaceBase,
        body: SafeArea(
          child: _isCompleted
              ? _buildCompletion(t)
              : Column(
                  children: [
                    _buildHeader(t),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: KeyedSubtree(
                          key: ValueKey(_currentIndex),
                          child: _buildExercise(t),
                        ),
                      ),
                    ),
                    _buildFooter(t),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(LinguaTokens t) {
    final progress = (_currentIndex + 1) / _exercises.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: _requestExit,
            icon: Icon(Icons.close_rounded, color: t.textSecondary),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  backgroundColor: t.surfaceSunken,
                  valueColor: AlwaysStoppedAnimation<Color>(t.accent),
                  minHeight: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text('+$_xpEarned XP',
              style: GoogleFonts.jetBrainsMono(
                  color: t.accent, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExercise(LinguaTokens t) {
    return switch (_current.type) {
      ExerciseType.flashcard => _buildFlashcard(t),
      ExerciseType.qcm => _buildQcm(t),
      ExerciseType.translation => _buildTranslation(t),
    };
  }

  Widget _buildFooter(LinguaTokens t) {
    if (_current.type == ExerciseType.flashcard) return const SizedBox.shrink();
    if (!_isAnswered) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _next,
          style: ElevatedButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: t.onAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
            elevation: 0,
          ),
          child: Text(tr(_isLast ? 'ex.finish' : 'ex.next'),
              style:
                  GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ─── Flashcard ───────────────────────────────────────────
  Widget _buildFlashcard(LinguaTokens t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Text(tr('ex.tap_flip'),
              style: GoogleFonts.manrope(color: t.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          Expanded(
            child: GestureDetector(
              onTap: _flip,
              child: AnimatedBuilder(
                animation: _flipAnim,
                builder: (_, __) {
                  final angle = _flipAnim.value;
                  final showBack = angle > math.pi / 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: showBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: _cardBack(t))
                        : _cardFront(t),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _isFlipped ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFlipped ? _confirmFlashcard : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: t.onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                      borderRadius: LinguaRadius.rMd),
                  elevation: 0,
                ),
                child: Text(tr('ex.understood'),
                    style: GoogleFonts.manrope(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardFront(LinguaTokens t) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: t.surfaceRaised,
          borderRadius: LinguaRadius.rXl,
          border: Border.all(color: t.outline, width: 1.5),
          boxShadow: t.shadowMd,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_rounded, size: 41, color: t.textAccent),
            const SizedBox(height: 16),
            Text(_current.translit,
                style: GoogleFonts.oswald(
                    color: t.textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_current.cyrillic,
                style: GoogleFonts.manrope(color: t.textTertiary, fontSize: 16)),
            const SizedBox(height: 16),
            Text(tr('ex.tap_translate'),
                style: GoogleFonts.manrope(color: t.textTertiary, fontSize: 13)),
          ],
        ),
      );

  Widget _cardBack(LinguaTokens t) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: t.accentTint,
          borderRadius: LinguaRadius.rXl,
          border: Border.all(color: t.accent, width: 1.5),
          boxShadow: t.shadowMd,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_current.translit,
                style: GoogleFonts.jetBrainsMono(
                    color: t.accentStrong,
                    fontSize: 34,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_current.cyrillic,
                style: GoogleFonts.oswald(
                    color: t.textSecondary, fontSize: 22)),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: t.surfaceRaised,
                borderRadius: LinguaRadius.rPill,
              ),
              child: Text(_current.french,
                  style: GoogleFonts.oswald(
                      color: t.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  // ─── QCM ─────────────────────────────────────────────────
  Widget _buildQcm(LinguaTokens t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_current.prompt ?? '',
              style: GoogleFonts.oswald(
                  color: t.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.35)),
          const SizedBox(height: 28),
          ...List.generate(_current.choices!.length, (i) {
            final isSelected = _selectedChoice == i;
            final isCorrectChoice = i == _current.correctIndex;
            Color border = t.outline;
            Color bg = t.surfaceRaised;
            Color fg = t.textPrimary;

            if (_isAnswered) {
              if (isCorrectChoice) {
                border = t.success;
                bg = t.success.withValues(alpha: 0.12);
                fg = t.success;
              } else if (isSelected) {
                border = t.danger;
                bg = t.danger.withValues(alpha: 0.12);
                fg = t.danger;
              }
            } else if (isSelected) {
              border = t.accent;
              bg = t.accentTint;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: _isAnswered ? null : () => _answerQcm(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: LinguaRadius.rMd,
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_current.choices![i],
                            style: GoogleFonts.manrope(
                              color: fg,
                              fontSize: 16,
                              fontWeight: (isSelected ||
                                      (_isAnswered && isCorrectChoice))
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            )),
                      ),
                      if (_isAnswered && isCorrectChoice)
                        Icon(Icons.check_circle_rounded,
                            color: t.success, size: 22),
                      if (_isAnswered && isSelected && !isCorrectChoice)
                        Icon(Icons.cancel_rounded, color: t.danger, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_isAnswered) ...[
            const SizedBox(height: 4),
            _feedbackBanner(
              t,
              isCorrect: _isCorrect,
              correctLabel: _isCorrect
                  ? null
                  : tr('ex.answer_is',
                      {'x': _current.choices![_current.correctIndex!]}),
              xp: _isCorrect ? '+10 XP' : null,
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Translation ─────────────────────────────────────────
  Widget _buildTranslation(LinguaTokens t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.surfaceRaised,
              borderRadius: LinguaRadius.rLg,
              border: Border.all(color: t.outline),
              boxShadow: t.shadowSm,
            ),
            child: Column(
              children: [
                Icon(Icons.edit_note_rounded, size: 36, color: t.textAccent),
                const SizedBox(height: 12),
                Text(_current.prompt ?? '',
                    style: GoogleFonts.oswald(
                        color: t.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!_isAnswered) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(tr('ex.hint', {'x': _current.cyrillic}),
                  style:
                      GoogleFonts.jetBrainsMono(color: t.accent, fontSize: 12)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _translCtrl,
              style: GoogleFonts.manrope(color: t.textPrimary, fontSize: 20),
              textAlign: TextAlign.center,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: tr('ex.answer_hint'),
                hintStyle:
                    GoogleFonts.manrope(color: t.textTertiary, fontSize: 14),
                filled: true,
                fillColor: t.surfaceSunken,
                border: OutlineInputBorder(
                  borderRadius: LinguaRadius.rMd,
                  borderSide: BorderSide(color: t.outline, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: LinguaRadius.rMd,
                  borderSide: BorderSide(color: t.outline, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: LinguaRadius.rMd,
                  borderSide: BorderSide(color: t.accent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _translCtrl.text.trim().isEmpty ? null : _checkTranslation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: t.onAccent,
                  disabledBackgroundColor: t.surfaceSunken,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                      borderRadius: LinguaRadius.rMd),
                  elevation: 0,
                ),
                child: Text(tr('ex.check'),
                    style: GoogleFonts.manrope(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          if (_isAnswered) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (_isCorrect ? t.success : t.danger)
                    .withValues(alpha: 0.12),
                borderRadius: LinguaRadius.rLg,
                border: Border.all(
                    color: _isCorrect ? t.success : t.danger, width: 1.5),
              ),
              child: Column(
                children: [
                  Text(tr(_isCorrect ? 'ex.perfect' : 'ex.correct_answer'),
                      style: GoogleFonts.manrope(
                          color: _isCorrect ? t.success : t.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(_current.translit,
                      style: GoogleFonts.oswald(
                          color: t.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  Text(_current.cyrillic,
                      style: GoogleFonts.manrope(
                          color: t.textTertiary, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(_current.french,
                      style: GoogleFonts.manrope(
                          color: t.textSecondary, fontSize: 14)),
                  if (_isCorrect) ...[
                    const SizedBox(height: 8),
                    Text('+20 XP',
                        style: GoogleFonts.jetBrainsMono(
                            color: t.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Feedback banner (QCM) ───────────────────────────────
  Widget _feedbackBanner(
    LinguaTokens t, {
    required bool isCorrect,
    String? correctLabel,
    String? xp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCorrect ? t.success : t.danger).withValues(alpha: 0.12),
        borderRadius: LinguaRadius.rMd,
        border: Border.all(color: isCorrect ? t.success : t.danger),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.lightbulb_rounded,
            size: 22,
            color: isCorrect ? t.success : t.goldInk,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(isCorrect ? 'ex.correct' : 'ex.not_quite'),
                    style: GoogleFonts.manrope(
                        color: isCorrect ? t.success : t.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                if (correctLabel != null)
                  Text(correctLabel,
                      style: GoogleFonts.manrope(
                          color: t.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (xp != null)
            Text(xp,
                style: GoogleFonts.jetBrainsMono(
                    color: t.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Completion ──────────────────────────────────────────
  Widget _buildCompletion(LinguaTokens t) {
    final perfect = _mistakes == 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              perfect ? Icons.emoji_events_rounded : Icons.school_rounded,
              size: 76,
              color: perfect ? t.goldInk : t.textAccent,
            ),
            const SizedBox(height: 24),
            Text(tr(perfect ? 'ex.done_perfect' : 'ex.done'),
                style: GoogleFonts.oswald(
                    color: t.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.lesson.title,
                style: GoogleFonts.manrope(color: t.textSecondary, fontSize: 16)),
            const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: t.surfaceRaised,
                borderRadius: LinguaRadius.rLg,
                border: Border.all(color: t.outline),
                boxShadow: t.shadowSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat(t, tr('ex.xp_earned'), '+$_xpEarned',
                      Icons.star_rounded),
                  Container(width: 1, height: 40, color: t.outlineSubtle),
                  // Sans faute, le compteur passe au vert : c'est là que le
                  // succès se lit d'un coup d'œil.
                  _stat(t, tr('ex.mistakes'), '$_mistakes',
                      _mistakes == 0
                          ? Icons.check_circle_rounded
                          : Icons.lightbulb_rounded,
                      tint: _mistakes == 0 ? t.success : null),
                  Container(width: 1, height: 40, color: t.outlineSubtle),
                  _stat(t, tr('ex.exercises'), '${_exercises.length}',
                      Icons.menu_book_rounded, tint: t.textAccent),
                ],
              ),
            ),
            if (_saveFailed) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: t.danger.withValues(alpha: 0.08),
                  borderRadius: LinguaRadius.rMd,
                  border: Border.all(color: t.danger.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off_rounded, color: t.danger, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(tr('ex.save_failed'),
                          style: GoogleFonts.manrope(
                              color: t.textPrimary, fontSize: 13)),
                    ),
                    TextButton(
                      onPressed: _retrying ? null : _retrySave,
                      child: _retrying
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: t.danger),
                            )
                          : Text(tr('common.retry'),
                              style: GoogleFonts.manrope(
                                  color: t.danger,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: t.onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                      borderRadius: LinguaRadius.rLg),
                  elevation: 0,
                ),
                child: Text(tr('common.continue'),
                    style: GoogleFonts.manrope(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(LinguaTokens t, String label, String value, IconData icon,
      {Color? tint}) {
    return Column(
      children: [
        Icon(icon, size: 24, color: tint ?? t.goldInk),
        const SizedBox(height: 5),
        Text(value,
            style: GoogleFonts.oswald(
                color: tint ?? t.goldInk,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.jetBrainsMono(
                color: t.textTertiary, fontSize: 10, letterSpacing: 1.1)),
      ],
    );
  }
}
