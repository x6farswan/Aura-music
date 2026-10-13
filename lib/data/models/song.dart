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
}
