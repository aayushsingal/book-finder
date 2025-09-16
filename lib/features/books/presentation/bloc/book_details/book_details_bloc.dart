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
    // Always show loading state first to ensure complete data loads together
    emit(BookDetailsLoading());

    try {
      // Check for locally saved book with complete data
      final fullKey = '/works/${event.workId}';
      if (kDebugMode) {
        debugPrint('BookDetails: Checking local data for ${event.workId}');
      }

      final savedBook = await getSavedBookDetails(fullKey);

      if (savedBook != null && savedBook.description?.isNotEmpty == true) {
        // Found saved book with complete details, use it directly
        if (kDebugMode) {
          debugPrint('BookDetails: Using local data with description');
        }

        // Merge with original data to preserve UI fields
        Book finalBook = savedBook;
        if (event.originalBook != null) {
          finalBook = savedBook.copyWith(
            // Keep better author names from search results
            authorName: event.originalBook!.authorName.isNotEmpty
                ? event.originalBook!.authorName
                : savedBook.authorName,
          );
        }

        emit(BookDetailsLoaded(bookDetails: finalBook));
        return;
      }

      // Book not saved locally or needs description update, fetch from API
      if (kDebugMode) {
        debugPrint('BookDetails: Fetching from API for ${event.workId}');
      }
      final fullBookDetails = await getBookDetails(event.workId);
      if (fullBookDetails != null) {
        // Merge with original data for complete info
        Book finalBook = fullBookDetails;

        if (event.originalBook != null) {
          finalBook = fullBookDetails.copyWith(
            authorName: event.originalBook!.authorName.isNotEmpty
                ? event.originalBook!.authorName
                : fullBookDetails.authorName,
            // Preserve missing fields from original
            firstPublishYear:
                fullBookDetails.firstPublishYear ??
                event.originalBook!.firstPublishYear,
            isbn: fullBookDetails.isbn?.isNotEmpty == true
                ? fullBookDetails.isbn
                : event.originalBook!.isbn,
          );
        }

        // Update saved book with complete data if needed
        if (savedBook != null) {
          if (kDebugMode) {
            debugPrint('BookDetails: Updating saved book with description');
          }
          finalBook = finalBook.copyWith(isSaved: true);
          await saveBook(finalBook); // Add missing description
        }

        emit(BookDetailsLoaded(bookDetails: finalBook));
      } else {
        // Fallback to original book if API fails
        if (event.originalBook != null) {
          emit(BookDetailsLoaded(bookDetails: event.originalBook!));
        } else {
          emit(BookDetailsError(errorMessage: 'Book not found'));
        }
      }
    } catch (error) {
      if (kDebugMode) debugPrint('BookDetails: Error - $error');
      // Show original data on error if available
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
      if (kDebugMode) debugPrint('BookDetails: Saving ${event.book.key}');
      emit(BookDetailsSaving(bookDetails: currentState.bookDetails));

      try {
        final success = await saveBook(currentState.bookDetails);
        if (success) {
          emit(
            BookDetailsLoaded(
              bookDetails: currentState.bookDetails.copyWith(isSaved: true),
            ),
          );
        } else {
          emit(BookDetailsError(errorMessage: 'Failed to save book'));
        }
      } catch (error) {
        if (kDebugMode) debugPrint('BookDetails: Save error - $error');
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
          emit(
            BookDetailsLoaded(
              bookDetails: currentState.bookDetails.copyWith(isSaved: false),
            ),
          );
        } else {
          emit(BookDetailsError(errorMessage: 'Failed to remove book'));
        }
      } catch (error) {
        emit(BookDetailsError(errorMessage: error.toString()));
      }
    }
  }
}
