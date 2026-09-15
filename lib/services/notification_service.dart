import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../i18n/app_strings.dart';

/// Rappel quotidien de série, en notification locale — aucun serveur requis.
///
/// Le choix de l'utilisateur (activé/désactivé) est persisté via
/// `shared_preferences`, même patron que [ThemeController]/[LocaleController].
///
/// Fonctionnement : plutôt qu'une répétition native (qui ne permet pas
/// d'annuler UN seul jour sans casser les suivants), on programme les
/// [_windowDays] prochains jours individuellement, chacun avec un
/// identifiant déterministe (AAAAMMJJ). [sync] recalcule cette fenêtre à
/// chaque appel — notamment après une activité (cf. `LessonService`), pour
/// annuler le rappel du jour dès qu'il devient inutile.
///
/// Limite connue : les alarmes programmées ne survivent pas toujours à un
/// redémarrage de l'appareil sur toutes les versions d'Android tant qu'un
/// récepteur `RECEIVE_BOOT_COMPLETED` ne les reprogramme pas. `main.dart`
/// appelle [sync] à chaque lancement de l'app, ce qui comble ce cas tant que
/// l'utilisateur rouvre l'app au moins une fois toutes les [_windowDays]
/// jours ; un vrai correctif demanderait un récepteur de démarrage natif.
class NotificationService {
  NotificationService._();

  static const _prefKey = 'notifications_enabled';
  static const _channelId = 'daily_streak_reminder';

  /// Heure du rappel — cf. tâche #1 du backlog.
  static const _hour = 19;
  static const _minute = 0;

  static const _windowDays = 14;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    if (kIsWeb) return; // pas de notifications locales sur le web

    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      // Repli sur UTC (déjà la locale par défaut du package `timezone`) :
      // le rappel arrivera à un autre horaire local, sans bloquer le reste.
      developer.log('Fuseau horaire local indisponible, repli UTC',
          name: 'NotificationService', error: e);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      _channelId,
      'Rappel de série',
      description: 'Rappelle de pratiquer LinguaCE chaque jour.',
      importance: Importance.defaultImportance,
    ));

    _initialized = true;
  }

  /// État persisté du réglage (indépendant de la permission système —
  /// l'utilisateur peut avoir activé le toggle puis refusé la permission).
  static Future<bool> isEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefKey) ?? true; // activé par défaut
    } catch (_) {
      return true;
    }
  }

  /// Active ou désactive les rappels : persiste le choix, demande la
  /// permission système si besoin, puis (re)programme ou annule.
  ///
  /// Renvoie `false` si l'activation a été refusée (permission système
  /// refusée) — l'appelant doit alors laisser le toggle éteint.
  static Future<bool> setEnabled(bool value) async {
    if (kIsWeb) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, value);
    } catch (_) {
      // Persistance best-effort — le comportement en session reste correct.
    }

    if (!value) {
      await _cancelAll();
      return true;
    }

    final granted = await _requestPermission();
    if (!granted) {
      // On revient sur l'état persisté pour ne pas mentir sur le toggle.
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKey, false);
      } catch (_) {}
      return false;
    }
    await sync();
    return true;
  }

  static Future<bool> _requestPermission() async {
    await _ensureInitialized();
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        // `null` sur Android < 13 : aucune permission à demander, donc OK.
        final granted = await android.requestNotificationsPermission();
        return granted ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
      return true;
    } catch (e) {
      developer.log('Permission de notification refusée ou indisponible',
          name: 'NotificationService', error: e);
      return false;
    }
  }

  /// Recalcule la planification des [_windowDays] prochains jours.
  ///
  /// À appeler : au démarrage de l'app (repli si l'appareil a redémarré), et
  /// juste après une activité qui met à jour la série ([ProfileService]) —
  /// le rappel du jour devient alors inutile et doit disparaître aussitôt.
  /// Ne fait rien si le réglage est désactivé.
  static Future<void> sync({DateTime? lastActivity}) async {
    if (kIsWeb) return;
    if (!await isEnabled()) return;
    await _ensureInitialized();

    final now = tz.TZDateTime.now(tz.local);
    final today = DateTime(now.year, now.month, now.day);
    final activeToday = lastActivity != null &&
        DateTime(lastActivity.year, lastActivity.month, lastActivity.day) ==
            today;

    for (var i = 0; i < _windowDays; i++) {
      final day = today.add(Duration(days: i));
      final id = _idForDate(day);

      if (i == 0 && activeToday) {
        await _plugin.cancel(id);
        continue;
      }

      final when =
          tz.TZDateTime(tz.local, day.year, day.month, day.day, _hour, _minute);
      if (when.isBefore(now)) {
        // L'heure du jour est déjà passée : rien à programmer pour ce jour.
        await _plugin.cancel(id);
        continue;
      }

      await _plugin.zonedSchedule(
        id,
        tr('notif.reminder_title'),
        tr('notif.reminder_body'),
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Rappel de série',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> _cancelAll() async {
    if (kIsWeb) return;
    await _ensureInitialized();
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (_isReminderId(p.id)) await _plugin.cancel(p.id);
    }
  }

  /// AAAAMMJJ — déterministe, unique par jour civil, dans l'espace int32.
  /// Exposé (`@visibleForTesting`) car le reste du service dépend du plugin
  /// natif, non mockable simplement en test unitaire.
  @visibleForTesting
  static int idForDate(DateTime d) => _idForDate(d);
  static int _idForDate(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  @visibleForTesting
  static bool isReminderId(int id) => _isReminderId(id);
  static bool _isReminderId(int id) => id >= 20000101 && id <= 29991231;
}
