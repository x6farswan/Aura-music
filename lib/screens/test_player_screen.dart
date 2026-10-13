import 'package:flutter/material.dart';
import '../data/models/song.dart';
import '../data/services/ytmusic_api.dart';
import '../main.dart';

class TestPlayerScreen extends StatefulWidget {
  const TestPlayerScreen({super.key});
  @override
  State<TestPlayerScreen> createState() => _TestPlayerScreenState();
}

class _TestPlayerScreenState extends State<TestPlayerScreen> {
  final _api = YTMusicApi();
  final _controller = TextEditingController();
  List<Song> _results = [];
  bool _loading = false;
  Song? _current;

  Future<void> _search() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await _api.search(_controller.text);
      setState(() {
        _results = res;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showSnack('Search failed: $e');
    }
  }

  Future<void> _play(Song song) async {
    // Wait up to 15 sec for audioHandler
    int tries = 0;
    while (audioHandler == null && tries < 15) {
      await Future.delayed(const Duration(seconds: 1));
      tries++;
    }

    if (audioHandler == null) {
      _showSnack('Audio service failed to start. Check logs.');
      return;
    }

    setState(() => _current = song);
    _showSnack('Loading ${song.title}...');
    try {
      final url = await _api.getStreamUrl(song.id);
      await audioHandler!.playMedia(song.toMediaItem(url), url);
      _showSnack('Playing!');
    } catch (e) {
      _showSnack('Play failed: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
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
          if (_current != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: const Color(0xFF1A1A1A),
                child: ListTile(
                  leading: const Icon(Icons.music_note, color: Color(0xFFFA2D48)),
                  title: Text('Now: ${_current!.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(_current!.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey)),
                ),
              ),
            ),
          if (_loading) const LinearProgressIndicator(color: Color(0xFFFA2D48)),
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text(
                      'Search for songs to test\nnotification controls!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (_, i) {
                      final s = _results[i];
                      return ListTile(
                        leading: SizedBox(
                          width: 48,
                          height: 48,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(s.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey.shade900,
                                    )),
                          ),
                        ),
                        title: Text(s.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(s.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey)),
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
