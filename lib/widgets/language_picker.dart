import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_scale.dart';
import '../design/lingua_tokens.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_controller.dart';

/// Boîte de choix de la langue d'interface, partagée par le drawer et le
/// profil. [context] doit rester monté pendant l'appel (pas le contexte
/// d'un drawer qu'on vient de fermer).
Future<void> showLanguagePicker(BuildContext context) async {
  final t = context.tokens;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final picked = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: t.surfaceRaised,
      shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
      title: Text(tr('set.interface_lang'),
          style: GoogleFonts.oswald(color: t.textPrimary, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: LocaleController.supported.map((code) {
          final selected = localeController.value == code;
          return ListTile(
            title: Text('$code — ${LocaleController.names[code]}',
                style: GoogleFonts.manrope(
                    color: selected ? t.accent : t.textPrimary,
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal)),
            trailing: selected
                ? Icon(Icons.check_rounded, color: t.accent, size: 18)
                : null,
            selected: selected,
            onTap: () => Navigator.of(dialogContext).pop(code),
          );
        }).toList(),
      ),
    ),
  );
  if (picked == null || picked == localeController.value) return;
  await localeController.setLang(picked);
  messenger?.showSnackBar(SnackBar(
    content: Text(tr('lang.selected', {'lang': LocaleController.names[picked]!}),
        style: GoogleFonts.manrope(color: Colors.white)),
    backgroundColor: t.accentStrong,
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
    margin: const EdgeInsets.all(16),
  ));
}
