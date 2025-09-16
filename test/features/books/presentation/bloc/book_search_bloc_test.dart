import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

import 'package:book_finder_assignment_aayush/features/books/presentation/bloc/book_search/book_search_bloc.dart';

import '../../../../helpers/test_data.dart';
import '../../../../mocks/mock_use_cases.mocks.dart';

void main() {
  group('BookSearchBloc', () {
    late BookSearchBloc bloc;
    late MockSearchBooks mockSearchBooks;

    setUp(() {
      mockSearchBooks = MockSearchBooks();
      bloc = BookSearchBloc(searchBooksUseCase: mockSearchBooks);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is BookSearchInitial', () {
      expect(bloc.state, equals(BookSearchInitial()));
    });

    blocTest<BookSearchBloc, BookSearchState>(
      'search emits loading then loaded on success',
      build: () {
        when(mockSearchBooks.call(any)).thenAnswer((_) async => TestData.mockBooks);
        return bloc;
      },
      act: (bloc) => bloc.add(SearchBooksEvent('test')),
      expect: () => [
        BookSearchLoading(),
        isA<BookSearchLoaded>(),
      ],
    );

    blocTest<BookSearchBloc, BookSearchState>(
      'search emits error on failure',
      build: () {
        when(mockSearchBooks.call(any)).thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(SearchBooksEvent('test')),
      expect: () => [
        BookSearchLoading(),
        BookSearchError(errorMessage: 'Network error'),
      ],
    );

    blocTest<BookSearchBloc, BookSearchState>(
      'empty search text returns to initial state',
      build: () => bloc,
      act: (bloc) => bloc.add(SearchBooksEvent('')),
      expect: () => [BookSearchInitial()],
    );

    blocTest<BookSearchBloc, BookSearchState>(
      'no results returns empty state',
      build: () {
        when(mockSearchBooks.call(any)).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(SearchBooksEvent('xyz')),
      expect: () => [
        BookSearchLoading(),
        BookSearchEmpty(searchText: 'xyz'),
      ],
    );

    test('BookSearchLoaded state properties', () {
      final state = BookSearchLoaded(
        bookList: TestData.mockBooks,
        searchText: 'test',
        currentPage: 1,
        hasMoreBooks: false,
      );
      
      expect(state.bookList, TestData.mockBooks);
      expect(state.searchText, 'test');
      expect(state.currentPage, 1);
      expect(state.hasMoreBooks, false);
    });
  });
}