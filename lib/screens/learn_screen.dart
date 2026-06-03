import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_components.dart';
import '../design/responsive.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import 'exercise_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: ContentClamp(
        padding: EdgeInsets.fromLTRB(
          Responsive.isMobile(context) ? 20 : 32,
          8,
          Responsive.isMobile(context) ? 20 : 32,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(t),
            const SizedBox(height: 20),
            _buildProgressOverview(t),
            const SizedBox(height: 28),
            const SectionLabel('Parcours d\'apprentissage'),
            const SizedBox(height: 12),
            ...MockData.lessons.map((l) => _LessonCard(lesson: l)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LinguaTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Apprendre',
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        Text('le tchétchène',
            style: GoogleFonts.playfairDisplay(
                color: t.accent, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProgressOverview(LinguaTokens t) {
    final completed =
        MockData.lessons.where((l) => l.status == LessonStatus.completed).length;
    final total = MockData.lessons.length;
    return CopilotCard(
      gradient: t.heroGradient,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$completed / $total leçons',
                    style: GoogleFonts.playfairDisplay(
                        color: t.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Text('complétées',
                    style:
                        GoogleFonts.inter(color: t.textSecondary, fontSize: 14)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : completed / total,
                      backgroundColor: t.surfaceSunken,
                      valueColor: AlwaysStoppedAnimation<Color>(t.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 4),
              Text('Débutant',
                  style: GoogleFonts.spaceMono(color: t.accent, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonModel lesson;
  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isLocked = lesson.status == LessonStatus.locked;
    final isCompleted = lesson.status == LessonStatus.completed;
    final isActive = lesson.status == LessonStatus.active;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isLocked
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseScreen(lesson: lesson),
                  ),
                ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLocked ? t.surfaceSunken : t.surfaceRaised,
            borderRadius: LinguaRadius.rLg,
            border: Border.all(
              color: isActive
                  ? t.accent
                  : isCompleted
                      ? t.accent.withValues(alpha: 0.4)
                      : t.outlineSubtle,
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: isLocked ? null : t.shadowSm,
          ),
          child: Row(
            children: [
              _buildStatusIcon(t, isCompleted, isLocked),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            lesson.title,
                            style: GoogleFonts.playfairDisplay(
                              color:
                                  isLocked ? t.textTertiary : t.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: t.accentSoft,
                              borderRadius: LinguaRadius.rPill,
                              border: Border.all(color: t.accent),
                            ),
                            child: Text('EN COURS',
                                style: GoogleFonts.spaceMono(
                                    color: t.accentStrong,
                                    fontSize: 9,
                                    letterSpacing: 1)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(lesson.subtitle,
                        style: GoogleFonts.inter(
                            color: t.textSecondary, fontSize: 13)),
                    if (isActive) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 4,
                          child: LinearProgressIndicator(
                            value: lesson.progress,
                            backgroundColor: t.surfaceSunken,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(t.accent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lesson.completedExercises}/${lesson.totalExercises} exercices',
                        style: GoogleFonts.spaceMono(
                            color: t.textTertiary, fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('+${lesson.xpReward} XP',
                      style: GoogleFonts.spaceMono(
                          color: isLocked ? t.textTertiary : t.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (!isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted ? t.surfaceSunken : t.accent,
                        borderRadius: LinguaRadius.rPill,
                      ),
                      child: Text(
                        isCompleted ? 'Revoir' : 'Commencer',
                        style: GoogleFonts.inter(
                          color: isCompleted ? t.textSecondary : t.onAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.lock_outline, color: t.textTertiary, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(LinguaTokens t, bool isCompleted, bool isLocked) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isCompleted
            ? t.accentSoft
            : isLocked
                ? t.surfaceSunken
                : t.surfaceSunken,
        shape: BoxShape.circle,
        border: Border.all(color: isCompleted ? t.accent : t.outline),
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check_rounded, color: t.accent, size: 22)
            : Text(lesson.icon, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
