import '../models/song.dart';
import 'database_helper.dart';

class MockDatabase {
  // This class now acts as a wrapper for DatabaseHelper
  static Future<List<Song>> searchSongs(String query) async {
    return await DatabaseHelper.instance.searchSongs(query);
  }

  static Future<List<Song>> getAllSongs() async {
    return await DatabaseHelper.instance.getAllSongs();
  }
}
