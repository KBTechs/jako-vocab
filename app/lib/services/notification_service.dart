import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:jako_vocab_app/data/dummy_words.dart';
import 'package:jako_vocab_app/services/settings_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final SettingsService _settings = SettingsService();
  bool _initialized = false;

  static const _channelId = 'jako_vocab_channel';
  static const _channelName = '語彙のお知らせ';

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      defaultPresentAlert: true,
      defaultPresentBanner: true,
      defaultPresentSound: true,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onSelect,
    );
    await _createChannel();
    await _requestPermission();
    _initialized = true;
    debugPrint('[NotificationService] Initialized');
  }

  Future<void> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      debugPrint('[NotificationService] Android permission granted: $granted');
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('[NotificationService] iOS permission granted: $granted');
    }
  }

  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: '単語の通知',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onSelect(NotificationResponse response) {}

  Map<String, String> _randomWord() {
    final i = Random().nextInt(dummyWords.length);
    return dummyWords[i];
  }

  /// 通知許可がONのとき、設定された頻度で繰り返し通知をスケジュール
  Future<void> updateScheduleFromSettings() async {
    final enabled = await _settings.getNotificationEnabled();
    await cancelAll();
    if (!enabled) return;

    final frequency = await _settings.getNotificationFrequency();
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: '単語の通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    switch (frequency) {
      case NotificationFrequency.every1h:
        final word = _randomWord();
        await _plugin.periodicallyShow(
          0,
          '単語のお知らせ',
          '${word['ja']} (${word['ko']})',
          RepeatInterval.hourly,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        break;
      case NotificationFrequency.every3h:
        await _scheduleEvery3Hours(details);
        break;
      case NotificationFrequency.onceDaily:
        final word = _randomWord();
        await _plugin.periodicallyShow(
          0,
          '単語のお知らせ',
          '${word['ja']} (${word['ko']})',
          RepeatInterval.daily,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        break;
    }
  }

  /// 毎日 0:00, 3:00, 6:00, 9:00, 12:00, 15:00, 18:00, 21:00 に通知（3時間ごと）
  Future<void> _scheduleEvery3Hours(NotificationDetails details) async {
    final now = tz.TZDateTime.now(tz.local);
    final times = [0, 3, 6, 9, 12, 15, 18, 21];
    for (var i = 0; i < times.length; i++) {
      var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, times[i], 0);
      if (at.isBefore(now)) {
        at = at.add(const Duration(days: 1));
      }
      final word = _randomWord();
      await _plugin.zonedSchedule(
        i + 1,
        '単語のお知らせ',
        '${word['ja']} (${word['ko']})',
        at,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// 開発用: 今すぐテスト通知を1件表示する（スケジュールには影響しない）
  Future<void> showTestNotification() async {
    if (!_initialized) {
      debugPrint('[NotificationService] showTestNotification: not initialized yet, initializing...');
      await initialize();
    }
    final word = _randomWord();
    final body = '${word['ja']} (${word['ko']})';
    debugPrint('[NotificationService] showTestNotification: sending "$body"');
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: '単語の通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    try {
      await _plugin.show(
        999,
        '単語のお知らせ（テスト）',
        body,
        details,
      );
      debugPrint('[NotificationService] showTestNotification: show() completed OK');
    } catch (e, st) {
      debugPrint('[NotificationService] showTestNotification: ERROR $e');
      debugPrint('[NotificationService] $st');
    }
  }
}
