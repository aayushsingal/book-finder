part of 'book_search_bloc.dart';

abstract class BookSearchState extends Equatable {
  const BookSearchState();

  @override
  List<Object> get props => [];
}

class BookSearchInitial extends BookSearchState {}

class BookSearchLoading extends BookSearchState {}

class BookSearchLoadingMore extends BookSearchState {
  final List<Book> bookList;
  final String searchText;
  final int currentPage;

  const BookSearchLoadingMore({
    required this.bookList,
    required this.searchText,
    required this.currentPage,
  });

  @override
  List<Object> get props => [bookList, searchText, currentPage];
}

class BookSearchLoaded extends BookSearchState {
  final List<Book> bookList;
  final String searchText;
  final int currentPage;
  final bool hasMoreBooks;

  const BookSearchLoaded({
    required this.bookList,
    required this.searchText,
    required this.currentPage,
    this.hasMoreBooks = false,
  });

  @override
  List<Object> get props => [bookList, searchText, currentPage, hasMoreBooks];
}

class BookSearchError extends BookSearchState {
  final String errorMessage;

  const BookSearchError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class BookSearchEmpty extends BookSearchState {
  final String searchText;

  const BookSearchEmpty({required this.searchText});

  @override
  List<Object> get props => [searchText];
}