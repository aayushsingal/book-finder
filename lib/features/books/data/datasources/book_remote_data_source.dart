import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/book_search_response.dart';
import '../models/book_details_response.dart';

abstract class BookRemoteDataSource {
  Future<BookSearchResponse> searchBooks(String query, int page);
  Future<BookDetailsResponse> getBookDetails(String workId);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final http.Client client;

  BookRemoteDataSourceImpl({required this.client});

  static const String baseUrl = 'https://openlibrary.org';
  static const int _booksPerPage = 20;

  @override
  Future<BookSearchResponse> searchBooks(String query, int page) async {
    try {
      final url = Uri.parse(
        '$baseUrl/search.json?q=$query&page=$page&limit=$_booksPerPage',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
              'Request timeout. Please check your internet connection.',
            ),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BookSearchResponse.fromJson(data);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<BookDetailsResponse> getBookDetails(String workId) async {
    try {
      final url = Uri.parse('$baseUrl/works/$workId.json');
      
      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
              'Request timeout. Please check your internet connection.',
            ),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BookDetailsResponse.fromJson(data);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
