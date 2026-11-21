import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/services/wav.dart';

import 'helpers/pcm.dart';

void main() {
  test('en-tête WAV : RIFF, PCM mono 16 bits, tailles cohérentes', () {
    final body = pcm();
    final wav = Wav.encode(body, sampleRate: 8000);
    final h = ByteData.sublistView(wav);
    String ascii(int o) => String.fromCharCodes(wav.sublist(o, o + 4));

    expect(ascii(0), 'RIFF');
    expect(ascii(8), 'WAVE');
    expect(ascii(12), 'fmt ');
    expect(ascii(36), 'data');
    expect(h.getUint32(4, Endian.little), 36 + body.length);
    expect(h.getUint16(20, Endian.little), 1); // PCM
    expect(h.getUint16(22, Endian.little), 1); // mono
    expect(h.getUint32(24, Endian.little), 8000);
    expect(h.getUint16(34, Endian.little), 16);
    expect(h.getUint32(40, Endian.little), body.length);
    expect(wav.length, 44 + body.length);
  });

  test('durée et niveau crête', () {
    expect(Wav.durationMs(16000, sampleRate: 8000), 1000);
    expect(Wav.peak(pcm(amp: 16384)), closeTo(0.5, 0.01));
    expect(Wav.peak(Uint8List(100)), 0);
  });

  test('le silence autour de la voix est retiré, avec une marge', () {
    final trimmed = Wav.trimSilence(pcm(), sampleRate: 8000, marginMs: 100);
    final ms = Wav.durationMs(trimmed.length, sampleRate: 8000);
    // 500 ms de voix + 2 × 100 ms de marge (± une fenêtre de 10 ms).
    expect(ms, inInclusiveRange(690, 720));
  });

  test('une prise silencieuse donne une liste vide', () {
    expect(Wav.trimSilence(pcm(amp: 0), sampleRate: 8000), isEmpty);
    expect(Wav.trimSilence(Uint8List(0), sampleRate: 8000), isEmpty);
  });
}
