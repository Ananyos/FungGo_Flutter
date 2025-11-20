import 'package:flutter/material.dart';
import '../models/song.dart';

class SongDetailPage extends StatelessWidget {
  final Song song;
  final String searchQuery; // Added to enable lyrics highlighting

  const SongDetailPage({
    Key? key,
    required this.song,
    required this.searchQuery,
  }) : super(key: key);

  // Utility function to generate a TextSpan with highlighted search results
  List<TextSpan> _highlightText(String text, String query, TextStyle defaultStyle, TextStyle highlightStyle) {
    if (query.isEmpty || text.isEmpty) {
      return [TextSpan(text: text, style: defaultStyle)];
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    final spans = <TextSpan>[];
    int currentPosition = 0;
    int index = -1;

    // Iterate to find all occurrences of the query
    do {
      index = lowerText.indexOf(lowerQuery, currentPosition);
      
      if (index == -1) {
        // No more matches, add the rest of the text
        spans.add(TextSpan(
          text: text.substring(currentPosition),
          style: defaultStyle,
        ));
        break;
      }

      // 1. Text before the match
      if (index > currentPosition) {
        spans.add(TextSpan(
          text: text.substring(currentPosition, index),
          style: defaultStyle,
        ));
      }
      
      // 2. The highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + lowerQuery.length),
        style: highlightStyle,
      ));

      // Move the position past the current match
      currentPosition = index + lowerQuery.length;
    } while (index != -1);

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    // Styles for the lyrics highlighting
    final defaultLyricsStyle = TextStyle(
      fontSize: 16,
      color: Colors.grey[800],
      height: 1.6,
    );
    final highlightStyle = const TextStyle(
      backgroundColor: Color(0xFFFDD835), // Yellow highlight background
      color: Colors.black,
      fontWeight: FontWeight.bold,
      height: 1.6, // Must match defaultLyricsStyle height
    );


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Song Details',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album art
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.grey,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Song title (No highlighting here, as it's the detail page)
              Text(
                song.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // Artist
              Text(
                song.artist,
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),

              // Year and views info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (song.year != null)
                      _buildInfoRow('Year', song.year.toString()),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Lyrics section
              const Text(
                'Lyrics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // Use RichText to display highlighted lyrics
                child: RichText(
                  text: TextSpan(
                    style: defaultLyricsStyle,
                    children: _highlightText(
                      song.lyrics,
                      searchQuery,
                      defaultLyricsStyle,
                      highlightStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}