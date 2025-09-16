import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/usecases/search_books.dart';

part 'book_search_event.dart';
part 'book_search_state.dart';

class BookSearchBloc extends Bloc<BookSearchEvent, BookSearchState> {
  final SearchBooks searchBooksUseCase;
  String? _currentActualSearchTerm; // For pagination consistency

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
    if (event.searchText.trim().isEmpty) {
      emit(BookSearchInitial());
      return;
    }

    _currentActualSearchTerm = event.searchText;
    
    emit(BookSearchLoading());

    try {
      final bookList = await searchBooksUseCase(
        SearchParams(searchText: event.searchText, pageNumber: 1),
      );

      if (bookList.isEmpty) {
        emit(BookSearchEmpty(searchText: event.searchText));
      } else {
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
      // Extract meaningful error message
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
      // Use stored search term for consistent pagination
      final searchTerm = _currentActualSearchTerm ?? currentState.searchText;
      if (searchTerm.isEmpty) return;
      
      final newBooks = await searchBooksUseCase(
        SearchParams(
          searchText: searchTerm,
          pageNumber: currentState.currentPage + 1,
        ),
      );
      
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
      // If searchText is empty, showing popular books
      if (currentState.searchText.isEmpty) {
        add(const LoadPopularBooksEvent()); // Refresh popular books
      } else {
        add(
          SearchBooksEvent(currentState.searchText),
        ); // Re-search current term
      }
    } else {
      add(const LoadPopularBooksEvent()); // Default to popular books
    }
  }

  Future<void> _loadPopularBooks(
    LoadPopularBooksEvent event,
    Emitter<BookSearchState> emit,
  ) async {
    emit(BookSearchLoading());

    try {
      // Search for popular trending topics to show initially
      final popularSearchTerms = [
        'fiction',
        'mystery',
        'romance',
        'science',
        'fantasy',
        'biography',
      ];
      final randomTerm = popularSearchTerms[(DateTime.now().millisecondsSinceEpoch % popularSearchTerms.length)];
      
      _currentActualSearchTerm = randomTerm;
      
      final bookList = await searchBooksUseCase(
        SearchParams(searchText: randomTerm, pageNumber: 1),
      );

      if (bookList.isEmpty) {
        emit(BookSearchInitial());
      } else {
        emit(
          BookSearchLoaded(
            bookList: bookList,
            searchText: '', // Empty = showing popular books
            currentPage: 1,
            hasMoreBooks: bookList.length >= 20,
          ),
        );
      }
    } catch (error) {
      
      // Instead of showing error on app startup, fall back to initial state
      // This provides a better user experience
      emit(BookSearchInitial());
    }
  }
}
