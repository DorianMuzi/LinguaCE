import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_components.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_tokens.dart';
import '../i18n/app_strings.dart';
import '../models/models.dart';
import '../services/report_service.dart';

/// Ouvre la feuille « Signaler une erreur » pour un exercice donné.
///
/// Affiche un message de remerciement (ou d'échec) une fois la feuille
/// refermée. [submit] est injectable pour les tests.
Future<void> showReportSheet(
  BuildContext context, {
  required String lessonId,
  required int position,
  required Exercise exercise,
  Future<bool> Function(ReportCategory category, String comment)? submit,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.tokens.surfaceRaised,
    builder: (_) => ReportSheet(
      exercise: exercise,
      submit: submit ??
          (category, comment) => ReportService.submit(
                lessonId: lessonId,
                position: position,
                exercise: exercise,
                category: category,
                comment: comment,
              ),
    ),
  );
  if (sent == true) {
    messenger.showSnackBar(SnackBar(content: Text(tr('report.thanks'))));
  }
}

class ReportSheet extends StatefulWidget {
  final Exercise exercise;
  final Future<bool> Function(ReportCategory category, String comment) submit;

  const ReportSheet({super.key, required this.exercise, required this.submit});

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  ReportCategory _category = ReportCategory.translit;
  final _comment = TextEditingController();
  bool _sending = false;
  bool _failed = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _failed = false;
    });
    final ok = await widget.submit(_category, _comment.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _sending = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ex = widget.exercise;
    const categories = [
      (ReportCategory.translit, 'report.cat_translit'),
      (ReportCategory.translation, 'report.cat_translation'),
      (ReportCategory.other, 'report.cat_other'),
    ];

    return Padding(
      // Remonte au-dessus du clavier quand le champ de commentaire a le focus.
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              LinguaSpacing.screen, 0, LinguaSpacing.screen, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(tr('report.title'),
                    style: GoogleFonts.oswald(
                        color: t.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              // Rappel de ce qui est signalé : latin d'abord, cyrillique et
              // français en appui.
              CopilotCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ex.translit,
                        style: GoogleFonts.manrope(
                            color: t.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(ex.cyrillic,
                        style:
                            GoogleFonts.manrope(color: t.goldInk, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(ex.french,
                        style: GoogleFonts.manrope(
                            color: t.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (category, key) in categories)
                    ChoiceChip(
                      label: Text(tr(key)),
                      selected: _category == category,
                      onSelected: _sending
                          ? null
                          : (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _comment,
                enabled: !_sending,
                maxLines: 3,
                minLines: 2,
                maxLength: ReportService.maxComment,
                decoration: InputDecoration(hintText: tr('report.comment_hint')),
              ),
              if (_failed) ...[
                const SizedBox(height: 4),
                Text(tr('report.failed'),
                    style: GoogleFonts.manrope(color: t.danger, fontSize: 13)),
              ],
              const SizedBox(height: 12),
              CopilotButton(
                label: tr('report.send'),
                onPressed: _sending ? null : _send,
                loading: _sending,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
