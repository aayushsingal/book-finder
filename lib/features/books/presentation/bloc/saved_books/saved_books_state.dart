part of 'saved_books_bloc.dart';

abstract class SavedBooksState extends Equatable {
  const SavedBooksState();

  @override
  List<Object> get props => [];
}

class SavedBooksInitial extends SavedBooksState {}

class SavedBooksLoading extends SavedBooksState {}

class SavedBooksLoaded extends SavedBooksState {
  final List<Book> savedBooks;

  const SavedBooksLoaded({required this.savedBooks});

  @override
  List<Object> get props => [savedBooks];
}

class SavedBooksEmpty extends SavedBooksState {}

class SavedBooksError extends SavedBooksState {
  final String errorMessage;

  const SavedBooksError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}