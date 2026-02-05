import 'package:shared_preferences/shared_preferences.dart';

/// 通知頻度
enum NotificationFrequency {
  every1h('1時間ごと', 1),
  every3h('3時間ごと', 3),
  onceDaily('1日1回', 24);

  const NotificationFrequency(this.label, this.hours);
  final String label;
  final int hours;
}

/// 学習レベル
enum LearningLevel {
  beginner('初級'),
  intermediate('中級'),
  advanced('上級');

  const LearningLevel(this.label);
  final String label;
}

class SettingsService {
  static const _keyNotificationFrequency = 'notification_frequency';
  static const _keyLearningLevel = 'learning_level';
  static const _keyNotificationEnabled = 'notification_enabled';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _prefsAsync async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<NotificationFrequency> getNotificationFrequency() async {
    final prefs = await _prefsAsync;
    final index = prefs.getInt(_keyNotificationFrequency) ?? 0;
    return NotificationFrequency.values[index.clamp(0, NotificationFrequency.values.length - 1)];
  }

  Future<void> setNotificationFrequency(NotificationFrequency value) async {
    final prefs = await _prefsAsync;
    await prefs.setInt(_keyNotificationFrequency, value.index);
  }

  Future<LearningLevel> getLearningLevel() async {
    final prefs = await _prefsAsync;
    final index = prefs.getInt(_keyLearningLevel) ?? 0;
    return LearningLevel.values[index.clamp(0, LearningLevel.values.length - 1)];
  }

  Future<void> setLearningLevel(LearningLevel value) async {
    final prefs = await _prefsAsync;
    await prefs.setInt(_keyLearningLevel, value.index);
  }

  Future<bool> getNotificationEnabled() async {
    final prefs = await _prefsAsync;
    return prefs.getBool(_keyNotificationEnabled) ?? false;
  }

  Future<void> setNotificationEnabled(bool value) async {
    final prefs = await _prefsAsync;
    await prefs.setBool(_keyNotificationEnabled, value);
  }
}
