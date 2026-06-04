import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_controller.dart';
import '../models/models.dart';
import '../services/claude_service.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _inputFocus = FocusNode();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _loadingHistory = true;

  /// Langue des réponses de l'IA = langue d'interface (FR / EN / RU / CE).
  /// En CE, l'IA répond en tchétchène (translittération latine 1992).
  String get _aiLang => localeController.value;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final saved = await ChatService.loadMessages();
    if (!mounted) return;
    setState(() {
      _messages = saved.isEmpty ? _welcomeMessages() : saved;
      _loadingHistory = false;
    });
    _scrollToBottom();
  }

  /// Message d'accueil dans la langue d'interface (clé i18n chat.welcome).
  List<ChatMessage> _welcomeMessages() => [
        ChatMessage(
          text: tr('chat.welcome'),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    final userMsg =
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now());

    setState(() {
      _messages.add(userMsg);
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    ChatService.saveMessage(userMsg);

    try {
      final reply = await ClaudeService.send(
        messages: List.unmodifiable(_messages),
        language: _aiLang,
      );
      if (!mounted) return;

      final aiMsg =
          ChatMessage(text: reply, isUser: false, timestamp: DateTime.now());

      setState(() {
        _messages.add(aiMsg);
        _isTyping = false;
      });

      ChatService.saveMessage(aiMsg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: '⚠️ Erreur : ${e.toString().replaceFirst('Exception: ', '')}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  Future<void> _clearHistory() async {
    final t = context.tokens;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
        title: Text(tr('chat.clear_q'),
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary, fontSize: 17)),
        content: Text(tr('chat.clear_desc'),
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('common.cancel'),
                style: GoogleFonts.inter(color: t.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('common.delete'),
                style: GoogleFonts.inter(
                    color: t.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ChatService.clearHistory();
    if (!mounted) return;
    setState(() => _messages = _welcomeMessages());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      children: [
        _buildHeader(t),
        Expanded(
          child: _loadingHistory
              ? Center(child: CircularProgressIndicator(color: t.accent))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_isTyping && i == _messages.length) {
                      return _buildTypingIndicator(t);
                    }
                    return _buildMessage(t, _messages[i]);
                  },
                ),
        ),
        _buildInputBar(t),
      ],
    );
  }

  Widget _buildHeader(LinguaTokens t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        border: Border(bottom: BorderSide(color: t.outlineSubtle)),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology_outlined, color: t.accent, size: 18),
          const SizedBox(width: 6),
          Text(tr('chat.ai_label'),
              style: GoogleFonts.spaceMono(color: t.accent, fontSize: 12)),
          const Spacer(),
          IconButton(
            onPressed: _clearHistory,
            icon: Icon(Icons.delete_outline_rounded,
                color: t.textTertiary, size: 20),
            tooltip: tr('common.delete'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Actions sur les messages (appui long / clic droit) ───────────────────
  void _showMessageActions(ChatMessage msg) {
    final t = context.tokens;
    showModalBottomSheet(
      context: context,
      backgroundColor: t.surfaceRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: t.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading:
                  Icon(Icons.copy_rounded, color: t.textSecondary, size: 20),
              title: Text(tr('chat.copy'),
                  style: GoogleFonts.inter(color: t.textPrimary, fontSize: 15)),
              onTap: () {
                Navigator.pop(ctx);
                _copyMessage(msg);
              },
            ),
            if (msg.isUser)
              ListTile(
                leading:
                    Icon(Icons.edit_rounded, color: t.textSecondary, size: 20),
                title: Text(tr('chat.edit'),
                    style:
                        GoogleFonts.inter(color: t.textPrimary, fontSize: 15)),
                onTap: () {
                  Navigator.pop(ctx);
                  _editMessage(msg);
                },
              )
            else
              ListTile(
                leading: Icon(Icons.refresh_rounded,
                    color: t.textSecondary, size: 20),
                title: Text(tr('chat.regenerate'),
                    style:
                        GoogleFonts.inter(color: t.textPrimary, fontSize: 15)),
                onTap: () {
                  Navigator.pop(ctx);
                  _regenerate(msg);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _copyMessage(ChatMessage msg) {
    Clipboard.setData(ClipboardData(text: msg.text));
    if (!mounted) return;
    final t = context.tokens;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(tr('chat.copied'), style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: t.accentStrong,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _editMessage(ChatMessage msg) {
    final idx = _messages.indexOf(msg);
    if (idx < 0) return;
    final kept = _messages.sublist(0, idx);
    setState(() {
      _messages = List.from(kept);
      _controller.text = msg.text;
      _controller.selection =
          TextSelection.collapsed(offset: msg.text.length);
    });
    ChatService.replaceHistory(kept);
    _inputFocus.requestFocus();
  }

  Future<void> _regenerate(ChatMessage aiMsg) async {
    if (_isTyping) return;
    final idx = _messages.indexOf(aiMsg);
    if (idx < 0) return;
    final kept = _messages.sublist(0, idx); // tout avant cette réponse
    setState(() {
      _messages = List.from(kept);
      _isTyping = true;
    });
    await ChatService.replaceHistory(kept);
    _scrollToBottom();
    try {
      final reply = await ClaudeService.send(
        messages: List.unmodifiable(_messages),
        language: _aiLang,
      );
      if (!mounted) return;
      final newMsg =
          ChatMessage(text: reply, isUser: false, timestamp: DateTime.now());
      setState(() {
        _messages.add(newMsg);
        _isTyping = false;
      });
      ChatService.saveMessage(newMsg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: '⚠️ Erreur : ${e.toString().replaceFirst('Exception: ', '')}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  Widget _buildMessage(LinguaTokens t, ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      key: ValueKey(msg.timestamp.millisecondsSinceEpoch),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: t.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showMessageActions(msg),
                  onSecondaryTap: () => _showMessageActions(msg),
                  child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? t.accent : t.surfaceRaised,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser ? null : Border.all(color: t.outlineSubtle),
                    boxShadow: isUser ? null : t.shadowSm,
                  ),
                  child: isUser
                      ? Text(
                          msg.text,
                          style: GoogleFonts.inter(
                            color: t.onAccent,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: msg.text,
                          softLineBreak: true,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.inter(
                                color: t.textPrimary,
                                fontSize: 14,
                                height: 1.4),
                            strong: GoogleFonts.inter(
                                color: t.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                            em: GoogleFonts.inter(
                                color: t.textPrimary,
                                fontSize: 14,
                                fontStyle: FontStyle.italic),
                            code: GoogleFonts.spaceMono(
                                color: t.accentStrong,
                                fontSize: 12,
                                backgroundColor: t.surfaceSunken),
                            codeblockDecoration: BoxDecoration(
                              color: t.surfaceSunken,
                              borderRadius: LinguaRadius.rSm,
                            ),
                            listBullet: GoogleFonts.inter(
                                color: t.textPrimary, fontSize: 14),
                          ),
                        ),
                ),
                  ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(LinguaTokens t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration:
                BoxDecoration(color: t.accentSoft, shape: BoxShape.circle),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: t.surfaceRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.outlineSubtle),
              boxShadow: t.shadowSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  List.generate(3, (i) => _TypingDot(delay: i * 200)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(LinguaTokens t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        border: Border(top: BorderSide(color: t.outlineSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _inputFocus,
              style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: tr('chat.hint'),
                hintStyle:
                    GoogleFonts.inter(color: t.textTertiary, fontSize: 14),
                filled: true,
                fillColor: t.surfaceSunken,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: t.outline, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: t.outline, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: t.accent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
              child: Icon(Icons.send_rounded, color: t.onAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _anim.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FadeTransition(
        opacity: _fade,
        child: CircleAvatar(radius: 4, backgroundColor: t.accent),
      ),
    );
  }
}
