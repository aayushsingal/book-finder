import '../../../../core/network/network_info.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_local_data_source.dart';
import '../datasources/book_remote_data_source.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource apiService;
  final BookLocalDataSource databaseService;
  final NetworkInfo networkChecker;

  BookRepositoryImpl({
    required this.apiService,
    required this.databaseService,
    required this.networkChecker,
  });

  @override
  Future<List<Book>> searchBooks(String searchText, int pageNumber) async {
    try {
      final isConnected = await networkChecker.isConnected;

      if (isConnected) {
        final response = await apiService.searchBooks(searchText, pageNumber);

        // Update save status for each book
        final bookList = <BookModel>[];
        for (final bookData in response.docs) {
          final isSaved = await databaseService.isBookSaved(bookData.key);
          bookList.add(bookData.copyWith(isSaved: isSaved));
        }

        return bookList;
      } else {
        // Offline fallback
        return await databaseService.getSavedBooks();
      }
    } catch (error) {

      // Provide user-friendly error messages
      final errorString = error.toString().toLowerCase();

      if (errorString.contains('socketexception') ||
          errorString.contains('network') ||
          errorString.contains('timeout') ||
          errorString.contains('connection') ||
          errorString.contains('handshake')) {
        throw Exception(
          'No internet connection. Please check your network and try again.',
        );
      } else if (errorString.contains('404')) {
        throw Exception('Books not found. Try a different search term.');
      } else if (errorString.contains('500') ||
          errorString.contains('server')) {
        throw Exception('Server error. Please try again later.');
      } else if (errorString.contains('formatexception') ||
          errorString.contains('json')) {
        throw Exception('Invalid response from server. Please try again.');
      } else {
        throw Exception(
          'Unable to load books. Please check your connection and try again.',
        );
      }
    }
  }

  @override
  Future<Book?> getBookDetails(String bookId) async {
    try {
      if (await networkChecker.isConnected) {
        final response = await apiService.getBookDetails(bookId);
        final isSaved = await databaseService.isBookSaved(response.key);

        // Works API returns author keys, not names - merge in BLoC
        return BookModel(
          key: response.key,
          title: response.title ?? 'Unknown Title',
          authorName: [], // Will be merged with search result data
          coverId: response.covers?.isNotEmpty == true
              ? response.covers!.first
              : null,
          description: response.descriptionText,
          isSaved: isSaved,
        );
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to load book details. Please try again.');
    }
  }

  @override
  Future<List<Book>> getSavedBooks() async {
    try {
      final books = await databaseService.getSavedBooks();
      return books;
    } catch (error) {
      return [];
    }
  }

  @override
  Future<bool> saveBook(Book book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      await databaseService.saveBook(bookModel);
      
      // Verify that the book is now saved
      final isActuallySaved = await databaseService.isBookSaved(book.key);
      return isActuallySaved;
    } catch (error) {
      rethrow; // Preserve original error context
    }
  }

  @override
  Future<bool> removeBook(String bookId) async {
    try {
      return await databaseService.unsaveBook(bookId);
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> isBookSaved(String bookId) async {
    try {
      final result = await databaseService.isBookSaved(bookId);
      return result;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<BookModel?> getSavedBookDetails(String bookId) async {
    try {
      final result = await databaseService.getSavedBook(bookId);
      return result;
    } catch (error) {
      return null;
    }
  }
}
