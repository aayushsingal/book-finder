part of 'book_search_bloc.dart';

abstract class BookSearchEvent extends Equatable {
  const BookSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchBooksEvent extends BookSearchEvent {
  final String searchText;

  const SearchBooksEvent(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class LoadMoreBooksEvent extends BookSearchEvent {
  const LoadMoreBooksEvent();
}

class RefreshBooksEvent extends BookSearchEvent {
  const RefreshBooksEvent();
}

class LoadPopularBooksEvent extends BookSearchEvent {
  const LoadPopularBooksEvent();
}