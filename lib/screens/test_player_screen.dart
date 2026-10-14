import 'package:flutter/material.dart';
import '../main.dart';

class TestPlayerScreen extends StatefulWidget {
  const TestPlayerScreen({super.key});
  @override
  State<TestPlayerScreen> createState() => _TestPlayerScreenState();
}

class _TestPlayerScreenState extends State<TestPlayerScreen> {
  final _controller = TextEditingController();

  bool _playing = false;
  bool _buffering = false;
  String? _currentTitle;
  String? _error;

  Future<void> _playFromYoutube() async {
    final videoId = _controller.text.trim();
    if (videoId.isEmpty) return;

    setState(() {
      _currentTitle = videoId;
      _error = null;
    });

    // Wait for handler to be ready (up to 10 sec)
    int tries = 0;
    while (audioHandler == null && tries < 10) {
      await Future.delayed(const Duration(seconds: 1));
      tries++;
    }

    if (audioHandler == null) {
      setState(() => _error = 'Audio service not ready. Check logs.');
      return;
    }

    try {
      await audioHandler.playFromYoutube(videoId: videoId);
      if (mounted) setState(() => _playing = true);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aura Music'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter YouTube video ID (e.g. dQw4w9WgXcQ)',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: _playFromYoutube,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _playFromYoutube(),
            ),
          ),
          if (_currentTitle != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: const Color(0xFFFA2D48),
                      size: 40,
                    ),
                    onPressed: () {
                      if (audioHandler == null) return;
                      if (_playing) {
                        audioHandler.pause();
                      } else {
                        audioHandler.play();
                      }
                      setState(() => _playing = !_playing);
                    },
                  ),
                ],
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
