import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_theme.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/screens/reset_password_screen.dart';
import 'package:lingua_ce/services/password_recovery.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  tearDown(PasswordRecovery.reset);

  group('URL de retour', () {
    test('mobile : le lien profond déclaré dans AndroidManifest', () {
      expect(PasswordRecovery.redirectUrl(web: false),
          'linguace://reset-password');
    });

    test('web : l\'origine de la page courante', () {
      expect(
        PasswordRecovery.redirectUrl(
            web: true, base: Uri.parse('http://localhost:59106/#/home')),
        'http://localhost:59106/',
      );
    });
  });

  test('l\'événement passwordRecovery (même rejoué tard) arme pending',
      () async {
    final events = StreamController<AuthState>();
    PasswordRecovery.listen(events.stream);
    events.add(const AuthState(AuthChangeEvent.signedIn, null));
    await Future<void>.delayed(Duration.zero);
    expect(PasswordRecovery.pending.value, isFalse);

    events.add(const AuthState(AuthChangeEvent.passwordRecovery, null));
    await Future<void>.delayed(Duration.zero);
    expect(PasswordRecovery.pending.value, isTrue);
    await events.close();
  });

  group('validation', () {
    test('mêmes règles qu\'à l\'inscription', () {
      expect(ResetPasswordScreen.validate('', ''), tr('err.fill_fields'));
      expect(ResetPasswordScreen.validate('abc', 'abc'),
          tr('reg.err_password_short'));
      expect(ResetPasswordScreen.validate('abcdef', 'abcdeg'),
          tr('reg.err_password_mismatch'));
      expect(ResetPasswordScreen.validate('abcdef', 'abcdef'), isNull);
    });
  });

  group('écran', () {
    Future<void> pump(WidgetTester tester,
        {required Future<void> Function(String) update,
        required void Function(BuildContext) onDone}) async {
      await tester.pumpWidget(MaterialApp(
        theme: LinguaTheme.dark(),
        home: ResetPasswordScreen(update: update, onDone: onDone),
      ));
    }

    testWidgets('mot de passe valide : enregistré puis on entre dans l\'app',
        (tester) async {
      String? saved;
      var done = false;
      await pump(tester,
          update: (p) async => saved = p, onDone: (_) => done = true);
      await tester.enterText(find.byType(TextField).at(0), 'nouveau123');
      await tester.enterText(find.byType(TextField).at(1), 'nouveau123');
      await tester.tap(find.text(tr('common.save')));
      // Pas de pumpAndSettle : le bouton reste en chargement (anti double
      // envoi) puisque, en vrai, on quitte l'écran.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(saved, 'nouveau123');
      expect(done, isTrue);
      expect(find.text(tr('reset.done')), findsOneWidget);
    });

    testWidgets('confirmation différente : rien n\'est envoyé',
        (tester) async {
      var called = false;
      await pump(tester,
          update: (_) async => called = true, onDone: (_) {});
      await tester.enterText(find.byType(TextField).at(0), 'nouveau123');
      await tester.enterText(find.byType(TextField).at(1), 'autre1234');
      await tester.tap(find.text(tr('common.save')));
      await tester.pumpAndSettle();
      expect(called, isFalse);
      expect(find.text(tr('reg.err_password_mismatch')), findsOneWidget);
    });

    testWidgets('refus du serveur : message affiché, on reste sur l\'écran',
        (tester) async {
      var done = false;
      await pump(tester,
          update: (_) async => throw const AuthException(
              'New password should be different from the old password.'),
          onDone: (_) => done = true);
      await tester.enterText(find.byType(TextField).at(0), 'nouveau123');
      await tester.enterText(find.byType(TextField).at(1), 'nouveau123');
      await tester.tap(find.text(tr('common.save')));
      await tester.pumpAndSettle();
      expect(done, isFalse);
      expect(find.textContaining('should be different'), findsOneWidget);
    });
  });
}
