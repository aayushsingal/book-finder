import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetSavedBooks {
  final BookRepository bookRepository;

  GetSavedBooks(this.bookRepository);

  Future<List<Book>> call() async {
    return await bookRepository.getSavedBooks();
  }
}