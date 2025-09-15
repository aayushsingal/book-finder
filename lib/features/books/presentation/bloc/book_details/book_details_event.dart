part of 'book_details_bloc.dart';

abstract class BookDetailsEvent extends Equatable {
  const BookDetailsEvent();

  @override
  List<Object> get props => [];
}

class GetBookDetailsEvent extends BookDetailsEvent {
  final String workId;
  final Book? originalBook; // Original book from search results

  const GetBookDetailsEvent({required this.workId, this.originalBook});

  @override
  List<Object> get props => [workId, originalBook ?? ''];
}

class SaveBookEvent extends BookDetailsEvent {
  final Book book;

  const SaveBookEvent({required this.book});

  @override
  List<Object> get props => [book];
}

class UnsaveBookEvent extends BookDetailsEvent {
  final String bookKey;

  const UnsaveBookEvent({required this.bookKey});

  @override
  List<Object> get props => [bookKey];
}