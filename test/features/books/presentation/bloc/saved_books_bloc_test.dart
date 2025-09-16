import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

import 'package:book_finder_assignment_aayush/features/books/presentation/bloc/saved_books/saved_books_bloc.dart';

import '../../../../helpers/test_data.dart';
import '../../../../mocks/mock_use_cases.mocks.dart';

void main() {
  group('SavedBooksBloc', () {
    late SavedBooksBloc bloc;
    late MockGetSavedBooks mockGetSavedBooks;

    setUp(() {
      mockGetSavedBooks = MockGetSavedBooks();
      bloc = SavedBooksBloc(getSavedBooks: mockGetSavedBooks);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is SavedBooksInitial', () {
      expect(bloc.state, equals(SavedBooksInitial()));
    });

    blocTest<SavedBooksBloc, SavedBooksState>(
      'loads saved books successfully',
      build: () {
        when(mockGetSavedBooks.call()).thenAnswer((_) async => TestData.mockSavedBooks);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSavedBooksEvent()),
      expect: () => [
        SavedBooksLoading(),
        isA<SavedBooksLoaded>(),
      ],
    );

    blocTest<SavedBooksBloc, SavedBooksState>(
      'handles load error',
      build: () {
        when(mockGetSavedBooks.call()).thenThrow(Exception('Database error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSavedBooksEvent()),
      expect: () => [
        SavedBooksLoading(),
        SavedBooksError(errorMessage: 'Exception: Database error'),
      ],
    );

    blocTest<SavedBooksBloc, SavedBooksState>(
      'shows empty state when no saved books',
      build: () {
        when(mockGetSavedBooks.call()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSavedBooksEvent()),
      expect: () => [
        SavedBooksLoading(),
        SavedBooksEmpty(),
      ],
    );

    test('SavedBooksLoaded state contains books', () {
      final state = SavedBooksLoaded(savedBooks: TestData.mockSavedBooks);
      expect(state.savedBooks, TestData.mockSavedBooks);
    });

    test('SavedBooksError state contains message', () {
      const state = SavedBooksError(errorMessage: 'Error occurred');
      expect(state.errorMessage, 'Error occurred');
    });
  });
}