class Constants {
  // API URLs
  static const String baseUrl = 'https://openlibrary.org';
  static const String searchUrl = '$baseUrl/search.json';
  static const String workUrl = '$baseUrl/works';
  static const String coverUrl = 'https://covers.openlibrary.org/b/id';
  
  // Pagination
  static const int booksPerPage = 20;
  
  // Database
  static const String databaseName = 'books.db';
  static const int databaseVersion = 1;
  
  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String serverError = 'Server error. Please try again later.';
  static const String cacheError = 'Local storage error. Please try again.';
  static const String noResultsError = 'No books found for your search.';
  static const String searchEmptyError = 'Please enter a search term.';
  
  // UI Messages
  static const String searchHint = 'Search for books...';
  static const String retryButtonText = 'Retry';
  static const String saveButtonText = 'Save Book';
  static const String savedButtonText = 'Saved';
  
  // Animation durations
  static const Duration rotationDuration = Duration(seconds: 2);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
}