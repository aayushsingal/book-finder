import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

import 'package:book_finder_assignment_aayush/features/books/presentation/bloc/book_details/book_details_bloc.dart';

import '../../../../helpers/test_data.dart';
import '../../../../mocks/mock_use_cases.mocks.dart';

void main() {
  group('BookDetailsBloc', () {
    late BookDetailsBloc bloc;
    late MockGetBookDetails mockGetBookDetails;
    late MockGetSavedBookDetails mockGetSavedBookDetails;
    late MockSaveBook mockSaveBook;
    late MockRemoveBook mockRemoveBook;

    setUp(() {
      mockGetBookDetails = MockGetBookDetails();
      mockGetSavedBookDetails = MockGetSavedBookDetails();
      mockSaveBook = MockSaveBook();
      mockRemoveBook = MockRemoveBook();
      
      when(mockGetSavedBookDetails.call(any)).thenAnswer((_) async => null);
      
      bloc = BookDetailsBloc(
        getBookDetails: mockGetBookDetails,
        getSavedBookDetails: mockGetSavedBookDetails,
        saveBook: mockSaveBook,
        removeBook: mockRemoveBook,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is BookDetailsInitial', () {
      expect(bloc.state, equals(BookDetailsInitial()));
    });

    blocTest<BookDetailsBloc, BookDetailsState>(
      'loads book details successfully',
      build: () {
        when(mockGetBookDetails.call(any)).thenAnswer((_) async => TestData.mockBookDetails);
        return bloc;
      },
      act: (bloc) => bloc.add(GetBookDetailsEvent(
        workId: 'test_id',
        originalBook: TestData.mockBooks.first,
      )),
      expect: () => [
        BookDetailsLoading(),
        isA<BookDetailsLoaded>(),
      ],
    );

    blocTest<BookDetailsBloc, BookDetailsState>(
      'saves book successfully',
      build: () {
        when(mockSaveBook.call(any)).thenAnswer((_) async => true);
        return bloc;
      },
      seed: () => BookDetailsLoaded(bookDetails: TestData.mockBookDetails),
      act: (bloc) => bloc.add(SaveBookEvent(book: TestData.mockBookDetails)),
      expect: () => [
        isA<BookDetailsSaving>(),
        isA<BookDetailsLoaded>(),
      ],
    );

    blocTest<BookDetailsBloc, BookDetailsState>(
      'unsaves book successfully',
      build: () {
        when(mockRemoveBook.call(any)).thenAnswer((_) async => true);
        return bloc;
      },
      seed: () => BookDetailsLoaded(bookDetails: TestData.mockSavedBook),
      act: (bloc) => bloc.add(UnsaveBookEvent(bookKey: 'test_id')),
      expect: () => [
        isA<BookDetailsSaving>(),
        isA<BookDetailsLoaded>(),
      ],
    );

    test('BookDetailsLoaded state contains book', () {
      final state = BookDetailsLoaded(bookDetails: TestData.mockBookDetails);
      expect(state.bookDetails, TestData.mockBookDetails);
    });

    test('BookDetailsError state contains message', () {
      const state = BookDetailsError(errorMessage: 'Error occurred');
      expect(state.errorMessage, 'Error occurred');
    });
  });
}