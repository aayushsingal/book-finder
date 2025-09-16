import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetSavedBookDetails implements BaseUseCase<Book?, String> {
  final BookRepository bookRepository;

  GetSavedBookDetails(this.bookRepository);

  @override
  Future<Book?> call(String bookId) async {
    return await bookRepository.getSavedBookDetails(bookId);
  }
}