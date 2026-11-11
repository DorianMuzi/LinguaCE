import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_components.dart';
import 'package:lingua_ce/design/lingua_theme.dart';

void main() {
  group('BrandAssets', () {
    test('pkharmat borne le niveau aux stades illustrés', () {
      expect(BrandAssets.pkharmat(1), 'assets/brand/pkharmat-1.jpg');
      expect(BrandAssets.pkharmat(5), 'assets/brand/pkharmat-5.jpg');
      expect(BrandAssets.pkharmat(8), 'assets/brand/pkharmat-8.jpg');
      // Niveau non borné côté joueur : on reste sur le dernier stade.
      expect(BrandAssets.pkharmat(42), 'assets/brand/pkharmat-8.jpg');
      // Valeurs dégradées : jamais de chemin inexistant.
      expect(BrandAssets.pkharmat(0), 'assets/brand/pkharmat-1.jpg');
      expect(BrandAssets.pkharmat(-3), 'assets/brand/pkharmat-1.jpg');
    });

    test('chaque illustration référencée existe sur le disque', () {
      final paths = [
        BrandAssets.naxci,
        for (var i = 1; i <= BrandAssets.pkharmatStages; i++)
          BrandAssets.pkharmat(i),
        for (final k in LeagueBadge.keys) BrandAssets.league(k),
      ];
      for (final p in paths) {
        expect(File(p).existsSync(), isTrue, reason: 'asset manquant : $p');
      }
    });

    test('le dossier assets/brand est déclaré dans pubspec.yaml', () {
      expect(File('pubspec.yaml').readAsStringSync(),
          contains('- assets/brand/'));
    });
  });

  group('rendu', () {
    Widget host(Widget child) => MaterialApp(
          theme: LinguaTheme.dark(),
          home: Scaffold(body: Center(child: child)),
        );

    testWidgets('NaxciAvatar se construit à la taille demandée',
        (tester) async {
      await tester.pumpWidget(host(const NaxciAvatar(size: 32)));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(NaxciAvatar)), const Size(32, 32));
    });

    testWidgets('LeagueBadge : chaque ligue et une clé inconnue',
        (tester) async {
      for (final k in [...LeagueBadge.keys, 'inconnue']) {
        await tester.pumpWidget(host(LeagueBadge(league: k, size: 40)));
        expect(tester.takeException(), isNull, reason: k);
        expect(tester.getSize(find.byType(LeagueBadge)), const Size(40, 40));
      }
    });

    testWidgets('Medallion.pkharmat affiche la pastille de niveau',
        (tester) async {
      await tester.pumpWidget(host(Builder(
        builder: (context) => Medallion.pkharmat(context, level: 12),
      )));
      expect(tester.takeException(), isNull);
      // Le vrai niveau reste affiché même si l'image est bornée au stade 8.
      expect(find.text('NIV. 12'), findsOneWidget);
      expect(tester.getSize(find.byType(Medallion)), const Size(132, 132));
    });
  });
}
