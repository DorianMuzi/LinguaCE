import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static final _client = Supabase.instance.client;

  static Future<void> createProfile(String username) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('profiles').insert({
      'id': user.id,
      'username': username,
      'xp': 0,
      'level': 1,
      'streak': 0,
      'lessons_completed': 0,
      'league': 'Aigle',
      'interface_language': 'FR',
    });
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  /// Récupère le profil, ou le crée s'il n'existe pas encore.
  static Future<Map<String, dynamic>?> getOrCreateProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      // 1. Chercher le profil existant
      final existing = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existing != null) return existing;

      // 2. Pas de profil → upsert avec le nom extrait de l'email
      final username = (user.email ?? 'apprenant').split('@').first;
      await _client.from('profiles').upsert({
        'id': user.id,
        'username': username,
        'xp': 0,
        'level': 1,
        'streak': 0,
        'lessons_completed': 0,
        'league': 'Aigle',
        'interface_language': 'FR',
      });

      // 3. Retourner le profil
      return await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
    } catch (e) {
      debugPrint('getOrCreateProfile error: $e');
      return null;
    }
  }

  static Future<void> addXP(int xp) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final profile = await getProfile();
    if (profile == null) return;
    final newXP = (profile['xp'] as int) + xp;
    final newLevel = (newXP ~/ 1000) + 1;
    await _client.from('profiles').update({
      'xp': newXP,
      'level': newLevel,
      'last_activity': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }

  static Future<void> updateStreak() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final profile = await getProfile();
    if (profile == null) return;
    final lastActivityRaw = profile['last_activity'] as String?;
    int newStreak = profile['streak'] as int;
    if (lastActivityRaw != null) {
      final lastActivity = DateTime.parse(lastActivityRaw);
      final today = DateTime.now();
      final difference = today.difference(lastActivity).inDays;
      if (difference == 1) {
        newStreak++;
      } else if (difference > 1) {
        newStreak = 1;
      }
    }
    await _client.from('profiles').update({
      'streak': newStreak,
      'last_activity': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }

  static Future<void> updateUsername(String username) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    // upsert : crée la row si elle n'existe pas, sinon met à jour
    await _client.from('profiles').upsert({
      'id': user.id,
      'username': username.trim(),
      'xp': 0,
      'level': 1,
      'streak': 0,
      'lessons_completed': 0,
      'league': 'Aigle',
      'interface_language': 'FR',
    });
  }

  static Future<void> updateLeague() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final profile = await getProfile();
    if (profile == null) return;
    final xp = profile['xp'] as int;
    String league = 'Aigle';
    if (xp >= 10000) {
      league = 'Diamant';
    } else if (xp >= 5000) {
      league = 'Or';
    } else if (xp >= 2000) {
      league = 'Argent';
    }
    await _client.from('profiles').update({
      'league': league,
    }).eq('id', user.id);
  }
}
