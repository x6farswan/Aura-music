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

  List<dynamic> _results = [];
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
      final response = await _api.searchMusic(
        query: _controller.text,
        limit: 20,
        audioQuality: AudioQuality.veryHigh,
        thumbQuality: ThumbnailQuality.high,
        includeAudioUrl: true,
      );

      // Extract data from YTMusicResponse wrapper
      final dynamic data = response.data ?? [];
      final List<dynamic> songs = (data as List).toList();

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

  Future<void> _play(dynamic song) async {
    String? audioUrl;
    String title = 'Unknown';
    String artist = '';

    try {
      audioUrl = song.audioUrl?.toString();
      title = song.title?.toString() ?? 'Unknown';
      final artists = song.artists;
      if (artists is List) {
        artist = artists.map((a) => a.toString()).join(', ');
      }
    } catch (e) {
      debugPrint('Parse error: $e');
    }

    if (audioUrl == null || audioUrl.isEmpty) {
      _showSnack('No audio URL available');
      return;
    }

    setState(() {
      _currentTitle = title;
      _currentArtist = artist;
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

  String _thumbUrl(dynamic song) {
    try {
      final thumbs = song.thumbnails;
      if (thumbs is List && thumbs.isNotEmpty) {
        return thumbs.last.url?.toString() ?? '';
      }
    } catch (_) {}
    return '';
  }

  String _titleOf(dynamic song) {
    try {
      return song.title?.toString() ?? 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  String _artistOf(dynamic song) {
    try {
      final a = song.artists;
      if (a is List) return a.map((x) => x.toString()).join(', ');
    } catch (_) {}
    return '';
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
                      final thumb = _thumbUrl(s);
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
                          _titleOf(s),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _artistOf(s),
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
