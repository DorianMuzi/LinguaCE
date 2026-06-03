import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

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
    // Journal d'XP pour le graphique hebdomadaire (best-effort).
    try {
      await _client
          .from('xp_events')
          .insert({'user_id': user.id, 'amount': xp});
    } catch (_) {}
  }

  /// Met à jour la série quotidienne en comparant les **jours calendaires**.
  /// À appeler AVANT [addXP] (qui écrase `last_activity`).
  static Future<void> updateStreak() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final profile = await getProfile();
    if (profile == null) return;

    final lastRaw = profile['last_activity'] as String?;
    int streak = (profile['streak'] as int?) ?? 0;
    final now = DateTime.now();

    if (lastRaw == null) {
      streak = 1; // première activité
    } else {
      final last = DateTime.parse(lastRaw).toLocal();
      final lastDay = DateTime(last.year, last.month, last.day);
      final today = DateTime(now.year, now.month, now.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        if (streak < 1) streak = 1; // même jour
      } else if (diff == 1) {
        streak += 1; // jour suivant
      } else {
        streak = 1; // série rompue
      }
    }

    await _client.from('profiles').update({
      'streak': streak,
      'last_activity': now.toIso8601String(),
    }).eq('id', user.id);
  }

  /// Met à jour seulement le pseudo (préserve XP, série, etc.).
  static Future<void> updateUsername(String username) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client
        .from('profiles')
        .update({'username': username.trim()})
        .eq('id', user.id);
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

  static const _avatarPalette = [
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFFBE185D),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFF4F46E5),
  ];

  /// Classement des utilisateurs par XP (le plus haut d'abord).
  static Future<List<LeagueUser>> fetchLeaderboard({int limit = 20}) async {
    final me = _client.auth.currentUser;
    try {
      final rows = await _client
          .from('profiles')
          .select('id, username, xp')
          .order('xp', ascending: false)
          .limit(limit);
      final list = rows as List;
      final result = <LeagueUser>[];
      for (var i = 0; i < list.length; i++) {
        final r = list[i] as Map<String, dynamic>;
        final name = (r['username'] as String?) ?? 'Apprenant';
        result.add(LeagueUser(
          name: name,
          avatarInitials: name.isNotEmpty ? name[0].toUpperCase() : 'A',
          avatarColor: _avatarPalette[i % _avatarPalette.length],
          xp: (r['xp'] as int?) ?? 0,
          rank: i + 1,
          isCurrentUser: r['id'] == me?.id,
        ));
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  /// XP gagné par jour sur les 7 derniers jours (du plus ancien au plus
  /// récent ; l'index 6 = aujourd'hui).
  static Future<List<int>> fetchWeeklyXp() async {
    final user = _client.auth.currentUser;
    if (user == null) return List.filled(7, 0);
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 6));
      final rows = await _client
          .from('xp_events')
          .select('amount, created_at')
          .eq('user_id', user.id)
          .gte('created_at', start.toIso8601String());
      final buckets = List<int>.filled(7, 0);
      for (final r in (rows as List)) {
        final created = DateTime.parse(r['created_at'] as String).toLocal();
        final day = DateTime(created.year, created.month, created.day);
        final idx = day.difference(start).inDays;
        if (idx >= 0 && idx < 7) buckets[idx] += (r['amount'] as int?) ?? 0;
      }
      return buckets;
    } catch (_) {
      return List.filled(7, 0);
    }
  }
}
