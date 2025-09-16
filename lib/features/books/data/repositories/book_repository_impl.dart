import 'package:flutter/material.dart';

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
    debugPrint(
      'Repository: Starting search for "$searchText", page $pageNumber',
    );
    try {
      final isConnected = await networkChecker.isConnected;
      debugPrint('Network connected: $isConnected');

      if (isConnected) {
        debugPrint('Making API call...');
        final response = await apiService.searchBooks(searchText, pageNumber);
        debugPrint(
          'API response received with ${response.docs.length} books',
        );

        // Check which books are saved and update their status
        final bookList = <BookModel>[];
        for (final bookData in response.docs) {
          final isSaved = await databaseService.isBookSaved(bookData.key);
          bookList.add(bookData.copyWith(isSaved: isSaved));
        }

        debugPrint('Repository returning ${bookList.length} books');
        return bookList;
      } else {
        // If no internet, return saved books that match the search
        debugPrint('No internet connection, returning saved books');
        return await databaseService.getSavedBooks();
      }
    } catch (error) {
      debugPrint('Repository error searching books: $error');

      // Provide user-friendly error messages
      if (error.toString().contains('SocketException') ||
          error.toString().contains('network') ||
          error.toString().contains('timeout')) {
        throw Exception(
          'No internet connection. Please check your network and try again.',
        );
      } else if (error.toString().contains('404')) {
        throw Exception('Books not found. Try a different search term.');
      } else if (error.toString().contains('500')) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    }
  }

  @override
  Future<Book?> getBookDetails(String bookId) async {
    try {
      if (await networkChecker.isConnected) {
        final response = await apiService.getBookDetails(bookId);
        final isSaved = await databaseService.isBookSaved(response.key);

        // Debug: Print the authors structure from API
        debugPrint('Authors from API: ${response.authors}');
        
        // The works API doesn't provide author names directly, only author keys
        // So we'll return empty authorName and let the BLoC preserve the original
        // author names from the search result when navigating to details
        return BookModel(
          key: response.key,
          title: response.title ?? 'Unknown Title',
          authorName: [], // Leave empty, will be merged with original book data
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
      debugPrint('Error getting book details: $error');
      throw Exception('Failed to load book details. Please try again.');
    }
  }

  @override
  Future<List<Book>> getSavedBooks() async {
    try {
      debugPrint('Repository: Getting saved books...');
      final books = await databaseService.getSavedBooks();
      debugPrint('Repository: Retrieved ${books.length} saved books');
      return books;
    } catch (error) {
      debugPrint('Repository: Error getting saved books: $error');
      return [];
    }
  }

  @override
  Future<bool> saveBook(Book book) async {
    try {
      debugPrint('Repository: Attempting to save book with key: ${book.key}');
      debugPrint('Repository: Book title: ${book.title}');
      debugPrint('Repository: Book authors: ${book.authorName}');
      
      final bookModel = BookModel.fromEntity(book);
      debugPrint('Repository: BookModel created, saving to database...');

      final savedBook = await databaseService.saveBook(bookModel);
      debugPrint(
        'Repository: Book saved successfully, returned book isSaved: ${savedBook.isSaved}',
      );

      // Double check that the book is now saved
      final isActuallySaved = await databaseService.isBookSaved(book.key);
      debugPrint(
        'Repository: Final verification - book is saved: $isActuallySaved',
      );

      return isActuallySaved;
    } catch (error) {
      debugPrint('Repository: Error saving book: $error');
      debugPrint('Repository: Stack trace: ${StackTrace.current}');
      rethrow; // Let the original error bubble up
    }
  }

  @override
  Future<bool> removeBook(String bookId) async {
    try {
      return await databaseService.unsaveBook(bookId);
    } catch (error) {
      debugPrint('Error removing book: $error');
      return false;
    }
  }

  @override
  Future<bool> isBookSaved(String bookId) async {
    try {
      debugPrint('Repository: Checking if book is saved with key: $bookId');
      final result = await databaseService.isBookSaved(bookId);
      debugPrint('Repository: Book saved status: $result');
      return result;
    } catch (error) {
      debugPrint('Error checking if book is saved: $error');
      return false;
    }
  }

  @override
  Future<BookModel?> getSavedBookDetails(String bookId) async {
    try {
      debugPrint('Repository: Getting saved book details for key: $bookId');
      final result = await databaseService.getSavedBook(bookId);
      if (result != null) {
        debugPrint('Repository: Found saved book details locally');
      } else {
        debugPrint('Repository: No saved book details found for key: $bookId');
      }
      return result;
    } catch (error) {
      debugPrint('Error getting saved book details: $error');
      return null;
    }
  }
}
