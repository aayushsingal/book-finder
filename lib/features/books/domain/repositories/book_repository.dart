import '../entities/book.dart';

// Repository contract for book-related operations
abstract class BookRepository {
  Future<List<Book>> searchBooks(String searchText, int pageNumber);
  Future<Book?> getBookDetails(String bookId);
  Future<List<Book>> getSavedBooks();
  Future<bool> saveBook(Book book);
  Future<bool> removeBook(String bookId);
  Future<bool> isBookSaved(String bookId);
  Future<Book?> getSavedBookDetails(String bookId);
}