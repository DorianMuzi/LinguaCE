import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_components.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_tokens.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../models/models.dart';
import '../services/lexeme_audio.dart';
import '../services/lexicon_service.dart';
import '../services/wav.dart';

enum StudioPhase { idle, recording, review, saving }

/// Studio d'enregistrement des prononciations natives (réservé aux
/// enregistreurs). Un mot à la fois : enregistrer, écouter, garder ou
/// refaire — puis le Studio passe au mot suivant sans prononciation.
///
/// Au clavier (web) : Espace enregistre / arrête, Entrée garde, → passe.
class StudioScreen extends StatefulWidget {
  final Future<List<Lexeme>> Function()? load;
  final VoiceRecorder Function()? recorder;
  final Future<String> Function(int lexemeId, Uint8List wav, int durationMs)?
      submit;
  final Future<void> Function(Uint8List wav)? playTake;
  final Future<void> Function(String audioUrl)? playSaved;

  const StudioScreen({
    super.key,
    this.load,
    this.recorder,
    this.submit,
    this.playTake,
    this.playSaved,
  });

  /// Durée maximale d'une prise : un mot ou une courte expression.
  static const maxTake = Duration(seconds: 8);

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  List<Lexeme>? _words;
  bool _failed = false;
  bool _onlyMissing = true;
  int? _currentId;

  StudioPhase _phase = StudioPhase.idle;
  VoiceRecorder? _recorder;
  StreamSubscription<Uint8List>? _sub;
  BytesBuilder _buffer = BytesBuilder(copy: false);
  final _clock = Stopwatch();
  Timer? _ticker;
  Timer? _limit;
  double _level = 0;

