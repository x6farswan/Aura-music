import 'package:audio_service/audio_service.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String thumbnail;
  final Duration duration;
  final String? album;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnail,
    required this.duration,
    this.album,
  });

  MediaItem toMediaItem(String streamUrl) => MediaItem(
        id: id,
        title: title,
        artist: artist,
        album: album,
        duration: duration,
        artUri: Uri.parse(thumbnail),
        extras: {'streamUrl': streamUrl},
      );
}
