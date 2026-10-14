import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yt_flutter_musicapi/yt_flutter_musicapi.dart';

class TestPlayerScreen extends StatefulWidget {
  const TestPlayerScreen({super.key});
  @override
  State<TestPlayerScreen> createState() => _TestPlayerScreenState();
}

class _TestPlayerScreenState extends State<TestPlayerScreen> {
  final _player = AudioPlayer();
  final _controller = TextEditingController();
  final _api = YtFlutterMusicapi();

  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _playing = false;
  String? _currentTitle;
  String? _currentArtist;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player.playingStream.listen((p) {
      if (mounted) setState(() => _playing = p);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _results = [];
      _error = null;
    });
    try {
      final songs = await _api.searchMusic(
        query: _controller.text,
        limit: 20,
        audioQuality: 'VERY_HIGH',
        thumbQuality: 'VERY_HIGH',
        includeAudioUrl: true,
      );
      if (mounted) {
        setState(() {
          _results = songs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
        _showSnack('Search failed: $e');
      }
    }
  }

  Future<void> _play(Map<String, dynamic> song) async {
    final audioUrl = song['audioUrl'] as String?;
    if (audioUrl == null || audioUrl.isEmpty) {
      _showSnack('No audio URL');
      return;
    }
    setState(() {
      _currentTitle = song['title'] as String?;
      _currentArtist = (song['artists'] as List?)?.join(', ');
      _error = null;
    });
    _showSnack('Loading...');
    try {
      await _player.setUrl(audioUrl);
      _player.play();
      _showSnack('Playing!');
    } catch (e) {
      setState(() => _error = e.toString());
      _showSnack('Play failed: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
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
                hintText: 'Search songs...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _search(),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _currentArtist ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
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
          if (_loading) const LinearProgressIndicator(color: Color(0xFFFA2D48)),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text('Search for a song',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (_, i) {
                      final s = _results[i];
                      final title = s['title'] as String? ?? 'Unknown';
                      final artists =
                          (s['artists'] as List?)?.join(', ') ?? '';
                      final thumb = (s['albumArt'] as String?) ?? '';
                      return ListTile(
                        leading: SizedBox(
                          width: 48,
                          height: 48,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: thumb.isNotEmpty
                                ? Image.network(
                                    thumb,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade900),
                                  )
                                : Container(color: Colors.grey.shade900),
                          ),
                        ),
                        title: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          artists,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () => _play(s),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
