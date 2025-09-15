import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/usecases/search_books.dart';

part 'book_search_event.dart';
part 'book_search_state.dart';

class BookSearchBloc extends Bloc<BookSearchEvent, BookSearchState> {
  final SearchBooks searchBooksUseCase;
  String? _currentActualSearchTerm; // Track actual search term used

  BookSearchBloc({required this.searchBooksUseCase})
    : super(BookSearchInitial()) {
    on<SearchBooksEvent>(_searchForBooks);
    on<LoadMoreBooksEvent>(_loadMoreBooks);
    on<RefreshBooksEvent>(_refreshBooks);
    on<LoadPopularBooksEvent>(_loadPopularBooks);
  }

  Future<void> _searchForBooks(
    SearchBooksEvent event,
    Emitter<BookSearchState> emit,
  ) async {
    debugPrint('Search triggered for: "${event.searchText}"');

    if (event.searchText.trim().isEmpty) {
      debugPrint('Search text is empty, returning to initial state');
      emit(BookSearchInitial());
      return;
    }

    // Store the actual search term for pagination
    _currentActualSearchTerm = event.searchText;
    
    debugPrint('Starting search loading state');
    emit(BookSearchLoading());

    try {
      debugPrint('Calling search use case...');
      final bookList = await searchBooksUseCase(
        SearchParams(searchText: event.searchText, pageNumber: 1),
      );

      debugPrint('Search returned ${bookList.length} books');

      if (bookList.isEmpty) {
        debugPrint('No books found, emitting empty state');
        emit(BookSearchEmpty(searchText: event.searchText));
      } else {
        debugPrint(
          'Books found, emitting loaded state with ${bookList.length} items',
        );
        emit(
          BookSearchLoaded(
            bookList: bookList,
            searchText: event.searchText,
            currentPage: 1,
            hasMoreBooks: bookList.length >= 20,
          ),
        );
      }
    } catch (error) {
      debugPrint('Search error: $error');
      
      // Extract user-friendly message from exception
      String errorMessage = 'Failed to search books';
      if (error is Exception) {
        final exceptionMessage = error.toString().replaceFirst('Exception: ', '');
        errorMessage = exceptionMessage.isNotEmpty ? exceptionMessage : errorMessage;
      }
      
      emit(BookSearchError(errorMessage: errorMessage));
    }
  }

  Future<void> _loadMoreBooks(
    LoadMoreBooksEvent event,
    Emitter<BookSearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BookSearchLoaded || !currentState.hasMoreBooks) {
      return;
    }

    emit(
      BookSearchLoadingMore(
        bookList: currentState.bookList,
        searchText: currentState.searchText,
        currentPage: currentState.currentPage,
      ),
    );

    try {
      // Use the actual search term for pagination, not the display search text
      final searchTerm = _currentActualSearchTerm ?? currentState.searchText;
      if (searchTerm.isEmpty) {
        debugPrint('No search term available for loading more');
        return;
      }
      
      debugPrint('Loading more books for: "$searchTerm", page ${currentState.currentPage + 1}');
      final newBooks = await searchBooksUseCase(
        SearchParams(
          searchText: searchTerm,
          pageNumber: currentState.currentPage + 1,
        ),
      );

      debugPrint('Load more returned ${newBooks.length} additional books');
      
      final allBooks = List<Book>.from(currentState.bookList)..addAll(newBooks);
      emit(
        BookSearchLoaded(
          bookList: allBooks,
          searchText: currentState.searchText,
          currentPage: currentState.currentPage + 1,
          hasMoreBooks: newBooks.length >= 20,
        ),
      );
    } catch (error) {
      debugPrint('Load more error: $error');
      
      // Don't emit error state for pagination failures, just revert to loaded state
      // This prevents the entire UI from showing an error when pagination fails
      emit(
        BookSearchLoaded(
          bookList: currentState.bookList,
          searchText: currentState.searchText,
          currentPage: currentState.currentPage,
          hasMoreBooks: false, // Disable further loading if it failed
        ),
      );
    }
  }

  Future<void> _refreshBooks(
    RefreshBooksEvent event,
    Emitter<BookSearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is BookSearchLoaded) {
      // If searchText is empty, it means we're showing popular books
      if (currentState.searchText.isEmpty) {
        add(const LoadPopularBooksEvent());
      } else {
        add(SearchBooksEvent(currentState.searchText));
      }
    } else {
      // If we're in any other state, load popular books
      add(const LoadPopularBooksEvent());
    }
  }

  Future<void> _loadPopularBooks(
    LoadPopularBooksEvent event,
    Emitter<BookSearchState> emit,
  ) async {
    debugPrint('Loading popular books...');
    emit(BookSearchLoading());

    try {
      // Search for popular trending topics to show initially
      final popularSearchTerms = ['fiction', 'mystery', 'romance', 'science'];
      final randomTerm = popularSearchTerms[(DateTime.now().millisecondsSinceEpoch % popularSearchTerms.length)];
      
      // Store the actual search term for pagination
      _currentActualSearchTerm = randomTerm;
      
      debugPrint('Loading books for category: $randomTerm');
      final bookList = await searchBooksUseCase(
        SearchParams(searchText: randomTerm, pageNumber: 1),
      );

      debugPrint('Popular books loaded: ${bookList.length} books');

      if (bookList.isEmpty) {
        debugPrint('No popular books found');
        emit(BookSearchEmpty(searchText: 'popular books'));
      } else {
        debugPrint('Emitting popular books loaded state');
        emit(
          BookSearchLoaded(
            bookList: bookList,
            searchText: '', // Empty search text indicates we're showing popular books
            currentPage: 1,
            hasMoreBooks: bookList.length >= 20,
          ),
        );
      }
    } catch (error) {
      debugPrint('Popular books error: $error');
      
      String errorMessage = 'Failed to load books';
      if (error is Exception) {
        final exceptionMessage = error.toString().replaceFirst('Exception: ', '');
        errorMessage = exceptionMessage.isNotEmpty ? exceptionMessage : errorMessage;
      }
      
      emit(BookSearchError(errorMessage: errorMessage));
    }
  }
}
