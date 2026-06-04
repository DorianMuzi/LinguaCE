import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../i18n/app_strings.dart';
import '../models/models.dart';
import '../services/lesson_service.dart';

// ═══════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════

enum ExerciseType { flashcard, qcm, translation }

class Exercise {
  final ExerciseType type;
  final String cyrillic;
  final String translit;
  final String french;
  final String? prompt;
  final List<String>? choices;
  final int? correctIndex;

  const Exercise({
    required this.type,
    required this.cyrillic,
    required this.translit,
    required this.french,
    this.prompt,
    this.choices,
    this.correctIndex,
  });
}

// ═══════════════════════════════════════════════════════════
// EXERCISE DATA
// ═══════════════════════════════════════════════════════════

class _Data {
  static const Map<String, List<Exercise>> _byLesson = {
    '1': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Салам', translit: 'Salam', french: 'Salut (informel)'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Баркалла', translit: 'Barkalla', french: 'Merci'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Баркалла', translit: 'Barkalla', french: 'Merci',
        prompt: 'Comment dit-on "Merci" en tchétchène ?',
        choices: ['Salam', 'Barkalla', 'Dika', 'Von'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Дика', translit: 'Dika', french: 'Bien / Bon',
        prompt: 'Que signifie "Dika" ?',
        choices: ['Mauvais', 'Beaucoup', 'Bien / Bon', 'Peu'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Дукха', translit: 'Dukxa', french: 'Beaucoup',
        prompt: 'Quel mot signifie "Beaucoup" ?',
        choices: ['Kʼezig', 'Von', 'Dika', 'Dukxa'],
        correctIndex: 3,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'Баркалла дукха', translit: 'Barkalla dukxa',
        french: 'Merci beaucoup',
        prompt: 'Traduis en tchétchène :\n"Merci beaucoup"',
      ),
    ],
    '2': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Марша огӀийла', translit: 'Marşa oġiyla',
          french: 'Bonjour (formel)'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Дела реза хуьлда', translit: 'Dela reza xülda',
          french: 'Que Dieu soit satisfait'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Марша огӀийла', translit: 'Marşa oġiyla',
        french: 'Bonjour (formel)',
        prompt: 'Quel est le bonjour formel en tchétchène ?',
        choices: ['Salam', 'Barkalla', 'Marşa oġiyla', 'Dika de'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Суьйре', translit: 'Süyre', french: 'Soir',
        prompt: 'Comment dit-on "Soir" en tchétchène ?',
        choices: ['De', 'Büysa', 'ʼüyre', 'Süyre'],
        correctIndex: 3,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Марша огӀийла', translit: 'Marşa oġiyla',
        french: 'Entre libre (litt.)',
        prompt: 'Que signifie littéralement "Marşa oġiyla" ?',
        choices: ['Bonne journée', 'Entre libre', 'Bonne nuit', 'À bientôt'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'Марша огӀийла', translit: 'Marşa oġiyla',
        french: 'Bonjour (formel)',
        prompt: 'Traduis en tchétchène :\n"Bonjour" (formel)',
      ),
    ],
    '3': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'цхьа', translit: 'cẋa', french: 'Un (1)'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'шиъ', translit: 'şiʔ', french: 'Deux (2)'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'кхо', translit: 'qo', french: 'Trois (3)',
        prompt: '"Qo" signifie ?',
        choices: ['Un', 'Deux', 'Trois', 'Quatre'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'пхи', translit: 'pxi', french: 'Cinq (5)',
        prompt: 'Comment dit-on "5" en tchétchène ?',
        choices: ['Diʔ', 'Pxi', 'Yalx', 'Vorx'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'цхьа', translit: 'cẋa', french: 'Un (1)',
        prompt: 'Comment dit-on "1" en tchétchène ?',
        choices: ['Şiʔ', 'Qo', 'Cẋa', 'Diʔ'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'кхо', translit: 'qo', french: 'Trois',
        prompt: 'Écris le chiffre 3 en tchétchène :',
      ),
    ],
    '4': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Да', translit: 'Da', french: 'Père'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Нана', translit: 'Nana', french: 'Mère'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Ваша', translit: 'Vaşa', french: 'Frère',
        prompt: 'Comment dit-on "Frère" en tchétchène ?',
        choices: ['Yişa', 'Nana', 'Vaşa', 'Da'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Йиша', translit: 'Yişa', french: 'Sœur',
        prompt: '"Yişa" signifie ?',
        choices: ['Mère', 'Père', 'Frère', 'Sœur'],
        correctIndex: 3,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Да', translit: 'Da', french: 'Père',
        prompt: 'Comment dit-on "Père" en tchétchène ?',
        choices: ['Nana', 'Da', 'Vaşa', 'Yişa'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'Нана', translit: 'Nana', french: 'Mère',
        prompt: 'Traduis en tchétchène :\n"Mère"',
      ),
    ],
  };

  static List<Exercise> forLesson(String id) => _byLesson[id] ?? [];
}

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
  late final List<Exercise> _exercises;
  int _currentIndex = 0;
  int _xpEarned = 0;
  int _mistakes = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isCompleted = false;

  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _isFlipped = false;

