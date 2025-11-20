import 'package:flutter/material.dart';
import '../models/song.dart';

/// A simple singleton class to manage user data globally.
/// In a real app, you might use Provider, Riverpod, or SharedPreferences.
class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  final List<Song> _searchHistory = [];
  final List<Song> _bookmarks = [];

  List<Song> get searchHistory => _searchHistory;
  List<Song> get bookmarks => _bookmarks;

  // --- History Logic ---

  void addToHistory(Song song) {
    // Remove if it already exists to move it to the top
    _searchHistory.removeWhere((s) => s.title == song.title && s.artist == song.artist);
    
    // Add to the front
    _searchHistory.insert(0, song);

    // Keep only the recent 10
    if (_searchHistory.length > 10) {
      _searchHistory.removeLast();
    }
    
    notifyListeners();
  }

  // --- Bookmark Logic ---

  void toggleBookmark(Song song) {
    if (isBookmarked(song)) {
      _bookmarks.removeWhere((s) => s.title == song.title && s.artist == song.artist);
    } else {
      _bookmarks.add(song);
    }
    notifyListeners();
  }

  bool isBookmarked(Song song) {
    // Check by title and artist assuming they are unique identifiers
    return _bookmarks.any((s) => s.title == song.title && s.artist == song.artist);
  }
}