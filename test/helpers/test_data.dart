import 'package:book_finder_assignment_aayush/features/books/domain/entities/book.dart';

class TestData {
  // Sample books for testing
  static final List<Book> mockBooks = [
    Book(
      key: '/works/OL45883W',
      title: 'Harry Potter',
      authorName: ['J.K. Rowling'],
      coverId: 123456,
      firstPublishYear: 1997,
      description: 'A wizard story.',
    ),
    Book(
      key: '/works/OL82563W',
      title: 'To Kill a Mockingbird',
      authorName: ['Harper Lee'],
      coverId: 789012,
      firstPublishYear: 1960,
      description: 'A classic novel.',
    ),
  ];

  //  test book with details
  static final Book mockBookDetails = mockBooks.first;

  //  saved book
  static final Book mockSavedBook = mockBooks.first.copyWith(isSaved: true);

  // List of saved books
  static final List<Book> mockSavedBooks = [mockSavedBook];

  // Test constants
  static const String searchText = 'Harry Potter';
  static const String bookWorkId = 'OL45883W';
  static const String bookId = '/works/OL45883W';
}