import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/usecases/get_saved_books.dart';

part 'saved_books_event.dart';
part 'saved_books_state.dart';

class SavedBooksBloc extends Bloc<SavedBooksEvent, SavedBooksState> {
  final GetSavedBooks getSavedBooks;

  SavedBooksBloc({required this.getSavedBooks}) : super(SavedBooksInitial()) {
    on<LoadSavedBooksEvent>(_onLoadSavedBooks);
    on<RefreshSavedBooksEvent>(_onRefreshSavedBooks);
  }

  Future<void> _onLoadSavedBooks(
    LoadSavedBooksEvent event,
    Emitter<SavedBooksState> emit,
  ) async {
    emit(SavedBooksLoading());

    try {
      final books = await getSavedBooks();
      if (books.isEmpty) {
        emit(SavedBooksEmpty());
      } else {
        emit(SavedBooksLoaded(savedBooks: books));
      }
    } catch (error) {
      emit(SavedBooksError(errorMessage: error.toString()));
    }
  }

  Future<void> _onRefreshSavedBooks(
    RefreshSavedBooksEvent event,
    Emitter<SavedBooksState> emit,
  ) async {
    add(LoadSavedBooksEvent());
  }
}