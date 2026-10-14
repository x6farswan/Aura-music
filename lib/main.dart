import 'package:flutter/material.dart';
import 'package:yt_flutter_musicapi/yt_flutter_musicapi.dart';
import 'screens/test_player_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await YtFlutterMusicapi().initialize(
      proxy: null,
      country: 'IN',
    );
    debugPrint('YT API initialized');
  } catch (e) {
    debugPrint('YT API init failed: $e');
  }

  runApp(const AuraMusicApp());
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
