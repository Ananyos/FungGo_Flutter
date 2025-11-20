import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/song.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static String? _tableName;
  static const String databaseFileName = 'songdb.db';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(databaseFileName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // FORCE DELETE to ensure fresh copy (remove this in production)
    try {
      await deleteDatabase(path);
    } catch (e) {
      print('⚠️ No old database to delete: $e');
    }

    // Copy from assets
    try {
      await Directory(dirname(path)).create(recursive: true);

      ByteData data = await rootBundle.load('assets/database/$filePath');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await File(path).writeAsBytes(bytes, flush: true);
    } catch (e) {
      print('❌ Error copying database: $e');
      rethrow;
    }

    // Open database
    final db = await openDatabase(path, version: 1);

    // Auto-detect table name
    await _detectTableName(db);

    return db;
  }

  Future<void> _detectTableName(Database db) async {
    if (_tableName != null) return;

    try {
      // Get all tables
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
      );

      if (tables.isEmpty) {
        throw Exception('No tables found in database');
      }

      // Use the first table found
      _tableName = tables.first['name'] as String;

      // Show table structure
      final columns = await db.rawQuery("PRAGMA table_info($_tableName)");

      for (var col in columns) {
        print('   ${col['name']} (${col['type']})');
      }
    } catch (e) {
      print('❌ Error detecting table: $e');
      rethrow;
    }
  }

  Future<List<Song>> searchSongs(String query) async {
    final db = await instance.database;

    if (query.isEmpty) return [];

    if (_tableName == null) {
      throw Exception('Table name not detected');
    }

    print('🔍 Searching for: "$query" in table: $_tableName');

    try {
      final searchTerm = '%${query.toLowerCase()}%';

      // Enhanced query with priority ranking
      // Priority: 1 = Title match, 2 = Artist match, 3 = Lyrics match
      final result = await db.rawQuery(
        '''
        SELECT *,
          CASE
            WHEN LOWER(CAST(title AS TEXT)) LIKE ? THEN 1
            WHEN LOWER(CAST(artist AS TEXT)) LIKE ? THEN 2
            WHEN LOWER(lyrics_full) LIKE ? THEN 3
            ELSE 4
          END AS match_priority
        FROM $_tableName 
        WHERE 
          (title IS NOT NULL AND LOWER(CAST(title AS TEXT)) LIKE ?) OR 
          (artist IS NOT NULL AND LOWER(CAST(artist AS TEXT)) LIKE ?) OR 
          (lyrics_full IS NOT NULL AND LOWER(lyrics_full) LIKE ?)
        ORDER BY 
          match_priority ASC
        LIMIT 50
      ''',
        [
          searchTerm, searchTerm, searchTerm, // For CASE statement
          searchTerm, searchTerm, searchTerm, // For WHERE clause
        ],
      );

      print('✅ Found ${result.length} results');

      // Print match distribution for debugging
      final titleMatches = result.where((r) => r['match_priority'] == 1).length;
      final artistMatches = result
          .where((r) => r['match_priority'] == 2)
          .length;
      final lyricsMatches = result
          .where((r) => r['match_priority'] == 3)
          .length;

      print('📊 Match distribution:');
      print(
        '   Title: $titleMatches, Artist: $artistMatches, Lyrics: $lyricsMatches',
      );

      return result.map((json) => Song.fromMap(json)).toList();
    } catch (e) {
      print('❌ Search error: $e');
      return [];
    }
  }

  Future<List<Song>> getAllSongs() async {
    final db = await instance.database;

    if (_tableName == null) {
      throw Exception('Table name not detected');
    }

    final result = await db.query(_tableName!, orderBy: 'id DESC', limit: 100);
    return result.map((json) => Song.fromMap(json)).toList();
  }

  Future<Song?> getSongById(int id) async {
    final db = await instance.database;

    if (_tableName == null) {
      throw Exception('Table name not detected');
    }

    final result = await db.query(
      _tableName!,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Song.fromMap(result.first);
    }
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
