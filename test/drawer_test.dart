import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_theme.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/i18n/locale_controller.dart';
import 'package:lingua_ce/main.dart' show themeController;
import 'package:lingua_ce/widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Le drawer se ferme AVANT d'ouvrir une boîte de dialogue : son `context`
/// est alors démonté. Ces tests verrouillent les bugs que ça causait
/// (Fermer d'« À propos » qui plantait, Déconnexion qui ne faisait rien).
void main() {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> openDrawer(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(400, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(AnimatedBuilder(
      animation: themeController,
      builder: (_, __) => MaterialApp(
        theme: LinguaTheme.light(),
        darkTheme: LinguaTheme.dark(),
        themeMode: themeController.value,
        home: Scaffold(key: scaffoldKey, drawer: const AppDrawer()),
      ),
    ));
    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();
  }

  testWidgets('À propos : la boîte s\'ouvre et « Fermer » la ferme',
      (tester) async {
    await openDrawer(tester);
    await tester.tap(find.text(tr('drawer.about')));
    await tester.pumpAndSettle();
    expect(find.text(tr('about.desc')), findsOneWidget);

    await tester.tap(find.text(tr('common.close')));
    await tester.pumpAndSettle();
    expect(find.text(tr('about.desc')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Déconnexion : la confirmation s\'affiche après fermeture',
      (tester) async {
    await openDrawer(tester);
    await tester.tap(find.text(tr('profile.logout_btn')));
    await tester.pumpAndSettle();
    expect(find.text(tr('profile.logout_q')), findsOneWidget);

    await tester.tap(find.text(tr('common.cancel')));
    await tester.pumpAndSettle();
    expect(find.text(tr('profile.logout_q')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Langue : choisir EN change la langue d\'interface',
      (tester) async {
    final initial = localeController.value;
    addTearDown(() => localeController.value = initial);
    localeController.value = 'FR';

    await openDrawer(tester);
    await tester.tap(find.text(tr('set.interface_lang')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('EN —'));
    await tester.pumpAndSettle();
    expect(localeController.value, 'EN');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Thème : toucher la ligne (pas seulement l\'interrupteur) bascule',
      (tester) async {
    await themeController.setMode(ThemeMode.light);
    addTearDown(() => themeController.setMode(ThemeMode.dark));

    await openDrawer(tester);
    await tester.tap(find.text(tr('drawer.theme')));
    await tester.pumpAndSettle();
    expect(themeController.value, ThemeMode.dark);
  });
}
