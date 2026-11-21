import 'dart:math' as math;
import 'dart:typed_data';

/// Outils PCM 16 bits / WAV, en Dart pur (identiques sur web, Android, iOS).
///
/// Le Studio enregistre en flux PCM brut, puis fabrique lui-même le WAV :
/// un format lisible partout et sans perte, adapté au futur corpus de
/// LinguaCE Voice.
class Wav {
  Wav._();

  static const bytesPerSample = 2;

  /// Durée en millisecondes de [pcmBytes] octets de PCM 16 bits.
  static int durationMs(int pcmBytes, {required int sampleRate, int channels = 1}) =>
      pcmBytes * 1000 ~/ (sampleRate * channels * bytesPerSample);

  /// Niveau crête de [pcm] entre 0 et 1 (vu-mètre du Studio).
  static double peak(Uint8List pcm) {
    final data = ByteData.sublistView(pcm);
    var max = 0;
    for (var i = 0; i + 1 < pcm.length; i += bytesPerSample) {
      final v = data.getInt16(i, Endian.little).abs();
      if (v > max) max = v;
    }
    return math.min(max / 32767, 1.0);
  }

  /// Retire le silence en début et en fin de prise, en gardant [marginMs]
  /// de part et d'autre de la voix. Le seuil est relatif au pic (bruit de
  /// fond) avec un plancher absolu. Renvoie une liste vide si la prise ne
  /// contient que du silence.
  static Uint8List trimSilence(
    Uint8List pcm, {
    required int sampleRate,
    int channels = 1,
    int marginMs = 150,
    double floor = 0.02,
  }) {
    final frame = channels * bytesPerSample;
    final usable = pcm.length - pcm.length % frame;
    if (usable == 0) return Uint8List(0);
    final data = ByteData.sublistView(pcm);

    // Fenêtres de 10 ms : on garde le pic de chacune.
    final window = math.max(1, sampleRate ~/ 100) * frame;
    final peaks = <int>[];
    for (var start = 0; start < usable; start += window) {
      final end = math.min(start + window, usable);
      var m = 0;
      for (var i = start; i + 1 < end; i += bytesPerSample) {
        final v = data.getInt16(i, Endian.little).abs();
        if (v > m) m = v;
      }
      peaks.add(m);
    }

    final loudest = peaks.reduce(math.max);
    final threshold = math.max(floor * 32767, loudest * 0.08);
    if (loudest < floor * 32767) return Uint8List(0);

    final first = peaks.indexWhere((p) => p >= threshold);
    final last = peaks.lastIndexWhere((p) => p >= threshold);
    final margin = (marginMs * sampleRate ~/ 1000) * frame;

    final from = math.max(0, first * window - margin);
    final to = math.min(usable, (last + 1) * window + margin);
    return Uint8List.sublistView(pcm, from, to);
  }

  /// Enveloppe [pcm] (16 bits little-endian) dans un en-tête WAV RIFF.
  static Uint8List encode(Uint8List pcm, {required int sampleRate, int channels = 1}) {
    final header = ByteData(44);
    final byteRate = sampleRate * channels * bytesPerSample;
    void ascii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    header.setUint32(4, 36 + pcm.length, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // taille du bloc fmt
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, channels * bytesPerSample, Endian.little);
    header.setUint16(34, 16, Endian.little); // bits par échantillon
    ascii(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);

    return Uint8List(44 + pcm.length)
      ..setRange(0, 44, header.buffer.asUint8List())
      ..setRange(44, 44 + pcm.length, pcm);
  }
}
