import 'package:flutter/material.dart';
import 'package:kd_youtube_background_audio/kd_youtube_background_audio.dart';

class TestPlayerScreen extends StatefulWidget {
  const TestPlayerScreen({super.key});
  @override
  State<TestPlayerScreen> createState() => _TestPlayerScreenState();
}

class _TestPlayerScreenState extends State<TestPlayerScreen> {
  late final KdYoutubeAudioPlayer _player;
  final _controller = TextEditingController();

  bool _playing = false;
  bool _buffering = false;
  String? _currentTitle;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = KdYoutubeAudioPlayer();
    _player.playingStream.listen((p) {
      if (mounted) setState(() => _playing = p);
    });
    _player.bufferingStream.listen((b) {
      if (mounted) setState(() => _buffering = b);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playFromYoutube() async {
    final videoId = _controller.text.trim();
    if (videoId.isEmpty) return;

    setState(() {
      _currentTitle = videoId;
      _error = null;
    });

    try {
      await _player.playFromYoutube(videoId);
    } catch (e) {
      setState(() => _error = e.toString());
    }
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
                  if (_buffering)
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFFFA2D48)),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        _playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: const Color(0xFFFA2D48),
                        size: 40,
                      ),
                      onPressed: () {
                        if (_playing) {
                          _player.pause();
                        } else {
                          _player.play();
                        }
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
