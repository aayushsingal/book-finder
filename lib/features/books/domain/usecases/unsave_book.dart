import '../../../../core/usecases/usecase.dart';
import '../repositories/book_repository.dart';

class RemoveBook implements BaseUseCase<bool, String> {
  final BookRepository bookRepository;

  RemoveBook(this.bookRepository);

  @override
  Future<bool> call(String bookId) async {
    return await bookRepository.removeBook(bookId);
  }
}