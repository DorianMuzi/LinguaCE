import 'dart:typed_data';

/// PCM 16 bits mono : [silenceMs] de silence, [toneMs] de signal, puis
/// [silenceMs] de silence.
Uint8List pcm({int rate = 8000, int silenceMs = 300, int toneMs = 500, int amp = 16000}) {
  final samples = <int>[
    for (var i = 0; i < rate * silenceMs ~/ 1000; i++) 0,
    for (var i = 0; i < rate * toneMs ~/ 1000; i++) i.isEven ? amp : -amp,
    for (var i = 0; i < rate * silenceMs ~/ 1000; i++) 0,
  ];
  final data = ByteData(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(i * 2, samples[i], Endian.little);
  }
  return data.buffer.asUint8List();
}

