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

  Future<List<Song>> trending() async {
    final results = await _explode.search.search('trending music 2024');
    return results
        .where((v) => v is yt.Video)
        .cast<yt.Video>()
        .take(15)
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
    final audio = manifest.audioOnly.withHighestBitrate();
    return audio.url.toString();
  }

  void dispose() => _explode.close();
}
