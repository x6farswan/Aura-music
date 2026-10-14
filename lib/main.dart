import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:kd_youtube_background_audio/kd_youtube_background_audio.dart';
import 'screens/test_player_screen.dart';

late KdYoutubeAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run app first so UI shows immediately
  runApp(const AuraMusicApp());

  // Initialize audio service in background
  try {
    audioHandler = await AudioService.init<KdYoutubeAudioHandler>(
      builder: () => KdYoutubeAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.auramusic.channel.audio',
        androidNotificationChannelName: 'Aura Music Playback',
        androidNotificationOngoing: true,
      ),
    );
    debugPrint('Audio handler initialized OK');
  } catch (e) {
    debugPrint('Audio handler init FAILED: $e');
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
