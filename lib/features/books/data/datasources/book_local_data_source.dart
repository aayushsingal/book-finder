import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/exceptions.dart';
import '../models/book_model.dart';

abstract class BookLocalDataSource {
  Future<List<BookModel>> getSavedBooks();
  Future<BookModel> saveBook(BookModel book);
  Future<bool> unsaveBook(String bookKey);
  Future<bool> isBookSaved(String bookKey);
  Future<BookModel?> getSavedBook(String bookKey);
}

class BookLocalDataSourceImpl implements BookLocalDataSource {
  static const String tableName = 'books';
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'books.db');
    
    debugPrint('LocalDataSource: Initializing database at: $path');

    return await openDatabase(
      path,
      version: 2, // Incremented version for migration
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint(
      'LocalDataSource: Upgrading database from version $oldVersion to $newVersion',
    );
    if (oldVersion < 2) {
      // Add the cover_id column if it doesn't exist
      await db.execute('ALTER TABLE $tableName ADD COLUMN cover_id INTEGER');
      debugPrint('LocalDataSource: Added cover_id column');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('LocalDataSource: Creating database table $tableName');
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT,
        cover_url TEXT,
        cover_id INTEGER,
        publish_year INTEGER,
        description TEXT,
        is_saved INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    debugPrint('LocalDataSource: Database table created successfully');
  }

  @override
  Future<List<BookModel>> getSavedBooks() async {
    try {
      final db = await database;
      debugPrint('LocalDataSource: Getting saved books...');

      // First, let's check what tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      debugPrint('LocalDataSource: Available tables: $tables');

      // Check if our table exists and has data
      final count = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      debugPrint('LocalDataSource: Total books in database: $count');
      
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'is_saved = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC',
      );
      
      debugPrint('LocalDataSource: Found ${maps.length} saved books');
      if (maps.isNotEmpty) {
        debugPrint('LocalDataSource: First saved book: ${maps.first}');
      }

      return maps.map((map) => BookModel.fromJson(_mapToBookJson(map))).toList();
    } catch (e) {
      debugPrint('LocalDataSource: Error getting saved books: $e');
      rethrow;
    }
  }

  @override
  Future<BookModel> saveBook(BookModel book) async {
    try {
      final db = await database;
      
      // CRITICAL FIX: Ensure the book is marked as saved before converting to map
      final bookToSave = book.copyWith(isSaved: true);
      final bookMap = _bookToMap(bookToSave);

      debugPrint('LocalDataSource: Saving book with data: $bookMap');
      final result = await db.insert(
        tableName,
        bookMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint(
        'LocalDataSource: Book saved to database successfully with result: $result',
      );

      // Verify the book was actually saved by querying it back
      final savedCheck = await isBookSaved(book.key);
      debugPrint(
        'LocalDataSource: Save verification - book exists: $savedCheck',
      );

      return bookToSave;
    } catch (e) {
      debugPrint('LocalDataSource: Error saving book: $e');
      debugPrint('LocalDataSource: Stack trace: ${StackTrace.current}');
      rethrow; // Throw the actual exception instead of CacheException
    }
  }

  @override
  Future<bool> unsaveBook(String bookKey) async {
    try {
      final db = await database;
      final result = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [bookKey],
      );

      return result > 0;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> isBookSaved(String bookKey) async {
    try {
      final db = await database;
      debugPrint(
        'LocalDataSource: Checking if book is saved with key: $bookKey',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ? AND is_saved = ?',
        whereArgs: [bookKey, 1],
        limit: 1,
      );
      
      debugPrint('LocalDataSource: Query result: ${maps.length} matches');
      if (maps.isNotEmpty) {
        debugPrint('LocalDataSource: Found saved book: ${maps.first}');
      }

      return maps.isNotEmpty;
    } catch (e) {
      debugPrint('LocalDataSource: Error checking if book is saved: $e');
      throw CacheException();
    }
  }

  @override
  Future<BookModel?> getSavedBook(String bookKey) async {
    try {
      final db = await database;
      debugPrint(
        'LocalDataSource: Getting saved book details for key: $bookKey',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ? AND is_saved = ?',
        whereArgs: [bookKey, 1],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        debugPrint(
          'LocalDataSource: Found saved book with full details: ${maps.first}',
        );
        return BookModel.fromJson(_mapToBookJson(maps.first));
      } else {
        debugPrint('LocalDataSource: No saved book found for key: $bookKey');
        return null;
      }
    } catch (e) {
      debugPrint('LocalDataSource: Error getting saved book details: $e');
      throw CacheException();
    }
  }

  Map<String, dynamic> _bookToMap(BookModel book) {
    return {
      'id': book.key,
      'title': book.title,
      'author': book.authorName.join(', '),
      'cover_url': book.coverUrl,
      'cover_id': book.coverId, // Store the cover ID as well
      'publish_year': book.firstPublishYear,
      'description': book.description,
      'is_saved': book.isSaved ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _mapToBookJson(Map<String, dynamic> map) {
    // Use stored cover_id if available, otherwise extract from cover URL
    int? coverId = map['cover_id'] as int?;

    if (coverId == null) {
      final coverUrl = map['cover_url'] as String?;
      if (coverUrl != null && coverUrl.isNotEmpty) {
        // Extract cover ID from URL like "https://covers.openlibrary.org/b/id/12345-M.jpg"
        final match = RegExp(r'/id/(\d+)-[A-Z]\.jpg$').firstMatch(coverUrl);
        if (match != null) {
          coverId = int.tryParse(match.group(1)!);
        }
      }
    }
    
    return {
      'key': map['id'],
      'title': map['title'],
      'author_name': (map['author'] as String?)?.split(', ') ?? [],
      'cover_i': coverId,
      'first_publish_year': map['publish_year'],
      'description': map['description'],
      'is_saved': (map['is_saved'] as int?) == 1,
    };
  }
}