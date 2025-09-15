import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String key;
  final String title;
  final List<String> authorName;
  final int? coverId;
  final int? firstPublishYear;
  final List<String>? isbn;
  final String? description;
  final bool isSaved;

  const Book({
    required this.key,
    required this.title,
    required this.authorName,
    this.coverId,
    this.firstPublishYear,
    this.isbn,
    this.description,
    this.isSaved = false,
  });

  String get coverUrl {
    if (coverId != null) {
      return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }
    return '';
  }

  String get workId {
    // Extract work ID from key like "/works/OL468516W"
    return key.split('/').last;
  }

  Book copyWith({
    String? key,
    String? title,
    List<String>? authorName,
    int? coverId,
    int? firstPublishYear,
    List<String>? isbn,
    String? description,
    bool? isSaved,
  }) {
    return Book(
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

  @override
  List<Object?> get props => [
        key,
        title,
        authorName,
        coverId,
        firstPublishYear,
        isbn,
        description,
        isSaved,
      ];
}