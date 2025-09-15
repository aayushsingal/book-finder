part of 'saved_books_bloc.dart';

abstract class SavedBooksEvent extends Equatable {
  const SavedBooksEvent();

  @override
  List<Object> get props => [];
}

class LoadSavedBooksEvent extends SavedBooksEvent {
  const LoadSavedBooksEvent();
}

class RefreshSavedBooksEvent extends SavedBooksEvent {
  const RefreshSavedBooksEvent();
}