import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import '../models/song.dart';

class YTMusicApi {
  final yt.YoutubeExplode _explode = yt.YoutubeExplode();

  Future<List<Song>> search(String query, {int limit = 20}) async {
    final results = await _explode.search.search(query);
    return results
        .where((v) => v is yt.Video)
        .cast<yt.Video>()
        .take(limit)
        .map((v) => Song(
              id: v.id.value,
              title: v.title,
              artist: v.author,
              thumbnail: v.thumbnails.highResUrl,
              duration: v.duration ?? Duration.zero,
            ))
        .toList();
  }

  Future<String> getStreamUrl(String videoId) async {
    final manifest = await _explode.videos.streamsClient.getManifest(videoId);
    // Prefer M4A/AAC (universally supported by Android)
    final m4aStreams = manifest.audioOnly
        .where((s) => s.container == yt.StreamContainer.mp4)
        .toList();
    final stream = m4aStreams.isNotEmpty
        ? m4aStreams.withHighestBitrate()
        : manifest.audioOnly.withHighestBitrate();
    return stream.url.toString();
  }

  void dispose() => _explode.close();
}
