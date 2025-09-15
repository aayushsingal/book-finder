import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class SaveBook implements BaseUseCase<bool, Book> {
  final BookRepository bookRepository;

  SaveBook(this.bookRepository);

  @override
  Future<bool> call(Book book) async {
    return await bookRepository.saveBook(book);
  }
}