  int? _selectedChoice;
  final _translCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exercises = _Data.forLesson(widget.lesson.id);

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
    _translCtrl.addListener(() => setState(() {}));

    if (_exercises.isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => Navigator.pop(context));
    }
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
    _isFlipped ? _flipCtrl.forward() : _flipCtrl.reverse();
  }

  void _confirmFlashcard() {
    setState(() => _xpEarned += 5);
    _next();
  }

  void _answerQcm(int index) {
    if (_isAnswered) return;
    final correct = index == _current.correctIndex;
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
      'ş': 's', 'ẋ': 'x', 'ç': 'c', 'ġ': 'g', 'ŋ': 'n',
      'ü': 'u', 'ö': 'o', 'ə': 'e',
      'ʔ': '', 'ʼ': '', 'ʻ': '', '\'': '', '`': '',
    };
    var out = s.trim().toLowerCase();
    folds.forEach((k, v) => out = out.replaceAll(k, v));
    return out.replaceAll(RegExp(r'\s+'), ' ');
  }

  void _next() {
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
    setState(() => _isCompleted = true);
    await LessonService.completeLesson(
      lessonId: widget.lesson.id,
      completedExercises: _exercises.length,
      totalExercises: _exercises.length,
      xpEarned: _xpEarned,
    );
  }

  // ─── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) return const SizedBox.shrink();
    final t = context.tokens;
    return Scaffold(
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
    );
  }

  Widget _buildHeader(LinguaTokens t) {
    final progress = (_currentIndex + 1) / _exercises.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
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
              style: GoogleFonts.spaceMono(
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
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
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
              style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13)),
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
                    style: GoogleFonts.inter(
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
            const Text('📖', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(_current.translit,
                style: GoogleFonts.playfairDisplay(
                    color: t.textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_current.cyrillic,
                style: GoogleFonts.inter(color: t.textTertiary, fontSize: 16)),
            const SizedBox(height: 16),
            Text(tr('ex.tap_translate'),
                style: GoogleFonts.inter(color: t.textTertiary, fontSize: 13)),
          ],
        ),
      );

  Widget _cardBack(LinguaTokens t) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: t.accentSoft,
          borderRadius: LinguaRadius.rXl,
          border: Border.all(color: t.accent, width: 1.5),
          boxShadow: t.shadowMd,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_current.translit,
                style: GoogleFonts.spaceMono(
                    color: t.accentStrong,
                    fontSize: 34,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_current.cyrillic,
                style: GoogleFonts.playfairDisplay(
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
                  style: GoogleFonts.playfairDisplay(
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
              style: GoogleFonts.playfairDisplay(
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
              bg = t.accentSoft;
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
                            style: GoogleFonts.inter(
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
                const Text('✍️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(_current.prompt ?? '',
                    style: GoogleFonts.playfairDisplay(
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
                      GoogleFonts.spaceMono(color: t.accent, fontSize: 12)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _translCtrl,
              style: GoogleFonts.inter(color: t.textPrimary, fontSize: 20),
              textAlign: TextAlign.center,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: tr('ex.answer_hint'),
                hintStyle:
                    GoogleFonts.inter(color: t.textTertiary, fontSize: 14),
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
                    style: GoogleFonts.inter(
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
                      style: GoogleFonts.inter(
                          color: _isCorrect ? t.success : t.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(_current.translit,
                      style: GoogleFonts.playfairDisplay(
                          color: t.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  Text(_current.cyrillic,
                      style: GoogleFonts.inter(
                          color: t.textTertiary, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(_current.french,
                      style: GoogleFonts.inter(
                          color: t.textSecondary, fontSize: 14)),
                  if (_isCorrect) ...[
                    const SizedBox(height: 8),
                    Text('+20 XP',
                        style: GoogleFonts.spaceMono(
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
          Text(isCorrect ? '🎉' : '💡', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(isCorrect ? 'ex.correct' : 'ex.not_quite'),
                    style: GoogleFonts.inter(
                        color: isCorrect ? t.success : t.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                if (correctLabel != null)
                  Text(correctLabel,
                      style: GoogleFonts.inter(
                          color: t.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (xp != null)
            Text(xp,
                style: GoogleFonts.spaceMono(
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
            Text(perfect ? '🏆' : '🎓', style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(tr(perfect ? 'ex.done_perfect' : 'ex.done'),
                style: GoogleFonts.playfairDisplay(
                    color: t.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.lesson.title,
                style: GoogleFonts.inter(color: t.textSecondary, fontSize: 16)),
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
                  _stat(t, tr('ex.xp_earned'), '+$_xpEarned', '⭐'),
                  Container(width: 1, height: 40, color: t.outlineSubtle),
                  _stat(t, tr('ex.mistakes'), '$_mistakes',
                      _mistakes == 0 ? '✨' : '💡'),
                  Container(width: 1, height: 40, color: t.outlineSubtle),
                  _stat(t, tr('ex.exercises'), '${_exercises.length}', '📚'),
                ],
              ),
            ),
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
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(LinguaTokens t, String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.playfairDisplay(
                color: t.accent, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.spaceMono(color: t.textSecondary, fontSize: 10)),
      ],
    );
  }
}
