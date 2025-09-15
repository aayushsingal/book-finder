import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/usecases/get_book_details.dart';
import '../../../domain/usecases/save_book.dart';
import '../../../domain/usecases/unsave_book.dart';

part 'book_details_event.dart';
part 'book_details_state.dart';

class BookDetailsBloc extends Bloc<BookDetailsEvent, BookDetailsState> {
  final GetBookDetails getBookDetails;
  final SaveBook saveBook;
  final RemoveBook removeBook;

  BookDetailsBloc({
    required this.getBookDetails,
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
    emit(BookDetailsLoading());

    try {
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
        emit(BookDetailsError(errorMessage: 'Book not found'));
      }
    } catch (error) {
      emit(BookDetailsError(errorMessage: error.toString()));
    }
  }

  Future<void> _onSaveBook(
    SaveBookEvent event,
    Emitter<BookDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BookDetailsLoaded) {
      emit(BookDetailsSaving(bookDetails: currentState.bookDetails));

      try {
        final success = await saveBook(event.book);
        if (success) {
          emit(BookDetailsLoaded(
            bookDetails: currentState.bookDetails.copyWith(isSaved: true),
          ));
        } else {
          emit(BookDetailsError(errorMessage: 'Failed to save book'));
        }
      } catch (error) {
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