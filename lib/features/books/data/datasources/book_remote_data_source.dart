import 'dart:convert';

import 'package:flutter/foundation.dart';
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

      debugPrint('Making search API call to: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        debugPrint('Search API response received');
        final data = json.decode(response.body);
        // Check what keys we are getting from the response
        final docs = data['docs'] as List?;
        if (docs != null && docs.isNotEmpty) {
          debugPrint('First book key: ${docs[0]['key']}');
        }
        return BookSearchResponse.fromJson(data);
      } else {
        throw ServerException();
      }
    } catch (e) {
      debugPrint('Error in searchBooks: $e');
      throw ServerException();
    }
  }

  @override
  Future<BookDetailsResponse> getBookDetails(String workId) async {
    try {
      final url = Uri.parse('$baseUrl/works/$workId.json');
      
      debugPrint('Making book details API call to: $url');
      debugPrint('Work ID: $workId');
      
      final response = await http.get(url);
      
      debugPrint('Book details status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Book details API response received');
        final data = json.decode(response.body);
        return BookDetailsResponse.fromJson(data);
      } else {
        debugPrint('Book details API failed with status: ${response.statusCode}');
        throw ServerException();
      }
    } catch (e) {
      debugPrint('Error getting book details: $e');
      throw ServerException();
    }
  }
}
