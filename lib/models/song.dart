class Song {
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String lyrics;
  final String? imageUrl;

  Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.lyrics,
    this.imageUrl,
  });
}