import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/exceptions.dart';
import '../models/book_model.dart';

abstract class BookLocalDataSource {
  Future<List<BookModel>> getSavedBooks();
  Future<BookModel> saveBook(BookModel book);
  Future<bool> unsaveBook(String bookKey);
  Future<bool> isBookSaved(String bookKey);
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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT,
        cover_url TEXT,
        publish_year INTEGER,
        description TEXT,
        is_saved INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  @override
  Future<List<BookModel>> getSavedBooks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'is_saved = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => BookModel.fromJson(_mapToBookJson(map))).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<BookModel> saveBook(BookModel book) async {
    try {
      final db = await database;
      
      await db.insert(
        tableName,
        _bookToMap(book),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return book.copyWith(isSaved: true);
    } catch (e) {
      throw CacheException();
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
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ? AND is_saved = ?',
        whereArgs: [bookKey, 1],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      throw CacheException();
    }
  }

  Map<String, dynamic> _bookToMap(BookModel book) {
    return {
      'id': book.key,
      'title': book.title,
      'author': book.authorName.join(', '),
      'cover_url': book.coverUrl,
      'publish_year': book.firstPublishYear,
      'description': book.description,
      'is_saved': book.isSaved ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _mapToBookJson(Map<String, dynamic> map) {
    return {
      'key': map['id'],
      'title': map['title'],
      'author_name': (map['author'] as String?)?.split(', ') ?? [],
      'cover_i': null, // We'll use cover_url instead
      'first_publish_year': map['publish_year'],
      'description': map['description'],
      'is_saved': (map['is_saved'] as int?) == 1,
    };
  }
}