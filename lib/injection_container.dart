import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'core/network/network_info.dart';
import 'features/books/data/datasources/book_local_data_source.dart';
import 'features/books/data/datasources/book_remote_data_source.dart';
import 'features/books/data/repositories/book_repository_impl.dart';
import 'features/books/domain/repositories/book_repository.dart';
import 'features/books/domain/usecases/get_book_details.dart';
import 'features/books/domain/usecases/get_saved_book_details.dart';
import 'features/books/domain/usecases/get_saved_books.dart';
import 'features/books/domain/usecases/save_book.dart';
import 'features/books/domain/usecases/search_books.dart';
import 'features/books/domain/usecases/unsave_book.dart';
import 'features/books/presentation/bloc/book_search/book_search_bloc.dart';
import 'features/books/presentation/bloc/book_details/book_details_bloc.dart';
import 'features/books/presentation/bloc/saved_books/saved_books_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () => BookSearchBloc(searchBooksUseCase: sl()),
  );
  sl.registerFactory(
    () => BookDetailsBloc(
      getBookDetails: sl(),
      getSavedBookDetails: sl(),
      saveBook: sl(),
      removeBook: sl(),
    ),
  );
  sl.registerFactory(
    () => SavedBooksBloc(getSavedBooks: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchBooks(sl()));
  sl.registerLazySingleton(() => GetBookDetails(sl()));
  sl.registerLazySingleton(() => GetSavedBookDetails(sl()));
  sl.registerLazySingleton(() => GetSavedBooks(sl()));
  sl.registerLazySingleton(() => SaveBook(sl()));
  sl.registerLazySingleton(() => RemoveBook(sl()));

  // Repository
  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(
      apiService: sl(),
      databaseService: sl(),
      networkChecker: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<BookLocalDataSource>(
    () => BookLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}