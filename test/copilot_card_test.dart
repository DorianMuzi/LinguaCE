import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_components.dart';
import 'package:lingua_ce/design/lingua_theme.dart';

/// Une carte qui passe du contour au filet coloré (leçon qui devient la
/// leçon en cours) ne doit pas interpoler les deux bordures : l'état
/// intermédiaire — côtés de couleurs différentes + coins arrondis — fait
/// lever « A borderRadius can only be given on borders with uniform colors ».
void main() {
  Widget host(Color? edge) => MaterialApp(
        theme: LinguaTheme.dark(),
        home: Scaffold(
          body: CopilotCard(edge: edge, child: const Text('Leçon')),
        ),
      );

  testWidgets('contour → filet : aucune exception pendant l\'animation',
      (tester) async {
    await tester.pumpWidget(host(null));
    await tester.pumpWidget(host(const Color(0xFFFF6B3D)));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('filet → contour : aucune exception pendant l\'animation',
      (tester) async {
    await tester.pumpWidget(host(const Color(0xFFFF6B3D)));
    await tester.pumpWidget(host(null));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.takeException(), isNull);
    }
  });
}
