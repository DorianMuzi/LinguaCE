import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Prononciations natives du lexique (amorce de LinguaCE Voice).
///
/// `lexemes.audio_url` contient le CHEMIN du fichier dans le bucket
/// [bucket] ; l'URL publique en est déduite ici.
class LexemeAudio {
  LexemeAudio._();

  static const bucket = 'lexeme-audio';

  static AudioPlayer? _player;

  /// URL jouable pour la valeur `audio_url` d'un mot (chemin du bucket ou
  /// URL complète), ou `null` s'il n'a pas encore de prononciation.
  static String? urlFor(String? audioUrl) {
    if (audioUrl == null || audioUrl.isEmpty) return null;
    if (audioUrl.startsWith('http')) return audioUrl;
    return Supabase.instance.client.storage.from(bucket).getPublicUrl(audioUrl);
  }

  static AudioPlayer get _p => _player ??= AudioPlayer();

  /// Joue la prononciation enregistrée d'un mot.
  static Future<void> play(String audioUrl) async {
    final url = urlFor(audioUrl);
    if (url == null) return;
    await _p.stop();
    await _p.play(UrlSource(url));
  }

  /// Joue une prise encore en mémoire (écoute avant de la garder).
  static Future<void> playBytes(Uint8List wav) async {
    await _p.stop();
    await _p.play(BytesSource(wav, mimeType: 'audio/wav'));
  }
}

/// Dépôt des prises par les enregistreurs (table `recorders`).
class RecordingService {
  RecordingService._();

  /// L'utilisateur connecté peut-il enregistrer ? `false` en cas d'erreur.
  static Future<bool> isRecorder() async {
    try {
      final r = await Supabase.instance.client.rpc('is_recorder');
      return r == true;
    } catch (_) {
      return false;
    }
  }

  /// Dépose [wav] puis l'enregistre comme prononciation active du mot.
  /// Renvoie le chemin du fichier (nouvelle valeur de `audio_url`).
  static Future<String> submit(int lexemeId, Uint8List wav, int durationMs) async {
    final client = Supabase.instance.client;
    final path = '$lexemeId/${DateTime.now().toUtc().millisecondsSinceEpoch}.wav';
    await client.storage.from(LexemeAudio.bucket).uploadBinary(
          path,
          wav,
          fileOptions: const FileOptions(contentType: 'audio/wav'),
        );
    await client.rpc('add_lexeme_recording', params: {
      'p_lexeme_id': lexemeId,
      'p_path': path,
      'p_duration_ms': durationMs,
    });
    return path;
  }
}

/// Micro, en flux PCM 16 bits mono — abstrait pour les tests du Studio.
abstract class VoiceRecorder {
  int get sampleRate;
  Future<bool> hasPermission();
  Future<Stream<Uint8List>> start();
  Future<void> stop();
  Future<void> dispose();
}

/// Implémentation réelle (paquet `record`), web, Android et iOS.
class MicRecorder implements VoiceRecorder {
  final _recorder = AudioRecorder();

  @override
  int get sampleRate => 44100;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<Stream<Uint8List>> start() => _recorder.startStream(RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
        // Voix brute : pas de traitement qui déformerait la prononciation.
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
      ));

  @override
  Future<void> stop() async {
    await _recorder.stop();
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}