  Uint8List? _take;
  int _takeMs = 0;
  String? _notice;
  bool _noticeIsError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _limit?.cancel();
    _sub?.cancel();
    _recorder?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final words = await (widget.load ??
          () => LexiconService.fetchAll(refresh: true))();
      if (!mounted) return;
      setState(() {
        _words = [...words];
        _currentId = _nextMissing(null);
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  // ─── Navigation entre les mots ─────────────────────────────
  Lexeme? get _current {
    final id = _currentId;
    if (id == null) return null;
    for (final w in _words ?? const <Lexeme>[]) {
      if (w.id == id) return w;
    }
    return null;
  }

  int get _recordedCount =>
      (_words ?? const <Lexeme>[]).where((w) => w.audioUrl != null).length;

  /// Premier mot sans prononciation après [afterId] (en boucle).
  int? _nextMissing(int? afterId) {
    final words = _words ?? const <Lexeme>[];
    if (words.isEmpty) return null;
    final start = afterId == null
        ? 0
        : words.indexWhere((w) => w.id == afterId) + 1;
    for (var k = 0; k < words.length; k++) {
      final w = words[(start + k) % words.length];
      if (w.audioUrl == null && w.id != afterId) return w.id;
    }
    return null;
  }

  List<Lexeme> get _visible {
    final words = _words ?? const <Lexeme>[];
    if (!_onlyMissing) return words;
    return [
      for (final w in words)
        if (w.audioUrl == null || w.id == _currentId) w,
    ];
  }

  bool get _busy =>
      _phase == StudioPhase.recording || _phase == StudioPhase.saving;

  void _select(int id) {
    if (_busy) return;
    setState(() {
      _currentId = id;
      _take = null;
      _phase = StudioPhase.idle;
      _notice = null;
    });
  }

  void _skip() {
    if (_busy) return;
    final visible = _visible;
    if (visible.isEmpty) return;
    final i = visible.indexWhere((w) => w.id == _currentId);
    _select(visible[(i + 1) % visible.length].id);
  }

  void _say(String text, {bool error = false}) {
    _notice = text;
    _noticeIsError = error;
  }

  // ─── Prise de son ──────────────────────────────────────────
  Future<void> _startRecording() async {
    if (_current == null || _busy) return;
    setState(() {
      _notice = null;
      _take = null;
    });
    final rec = _recorder ??= (widget.recorder ?? MicRecorder.new)();
    try {
      if (!await rec.hasPermission()) {
        if (mounted) setState(() => _say(tr('studio.mic_denied'), error: true));
        return;
      }
      _buffer = BytesBuilder(copy: false);
      final stream = await rec.start();
      _sub = stream.listen((chunk) {
        _buffer.add(chunk);
        _level = Wav.peak(chunk);
      });
    } catch (_) {
      if (mounted) setState(() => _say(tr('studio.mic_denied'), error: true));
      return;
    }
    _clock
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
    _limit = Timer(StudioScreen.maxTake, _stopRecording);
    if (mounted) setState(() => _phase = StudioPhase.recording);
  }

  Future<void> _stopRecording() async {
    if (_phase != StudioPhase.recording) return;
    _ticker?.cancel();
    _limit?.cancel();
    _clock.stop();
    final rec = _recorder!;
    await rec.stop();
    // Micro arrêté : les données sont déjà là. On n'attend pas l'annulation,
    // qui peut ne jamais aboutir sur un flux déjà clos.
    unawaited(_sub?.cancel());
    _sub = null;

    final trimmed =
        Wav.trimSilence(_buffer.takeBytes(), sampleRate: rec.sampleRate);
    if (!mounted) return;
    if (trimmed.isEmpty) {
      setState(() {
        _phase = StudioPhase.idle;
        _level = 0;
        _say(tr('studio.silence'), error: true);
      });
      return;
    }
    final wav = Wav.encode(trimmed, sampleRate: rec.sampleRate);
    setState(() {
      _take = wav;
      _takeMs = Wav.durationMs(trimmed.length, sampleRate: rec.sampleRate);
      _phase = StudioPhase.review;
      _level = 0;
    });
    // Réécoute immédiate : on juge la prise sans clic supplémentaire.
    _playTake();
  }

  void _toggleRecording() => _phase == StudioPhase.recording
      ? _stopRecording()
      : _startRecording();

  Future<void> _playTake() async {
    final take = _take;
    if (take == null) return;
    try {
      await (widget.playTake ?? LexemeAudio.playBytes)(take);
    } catch (_) {}
  }

  Future<void> _playSaved(String audioUrl) async {
    try {
      await (widget.playSaved ?? LexemeAudio.play)(audioUrl);
    } catch (_) {}
  }

  void _redo() {
    if (_phase != StudioPhase.review) return;
    setState(() => _take = null);
    _startRecording();
  }

  Future<void> _keep() async {
    final word = _current;
    final take = _take;
    if (word == null || take == null || _phase != StudioPhase.review) return;
    setState(() => _phase = StudioPhase.saving);
    try {
      final path = await (widget.submit ?? RecordingService.submit)(
          word.id, take, _takeMs);
      LexiconService.invalidate();
      if (!mounted) return;
      setState(() {
        final i = _words!.indexWhere((w) => w.id == word.id);
        _words![i] = word.withAudio(path);
        _take = null;
        _phase = StudioPhase.idle;
        _currentId = _nextMissing(word.id) ?? word.id;
        _say(tr('studio.saved'));
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _phase = StudioPhase.review;
          _say(tr('err.generic'), error: true);
        });
      }
    }
  }

  // ─── Interface ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): _toggleRecording,
        const SingleActivator(LogicalKeyboardKey.enter): _keep,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _skip,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: t.surfaceBase,
          appBar: AppBar(
            backgroundColor: t.surfaceBase,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.textPrimary),
              tooltip: tr('common.back'),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(tr('studio.title'),
                style: GoogleFonts.oswald(
                    color: t.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(child: _buildBody(t)),
        ),
      ),
    );
  }

  Widget _buildBody(LinguaTokens t) {
    if (_failed) {
      return Center(
        child: CopilotButton(
          label: tr('common.retry'),
          variant: CopilotButtonVariant.tonal,
          onPressed: _load,
        ),
      );
    }
    final words = _words;
    if (words == null) {
      return Center(child: CircularProgressIndicator(color: t.accent));
    }

    final total = words.length;
    return ContentClamp(
      maxWidth: 640,
      padding: const EdgeInsets.fromLTRB(
          LinguaSpacing.screen, LinguaSpacing.sm, LinguaSpacing.screen, 0),
      child: ListView(
        padding: const EdgeInsets.only(bottom: LinguaSpacing.xl),
        children: [
          Semantics(
            liveRegion: true,
            child: SectionLabel(tr('studio.progress',
                {'n': '$_recordedCount', 't': '$total'})),
          ),
          const SizedBox(height: LinguaSpacing.sm),
          ClipRRect(
            borderRadius: LinguaRadius.rMd,
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : _recordedCount / total,
              minHeight: 6,
              color: t.accent,
              backgroundColor: t.outlineSubtle,
            ),
          ),
          const SizedBox(height: LinguaSpacing.lg),
          _wordCard(t),
          const SizedBox(height: LinguaSpacing.lg),
          if (_current != null) _controls(t),
          if (_notice != null) ...[
            const SizedBox(height: LinguaSpacing.md),
            Semantics(
              liveRegion: true,
              child: Text(_notice!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                      color: _noticeIsError ? t.danger : t.success,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ],
          if (kIsWeb) ...[
            const SizedBox(height: LinguaSpacing.md),
            Text(tr('studio.keys'),
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                    color: t.textTertiary, fontSize: 11)),
          ],
          const SizedBox(height: LinguaSpacing.xl),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(tr('studio.filter_missing'))),
              ButtonSegment(value: false, label: Text(tr('studio.filter_all'))),
            ],
            selected: {_onlyMissing},
            onSelectionChanged: (s) => setState(() => _onlyMissing = s.first),
          ),
          const SizedBox(height: LinguaSpacing.sm),
          for (final w in _visible) _row(t, w),
        ],
      ),
    );
  }

  Widget _wordCard(LinguaTokens t) {
    final w = _current;
    if (w == null) {
      return CopilotCard(
        child: Text(tr('studio.all_done'),
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
                color: t.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      );
    }
    final cls = Lexeme.classLetter(w.nounClass);
    return CopilotCard(
      edge: t.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChechenWord(
            latin: w.latin,
            cyrillic: w.cyrillic,
            gloss: w.translationsFor('FR').join(', '),
            size: 40,
          ),
          const SizedBox(height: LinguaSpacing.md),
          Wrap(
            spacing: LinguaSpacing.xs,
            runSpacing: LinguaSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AccentChip(label: tr('pos.${w.pos}'), tone: ChipTone.neutral),
              if (cls != null) AccentChip(label: tr('dict.class', {'c': cls})),
              if (w.audioUrl case final saved?)
                TextButton.icon(
                  onPressed: () => _playSaved(saved),
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: Text(tr('studio.current')),
                ),
            ],
          ),
          const SizedBox(height: LinguaSpacing.sm),
          Text(tr('studio.hint'),
              style: GoogleFonts.manrope(color: t.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _controls(LinguaTokens t) {
    switch (_phase) {
      case StudioPhase.idle:
      case StudioPhase.recording:
        final recording = _phase == StudioPhase.recording;
        final secs = (_clock.elapsedMilliseconds / 1000).toStringAsFixed(1);
        return Column(
          children: [
            Semantics(
              button: true,
              label: recording ? tr('studio.stop') : tr('studio.record'),
              child: Tooltip(
                message: recording ? tr('studio.stop') : tr('studio.record'),
                child: InkResponse(
                  onTap: _toggleRecording,
                  radius: 52,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 90),
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: recording ? t.danger : t.accent,
                      border: Border.all(
                        color: (recording ? t.danger : t.accent)
                            .withValues(alpha: 0.35),
                        width: 4 + 18 * _level,
                      ),
                    ),
                    child: Icon(
                      recording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: LinguaSpacing.sm),
            Text(recording ? '$secs s' : tr('studio.record'),
                style: GoogleFonts.jetBrainsMono(
                    color: t.textSecondary, fontSize: 13)),
            const SizedBox(height: LinguaSpacing.sm),
            TextButton(
              onPressed: recording ? null : _skip,
              child: Text(tr('studio.skip')),
            ),
          ],
        );
      case StudioPhase.review:
      case StudioPhase.saving:
        final saving = _phase == StudioPhase.saving;
        return Column(
          children: [
            Text('${(_takeMs / 1000).toStringAsFixed(1)} s',
                style: GoogleFonts.jetBrainsMono(
                    color: t.textSecondary, fontSize: 13)),
            const SizedBox(height: LinguaSpacing.sm),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: LinguaSpacing.sm,
              runSpacing: LinguaSpacing.sm,
              children: [
                CopilotButton(
                  label: tr('studio.listen'),
                  icon: Icons.play_arrow_rounded,
                  variant: CopilotButtonVariant.ghost,
                  onPressed: saving ? null : _playTake,
                ),
                CopilotButton(
                  label: tr('studio.redo'),
                  icon: Icons.replay_rounded,
                  variant: CopilotButtonVariant.tonal,
                  onPressed: saving ? null : _redo,
                ),
                CopilotButton(
                  label: tr('studio.keep'),
                  icon: Icons.check_rounded,
                  loading: saving,
                  onPressed: saving ? null : _keep,
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _row(LinguaTokens t, Lexeme w) {
    final selected = w.id == _currentId;
    final done = w.audioUrl != null;
    return ListTile(
      selected: selected,
      selectedTileColor: t.accentTint,
      shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
      onTap: () => _select(w.id),
      title: Text(w.latin,
          style: GoogleFonts.manrope(
              color: t.textPrimary, fontWeight: FontWeight.w600)),
      subtitle: Text('${w.cyrillic} · ${w.translationsFor('FR').join(', ')}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(color: t.textSecondary, fontSize: 13)),
      trailing: Icon(
        done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
        color: done ? t.success : t.textTertiary,
        semanticLabel: done ? tr('studio.done_label') : null,
      ),
    );
  }
}
