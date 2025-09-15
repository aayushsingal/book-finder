import 'book_model.dart';

class BookSearchResponse {
  final List<BookModel> docs;
  final int numFound;
  final int start;

  const BookSearchResponse({
    required this.docs,
    required this.numFound,
    required this.start,
  });

  factory BookSearchResponse.fromJson(Map<String, dynamic> json) {
    return BookSearchResponse(
      docs: (json['docs'] as List<dynamic>?)
              ?.map((doc) => BookModel.fromJson(doc as Map<String, dynamic>))
              .toList() ??
          [],
      numFound: json['numFound'] ?? 0,
      start: json['start'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docs': docs.map((doc) => doc.toJson()).toList(),
      'numFound': numFound,
      'start': start,
    };
  }
}