import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class SearchBooks implements BaseUseCase<List<Book>, SearchParams> {
  final BookRepository bookRepository;

  SearchBooks(this.bookRepository);

  @override
  Future<List<Book>> call(SearchParams params) async {
    return await bookRepository.searchBooks(params.searchText, params.pageNumber);
  }
}

class SearchParams {
  final String searchText;
  final int pageNumber;

  SearchParams({required this.searchText, required this.pageNumber});
}