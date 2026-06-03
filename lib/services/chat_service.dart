import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ChatService {
  static final _client = Supabase.instance.client;
  static const _limit = 100;

  /// Charge les [_limit] derniers messages de l'utilisateur connecté.
  static Future<List<ChatMessage>> loadMessages() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final rows = await _client
          .from('chat_messages')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true)
          .limit(_limit);

      return (rows as List).map((r) => ChatMessage(
            text: r['content'] as String,
            isUser: r['role'] == 'user',
            timestamp: DateTime.parse(r['created_at'] as String),
          )).toList();
    } catch (_) {
      return []; // Table absente ou erreur réseau → historique vide
    }
  }

  /// Persiste un message (fire-and-forget — les erreurs réseau sont ignorées).
  static Future<void> saveMessage(ChatMessage message) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client.from('chat_messages').insert({
        'user_id': user.id,
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.text,
      });
    } catch (_) {
      // Silencieux : ne pas bloquer l'UI si le réseau est absent
    }
  }

  /// Efface tout l'historique de l'utilisateur connecté.
  static Future<void> clearHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('chat_messages').delete().eq('user_id', user.id);
  }
}
