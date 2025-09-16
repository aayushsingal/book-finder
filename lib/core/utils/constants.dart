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
  
  // App Titles and Navigation
  static const String appTitle = 'Book Finder';
  static const String bookDetailsTitle = 'Book Details';
  static const String favoritesTitle = 'Favorites';

  // Search and Input
  static const String searchHint = 'Search for books... (e.g. "harry potter")';
  static const String searchPlaceholder = 'Search for books...';

  // Button Labels
  static const String retryButtonText = 'RETRY';
  static const String tryAgainButtonText = 'Try Again';
  static const String saveButtonText = 'Save Book';
  static const String savedButtonText = 'Saved';
  
  // Tooltips
  static const String favoritesTooltip = 'Favorites';
  static const String refreshTooltip = 'Refresh';

  // Empty States
  static const String discoverBooksTitle = 'Discover Amazing Books';
  static const String discoverBooksSubtitle =
      'Search for your favorite books by title or author\n\nTry searching for "Harry Potter" or "Lord of the Rings"';
  static const String noFavoritesTitle = 'No Favorites Yet';
  static const String noFavoritesSubtitle =
      'Start building your library by saving books you love!\n\nTap the bookmark icon on any book\'s details page to add it here.';
  static const String noSearchResultsSubtitle =
      'Try searching with different keywords or check your spelling';

  // Error Messages for UI
  static const String searchFailedPrefix = 'Search failed: ';

  // Book Information Labels
  static const String publishedLabel = 'Published: ';
  static const String authorPrefix = 'by ';
  static const String descriptionLabel = 'Description';
  static const String additionalInfoLabel = 'Additional Information';
  static const String isbnLabel = 'ISBN';
  static const String workIdLabel = 'Work ID';
  static const String noCoverText = 'No Cover';

  // Default Values
  static const String unknownTitle = 'Unknown Title';
  
  // Animation durations
  static const Duration rotationDuration = Duration(seconds: 2);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
}