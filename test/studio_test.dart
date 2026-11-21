import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_theme.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/i18n/locale_controller.dart';
import 'package:lingua_ce/models/models.dart';
import 'package:lingua_ce/screens/studio_screen.dart';
import 'package:lingua_ce/services/lexeme_audio.dart';

import 'helpers/pcm.dart';

/// SectionLabel affiche ses titres en capitales.
String progress(int n) => tr('studio.progress', {'n': '$n', 't': '2'}).toUpperCase();

/// Micro factice : chaque prise est un nouveau flux que le test alimente.
class FakeRecorder implements VoiceRecorder {
  bool permission = true;
  StreamController<Uint8List>? _ctrl;

  void speak(Uint8List chunk) => _ctrl!.add(chunk);

  @override
  int get sampleRate => 8000;

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<Stream<Uint8List>> start() async {
    _ctrl = StreamController<Uint8List>();
    return _ctrl!.stream;
  }

  @override
  Future<void> stop() async => _ctrl?.close();

  @override
  Future<void> dispose() async {}
}

const _words = [
  Lexeme(id: 1, cyrillic: 'неӀ', latin: 'nej', pos: 'noun', nounClass: 'y',
      translations: {'FR': ['Porte']}),
  Lexeme(id: 2, cyrillic: 'кор', latin: 'kor', pos: 'noun', nounClass: 'd',
      translations: {'FR': ['Fenêtre']}),
];

void main() {
  late FakeRecorder mic;
  late List<(int, Uint8List, int)> submitted;
  late int plays;

  Widget studio() => MaterialApp(
        theme: LinguaTheme.dark(),
        home: StudioScreen(
          load: () async => _words,
          recorder: () => mic,
          submit: (id, wav, ms) async {
            submitted.add((id, wav, ms));
            return '$id/1.wav';
          },
          playTake: (_) async => plays++,
          playSaved: (_) async {},
        ),
      );

  setUp(() {
    final initial = localeController.value;
    localeController.value = 'FR';
    addTearDown(() => localeController.value = initial);
    mic = FakeRecorder();
    submitted = [];
    plays = 0;
  });

  Future<void> record(WidgetTester tester, Uint8List sound) async {
    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pump();
    await tester.pump();
    mic.speak(sound);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.stop_rounded));
    await tester.pumpAndSettle();
  }

  testWidgets('enregistrer, réécouter, garder : le Studio passe au mot suivant',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(studio());
    await tester.pumpAndSettle();
    expect(find.text(progress(0)), findsOneWidget);

    await record(tester, pcm());
    expect(find.text('Garder'), findsOneWidget);
    expect(plays, 1, reason: 'la prise est rejouée automatiquement');

    await tester.tap(find.text('Garder'));
    await tester.pumpAndSettle();

    expect(submitted, hasLength(1));
    final (id, wav, ms) = submitted.single;
    expect(id, 1);
    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    expect(ms, inInclusiveRange(700, 820), reason: 'silence retiré, marges gardées');

    expect(find.text(progress(1)), findsOneWidget);
    expect(find.text('Enregistré.'), findsOneWidget);
    // Mot suivant : « kor » occupe la grande carte, « nej » est coché.
    expect(find.text('kor'), findsWidgets);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing,
        reason: 'filtre « À enregistrer » : nej, enregistré, quitte la liste');
    await tester.tap(find.text('Tous'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('une prise silencieuse est refusée avec un conseil', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(studio());
    await tester.pumpAndSettle();

    await record(tester, pcm(amp: 0));
    expect(find.text('Aucun son détecté. Rapproche-toi du micro.'), findsOneWidget);
    expect(find.text('Garder'), findsNothing);
    expect(submitted, isEmpty);
  });

  testWidgets('micro refusé : message clair, rien n\'est enregistré',
      (tester) async {
    mic.permission = false;
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(studio());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('Micro refusé'), findsOneWidget);
    expect(find.byIcon(Icons.stop_rounded), findsNothing);
  });

  testWidgets('refaire relance aussitôt une nouvelle prise', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(studio());
    await tester.pumpAndSettle();

    await record(tester, pcm());
    await tester.tap(find.text('Refaire'));
    await tester.pump();
    await tester.pump();
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

    mic.speak(pcm());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.stop_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Garder'), findsOneWidget);
    expect(submitted, isEmpty);
  });
}
