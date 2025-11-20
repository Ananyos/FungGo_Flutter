import 'package:flutter/material.dart';
import '../models/song.dart';
import '../screens/song_detail_page.dart';
import '../screens/user_manager.dart'; // Import the user manager

class SongCard extends StatefulWidget {
  final Song song;
  final String searchQuery;

  const SongCard({Key? key, required this.song, required this.searchQuery})
    : super(key: key);

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  // Utility function to generate a TextSpan with highlighted search results
  List<TextSpan> _highlightText(
    String text,
    String query,
    TextStyle defaultStyle,
    TextStyle highlightStyle,
  ) {
    if (query.isEmpty || text.isEmpty) {
      return [TextSpan(text: text, style: defaultStyle)];
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final firstMatchIndex = lowerText.indexOf(lowerQuery);

    if (firstMatchIndex != -1) {
      final spans = <TextSpan>[];
      if (firstMatchIndex > 0) {
        spans.add(
          TextSpan(
            text: text.substring(0, firstMatchIndex),
            style: defaultStyle,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(
            firstMatchIndex,
            firstMatchIndex + lowerQuery.length,
          ),
          style: highlightStyle,
        ),
      );
      spans.add(
        TextSpan(
          text: text.substring(firstMatchIndex + lowerQuery.length),
          style: defaultStyle,
        ),
      );
      return spans;
    } else {
      return [TextSpan(text: text, style: defaultStyle)];
    }
  }

  // Utility function to find the first lyrics match
  List<TextSpan>? _getFirstLyricsMatchSnippet(
    String lyrics,
    String query,
    TextStyle defaultStyle,
    TextStyle highlightStyle,
  ) {
    if (query.isEmpty || lyrics.isEmpty) return null;

    final lowerLyrics = lyrics.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final firstMatchIndex = lowerLyrics.indexOf(lowerQuery);

    if (firstMatchIndex == -1) {
      return null;
    }

    const int contextLength = 50;
    int snippetStart = firstMatchIndex - contextLength;
    if (snippetStart < 0) snippetStart = 0;

    int snippetEnd = firstMatchIndex + lowerQuery.length + contextLength;
    if (snippetEnd > lyrics.length) snippetEnd = lyrics.length;

    final snippet = lyrics.substring(snippetStart, snippetEnd);
    final snippetLower = snippet.toLowerCase();
    final snippetMatchIndex = snippetLower.indexOf(lowerQuery);

    final spans = <TextSpan>[];
    final matchStart = snippetMatchIndex;
    final matchEnd = snippetMatchIndex + lowerQuery.length;

    if (matchStart > 0) {
      spans.add(
        TextSpan(text: snippet.substring(0, matchStart), style: defaultStyle),
      );
    }

    spans.add(
      TextSpan(
        text: snippet.substring(matchStart, matchEnd),
        style: highlightStyle,
      ),
    );

    if (matchEnd < snippet.length) {
      spans.add(
        TextSpan(text: snippet.substring(matchEnd), style: defaultStyle),
      );
    }

    if (snippetStart > 0) {
      spans.insert(0, TextSpan(text: '...', style: defaultStyle));
    }
    if (snippetEnd < lyrics.length) {
      spans.add(TextSpan(text: '...', style: defaultStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final defaultTitleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final defaultArtistStyle = TextStyle(fontSize: 14, color: Colors.grey[700]);
    final defaultLyricsStyle = TextStyle(fontSize: 12, color: Colors.grey[500]);
    final highlightStyle = const TextStyle(
      backgroundColor: Color(0xFFFDD835),
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
    final highlightLyricsStyle = highlightStyle.copyWith(fontSize: 12);

    final lyricsSnippetSpans = _getFirstLyricsMatchSnippet(
      widget.song.lyrics,
      widget.searchQuery,
      defaultLyricsStyle,
      highlightLyricsStyle,
    );

    // Check if currently bookmarked
    final isBookmarked = UserManager().isBookmarked(widget.song);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // 1. Add to history when clicked
          UserManager().addToHistory(widget.song);

          // 2. Navigate
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongDetailPage(
                song: widget.song,
                searchQuery: widget.searchQuery,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.library_music,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: defaultTitleStyle.copyWith(color: Colors.black),
                        children: _highlightText(
                          widget.song.title,
                          widget.searchQuery,
                          defaultTitleStyle.copyWith(color: Colors.black),
                          highlightStyle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: defaultArtistStyle,
                        children: _highlightText(
                          widget.song.artist,
                          widget.searchQuery,
                          defaultArtistStyle,
                          highlightStyle,
                        ),
                      ),
                    ),
                    if (lyricsSnippetSpans != null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Lyrics Match:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: defaultLyricsStyle,
                          children: lyricsSnippetSpans,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // NEW: Bookmark Button
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.deepOrange : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    UserManager().toggleBookmark(widget.song);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
