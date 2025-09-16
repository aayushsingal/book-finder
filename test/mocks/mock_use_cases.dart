import 'package:mockito/annotations.dart';

import 'package:book_finder_assignment_aayush/features/books/domain/usecases/search_books.dart';
import 'package:book_finder_assignment_aayush/features/books/domain/usecases/get_book_details.dart';
import 'package:book_finder_assignment_aayush/features/books/domain/usecases/get_saved_book_details.dart';
import 'package:book_finder_assignment_aayush/features/books/domain/usecases/save_book.dart';
import 'package:book_finder_assignment_aayush/features/books/domain/usecases/unsave_book.dart';
import 'package:book_finder_assignment_aayush/features/books/domain/usecases/get_saved_books.dart';

// Generate mocks using mockito
@GenerateMocks([
  SearchBooks,
  GetBookDetails,
  GetSavedBookDetails,
  SaveBook,
  RemoveBook,
  GetSavedBooks,
])
void main() {}