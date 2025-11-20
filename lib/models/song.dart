class Song {
  final int? id;
  final String title;
  final String artist;
  final String lyrics;
  final int? year;

  Song({
    this.id,
    required this.title,
    required this.artist,
    required this.lyrics,
    this.year,
  });

  // Factory constructor to create Song from database map
  factory Song.fromMap(Map<String, dynamic> map) {
    // Helper function to safely parse integers
    int? parseIntSafely(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    return Song(
      id: parseIntSafely(map['id']),
      title: map['title']?.toString() ?? 'Unknown Title',
      artist: map['artist']?.toString() ?? 'Unknown Artist',
      lyrics: map['lyrics_full']?.toString() ?? '',
      year: parseIntSafely(map['year'])
    );
  }

  // Convert Song to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'lyrics_full': lyrics,
      'year': year,
    };
  }

  // Getters for backward compatibility with your existing UI code
  String get album => year?.toString() ?? 'Unknown';
  String get duration => '';
  String? get imageUrl => null;
}