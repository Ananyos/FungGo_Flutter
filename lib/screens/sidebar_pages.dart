import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/song_card.dart';
import '../screens/user_manager.dart';

class SearchHistoryPage extends StatefulWidget {
  const SearchHistoryPage({Key? key}) : super(key: key);

  @override
  State<SearchHistoryPage> createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends State<SearchHistoryPage> {
  @override
  Widget build(BuildContext context) {
    // Listen to changes to update UI if needed
    final history = UserManager().searchHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No history yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                // We pass an empty query because we aren't highlighting text in history view
                return SongCard(song: history[index], searchQuery: '');
              },
            ),
    );
  }
}

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  Widget build(BuildContext context) {
    final bookmarks = UserManager().bookmarks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No bookmarks yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                // We rebuild to ensure the list updates if you un-bookmark something
                return SongCard(song: bookmarks[index], searchQuery: '');
              },
            ),
    );
  }
}