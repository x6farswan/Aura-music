import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import 'data/services/audio_handler.dart';
import 'screens/test_player_screen.dart';

AuraAudioHandler? audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run app FIRST so UI shows even if audio init fails
  runApp(const AuraMusicApp());

  // Then init audio service in background
  try {
    audioHandler = await AudioService.init(
      builder: () => AuraAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.auramusic.channel.audio',
        androidNotificationChannelName: 'Aura Music Playback',
        androidNotificationOngoing: true,
      ),
    );
    debugPrint('AudioService initialized OK');
  } catch (e) {
    debugPrint('AudioService init FAILED: $e');
  }
}

class AuraMusicApp extends StatelessWidget {
  const AuraMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFA2D48),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const TestPlayerScreen(),
    );
  }
}
