import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/usecases/get_book_details.dart';
import '../../../domain/usecases/get_saved_book_details.dart';
import '../../../domain/usecases/save_book.dart';
import '../../../domain/usecases/unsave_book.dart';

part 'book_details_event.dart';
part 'book_details_state.dart';

class BookDetailsBloc extends Bloc<BookDetailsEvent, BookDetailsState> {
  final GetBookDetails getBookDetails;
  final GetSavedBookDetails getSavedBookDetails;
  final SaveBook saveBook;
  final RemoveBook removeBook;

  BookDetailsBloc({
    required this.getBookDetails,
    required this.getSavedBookDetails,
    required this.saveBook,
    required this.removeBook,
  }) : super(BookDetailsInitial()) {
    on<GetBookDetailsEvent>(_onGetBookDetails);
    on<SaveBookEvent>(_onSaveBook);
    on<UnsaveBookEvent>(_onUnsaveBook);
  }

  Future<void> _onGetBookDetails(
    GetBookDetailsEvent event,
    Emitter<BookDetailsState> emit,
  ) async {
    // Immediately emit the original book data to prevent UI flicker
    if (event.originalBook != null) {
      emit(BookDetailsLoaded(bookDetails: event.originalBook!));
    } else {
      emit(BookDetailsLoading());
    }

    try {
      // First check if this book is saved locally with complete details
      debugPrint(
        'BookDetailsBloc: Checking for saved book details for: ${event.workId}',
      );
      final savedBook = await getSavedBookDetails(event.workId);

      if (savedBook != null) {
        // Found saved book with complete details, use it directly
        debugPrint(
          'BookDetailsBloc: Found saved book details locally, using local data',
        );

        // Merge with original book data if needed to preserve any UI-specific fields
        Book finalBook = savedBook;
        if (event.originalBook != null) {
          finalBook = savedBook.copyWith(
            // Preserve author name from original if it's more complete
            authorName: event.originalBook!.authorName.isNotEmpty
                ? event.originalBook!.authorName
                : savedBook.authorName,
          );
        }

        emit(BookDetailsLoaded(bookDetails: finalBook));
        return; // Exit early, no need for API call
      }

      // Book not saved locally, fetch from API
      debugPrint('BookDetailsBloc: Book not saved locally, fetching from API');
      final enhancedBook = await getBookDetails(event.workId);
      if (enhancedBook != null) {
        // Merge original book data (especially author names) with enhanced details
        Book finalBook = enhancedBook;
        
        if (event.originalBook != null) {
          finalBook = enhancedBook.copyWith(
            authorName: event.originalBook!.authorName.isNotEmpty 
                ? event.originalBook!.authorName 
                : enhancedBook.authorName,
            // Also preserve other fields if they're missing in enhanced data
            firstPublishYear: enhancedBook.firstPublishYear ?? event.originalBook!.firstPublishYear,
            isbn: enhancedBook.isbn?.isNotEmpty == true 
                ? enhancedBook.isbn 
                : event.originalBook!.isbn,
          );
        }
        
        emit(BookDetailsLoaded(bookDetails: finalBook));
      } else {
        // If enhanced data fails but we have original book, keep showing it
        if (event.originalBook != null) {
          emit(BookDetailsLoaded(bookDetails: event.originalBook!));
        } else {
          emit(BookDetailsError(errorMessage: 'Book not found'));
        }
      }
    } catch (error) {
      debugPrint('BookDetailsBloc: Error getting book details: $error');
      // If there's an error but we have original book data, keep showing it
      if (event.originalBook != null) {
        emit(BookDetailsLoaded(bookDetails: event.originalBook!));
      } else {
        emit(BookDetailsError(errorMessage: error.toString()));
      }
    }
  }

  Future<void> _onSaveBook(
    SaveBookEvent event,
    Emitter<BookDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BookDetailsLoaded) {
      debugPrint('BookDetailsBloc: Starting save for book: ${event.book.key}');
      emit(BookDetailsSaving(bookDetails: currentState.bookDetails));

      try {
        debugPrint('BookDetailsBloc: Calling save use case...');
        final success = await saveBook(event.book);
        debugPrint('BookDetailsBloc: Save result: $success');
        if (success) {
          debugPrint('BookDetailsBloc: Save successful, updating state');
          emit(BookDetailsLoaded(
            bookDetails: currentState.bookDetails.copyWith(isSaved: true),
          ));
        } else {
          debugPrint('BookDetailsBloc: Save failed');
          emit(BookDetailsError(errorMessage: 'Failed to save book'));
        }
      } catch (error) {
        debugPrint('BookDetailsBloc: Save error: $error');
        emit(BookDetailsError(errorMessage: error.toString()));
      }
    }
  }

  Future<void> _onUnsaveBook(
    UnsaveBookEvent event,
    Emitter<BookDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BookDetailsLoaded) {
      emit(BookDetailsSaving(bookDetails: currentState.bookDetails));

      try {
        final success = await removeBook(event.bookKey);
        if (success) {
          emit(BookDetailsLoaded(
            bookDetails: currentState.bookDetails.copyWith(isSaved: false),
          ));
        } else {
          emit(BookDetailsError(errorMessage: 'Failed to remove book'));
        }
      } catch (error) {
        emit(BookDetailsError(errorMessage: error.toString()));
      }
    }
  }
}