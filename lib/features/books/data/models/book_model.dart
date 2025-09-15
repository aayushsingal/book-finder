import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.key,
    required super.title,
    required super.authorName,
    super.coverId,
    super.firstPublishYear,
    super.isbn,
    super.description,
    super.isSaved,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      key: json['key'] ?? '',
      title: json['title'] ?? '',
      authorName:
          (json['author_name'] as List<dynamic>?)
              ?.map((name) => name.toString())
              .toList() ??
          [],
      coverId: json['cover_i'] as int?,
      firstPublishYear: json['first_publish_year'] as int?,
      isbn:
          (json['isbn'] as List<dynamic>?)
              ?.map((isbn) => isbn.toString())
              .toList() ??
          [],
      description: json['description'] as String?,
      isSaved: json['is_saved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'author_name': authorName,
      'cover_i': coverId,
      'first_publish_year': firstPublishYear,
      'isbn': isbn,
      'description': description,
      'is_saved': isSaved,
    };
  }

  factory BookModel.fromEntity(Book book) {
    return BookModel(
      key: book.key,
      title: book.title,
      authorName: book.authorName,
      coverId: book.coverId,
      firstPublishYear: book.firstPublishYear,
      isbn: book.isbn,
      description: book.description,
      isSaved: book.isSaved,
    );
  }

  @override
  BookModel copyWith({
    String? key,
    String? title,
    List<String>? authorName,
    int? coverId,
    int? firstPublishYear,
    List<String>? isbn,
    String? description,
    bool? isSaved,
  }) {
    return BookModel(
      key: key ?? this.key,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      coverId: coverId ?? this.coverId,
      firstPublishYear: firstPublishYear ?? this.firstPublishYear,
      isbn: isbn ?? this.isbn,
      description: description ?? this.description,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
