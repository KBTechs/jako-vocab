import 'package:flutter/material.dart';
import 'package:jako_vocab_app/screens/settings_screen.dart';
import 'package:jako_vocab_app/services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JakoVocabApp());
}

class JakoVocabApp extends StatelessWidget {
  const JakoVocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jako Vocab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.zero,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationService _notifications = NotificationService();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _notifications.initialize();
    await _notifications.updateScheduleFromSettings();
  }

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}
