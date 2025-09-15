import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetBookDetails implements BaseUseCase<Book?, String> {
  final BookRepository bookRepository;

  GetBookDetails(this.bookRepository);

  @override
  Future<Book?> call(String bookId) async {
    return await bookRepository.getBookDetails(bookId);
  }
}