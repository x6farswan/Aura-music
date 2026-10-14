import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:youtube_extractor_muzo/extractor.dart';

class TestPlayerScreen extends StatefulWidget {
  const TestPlayerScreen({super.key});
  @override
  State<TestPlayerScreen> createState() => _TestPlayerScreenState();
}

class _TestPlayerScreenState extends State<TestPlayerScreen> {
  final _player = AudioPlayer();
  final _controller = TextEditingController();
  final _yt = yt.YoutubeExplode();

  List<yt.Video> _results = [];
  bool _loading = false;
  bool _playing = false;
  bool _buffering = false;
  String? _currentTitle;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player.playingStream.listen((p) {
      if (mounted) setState(() => _playing = p);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _buffering = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    _yt.close();
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
      final results = await _yt.search.search(_controller.text.trim());
      final videos = results.whereType<yt.Video>().take(20).toList();
      if (mounted) {
        setState(() {
          _results = videos;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _play(yt.Video video) async {
    setState(() {
      _currentTitle = video.title;
      _error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Extracting...')),
    );
    try {
      final playbackData = await YTPlayerUtils.playerResponseForPlayback(
        video.id.value,
        audioQuality: AudioQuality.high,
      );
      if (playbackData == null) {
        throw Exception('No stream returned');
      }
      await _player.setUrl(playbackData.streamUrl);
      _player.play();
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
                      final v = _results[i];
                      return ListTile(
                        leading: SizedBox(
                          width: 48,
                          height: 48,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              v.thumbnails.mediumResUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade900),
                            ),
                          ),
                        ),
                        title: Text(
                          v.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          v.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () => _play(v),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
