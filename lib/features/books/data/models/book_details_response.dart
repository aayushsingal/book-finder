class BookDetailsResponse {
  final String key;
  final String? title;
  final dynamic description;
  final List<Map<String, dynamic>>? authors;
  final List<String>? subjects;
  final dynamic created;
  final List<int>? covers;

  const BookDetailsResponse({
    required this.key,
    this.title,
    this.description,
    this.authors,
    this.subjects,
    this.created,
    this.covers,
  });

  factory BookDetailsResponse.fromJson(Map<String, dynamic> json) {
    return BookDetailsResponse(
      key: json['key'] ?? '',
      title: json['title'] as String?,
      description: json['description'], // Can be Map or String
      authors: (json['authors'] as List<dynamic>?)
          ?.map((author) => author as Map<String, dynamic>)
          .toList(),
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((subject) => subject.toString())
          .toList(),
      created: json['created'], // Can be Map or String
      covers: (json['covers'] as List<dynamic>?)
          ?.map((cover) => cover as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'authors': authors,
      'subjects': subjects,
      'created': created,
      'covers': covers,
    };
  }

  String get descriptionText {
    if (description != null) {
      if (description is Map<String, dynamic>) {
        final Map<String, dynamic> descMap = description;
        return descMap['value']?.toString() ?? '';
      } else if (description is String) {
        return description;
      }
    }
    return '';
  }

  String get createdText {
    if (created != null) {
      if (created is Map<String, dynamic>) {
        final Map<String, dynamic> createdMap = created;
        return createdMap['value']?.toString() ?? '';
      } else if (created is String) {
        return created;
      }
    }
    return '';
  }
}