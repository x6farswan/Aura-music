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
    final res = await _api.search(_controller.text);
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  Future<void> _play(Song song) async {
    setState(() => _current = song);
    final url = await _api.getStreamUrl(song.id);
    await audioHandler.playMedia(song.toMediaItem(url), url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aura Music')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search songs...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_current != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.music_note, color: Color(0xFFFA2D48)),
                  title: Text('Now: ${_current!.title}',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(_current!.artist,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          if (_loading) const LinearProgressIndicator(),
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
                            child: Image.network(s.thumbnail, fit: BoxFit.cover),
                          ),
                        ),
                        title: Text(s.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(s.artist,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
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
