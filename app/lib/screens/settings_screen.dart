import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jako_vocab_app/services/settings_service.dart';
import 'package:jako_vocab_app/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  final NotificationService _notifications = NotificationService();

  NotificationFrequency _frequency = NotificationFrequency.every1h;
  LearningLevel _level = LearningLevel.beginner;
  bool _notificationEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final f = await _settings.getNotificationFrequency();
    final l = await _settings.getLearningLevel();
    final e = await _settings.getNotificationEnabled();
    if (mounted) {
      setState(() {
        _frequency = f;
        _level = l;
        _notificationEnabled = e;
        _loading = false;
      });
    }
  }

  Future<void> _setFrequency(NotificationFrequency value) async {
    await _settings.setNotificationFrequency(value);
    setState(() => _frequency = value);
    await _notifications.updateScheduleFromSettings();
  }

  Future<void> _setLevel(LearningLevel value) async {
    await _settings.setLearningLevel(value);
    setState(() => _level = value);
  }

  Future<void> _setNotificationEnabled(bool value) async {
    await _settings.setNotificationEnabled(value);
    setState(() => _notificationEnabled = value);
    await _notifications.updateScheduleFromSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SizedBox(height: 8),
          _sectionTitle('通知'),
          _dropdownCard(
            title: '通知頻度',
            valueIndex: _frequency.index,
            items: NotificationFrequency.values.map((e) => e.label).toList(),
            onChanged: (index) => _setFrequency(NotificationFrequency.values[index]),
          ),
          _switchCard(
            title: '通知許可',
            value: _notificationEnabled,
            onChanged: _setNotificationEnabled,
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: const Text('テスト通知を送る'),
                subtitle: const Text('開発用：今すぐ1件表示'),
                trailing: const Icon(Icons.notifications_active),
                onTap: () async {
                  debugPrint('[Settings] テスト通知ボタン tapped');
                  await _notifications.showTestNotification();
                  debugPrint('[Settings] showTestNotification 完了');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('テスト通知を送りました')),
                    );
                  }
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          _sectionTitle('学習'),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('学習レベル', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  SegmentedButton<LearningLevel>(
                    segments: LearningLevel.values
                        .map((e) => ButtonSegment(value: e, label: Text(e.label)))
                        .toList(),
                    selected: {_level},
                    onSelectionChanged: (Set<LearningLevel> selected) {
                      _setLevel(selected.first);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _dropdownCard({
    required String title,
    required int valueIndex,
    required List<String> items,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: valueIndex.clamp(0, items.length - 1),
                items: List.generate(items.length, (i) => DropdownMenuItem(value: i, child: Text(items[i]))),
                onChanged: (i) {
                  if (i != null) onChanged(i);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchCard({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
