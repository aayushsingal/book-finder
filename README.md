# Book Finder App 📚

A modern Flutter application that allows users to search for books and view detailed information using the Open Library API. Built with clean architecture principles, BLoC pattern, modern UI design, and production-ready code structure.

## Features

### Core Functionality
- **Book Search**: Real-time search functionality with the Open Library API
- **Book Details**: Comprehensive book information with animated cover images
- **Favorites Management**: Save and manage favorite books using SQLite
- **Favorites Page**: Dedicated page to view all saved books with easy access
- **Smart Save States**: Dynamic save/unsave button that reflects current status
- **Offline Support**: View saved books even without internet connection

### UI/UX Features
- **Modern White Theme**: Clean, modern app design with white background and direct styling
- **Heart-Based Favorites**: Intuitive heart icons for favorite/unfavorite actions
- **Modern Outline Buttons**: Contemporary button design with conditional styling
- **Responsive Design**: Optimized for different screen sizes and layouts
- **Shimmer Loading**: Smooth loading animations during API calls
- **Universal Pull-to-Refresh**: Refresh functionality on all screens and states
- **Infinite Scrolling**: Automatic pagination for seamless browsing
- **3D Animated Book Covers**: Interactive rotation animation on book details
- **Compact Book Cards**: Optimized grid layout with heart indicators
- **Comprehensive Error Handling**: Better error recovery with 10-second timeouts
- **Empty States**: Informative messages for all app states

### Technical Features
- **Clean Architecture**: Separation of concerns with Domain, Data, and Presentation layers
- **BLoC Pattern**: Professional state management using Flutter BLoC
- **Dependency Injection**: Service locator pattern with GetIt
- **Direct Theme-Free Styling**: Modern approach without Theme complexity
- **Enhanced Database**: SQLite with robust migration handling (v1→v3)
- **Production-Ready Logging**: Conditional debug prints for clean production builds
- **Better Error Handling**: Graceful fallbacks and timeout management
- **Network Caching**: Cached network images for optimal performance

## 📋 Requirements Met

✅ **Search Screen**
- Search bar with real-time input validation
- Grid view of book results with thumbnails
- Shimmer loading animation during API calls
- Pull-to-refresh functionality
- Infinite scrolling with pagination
- Empty state and comprehensive error handling

✅ **Details Screen**
- Animated book cover with 3D rotation
- Complete book information display
- Favorite/unfavorite functionality with local storage
- Modern outline button design with conditional styling
- Heart icons for intuitive favorite indication
- Proper visual feedback with color changes
- Smooth navigation back to search
- Loading states and comprehensive error handling

✅ **Favorites Screen**
- Dedicated page showing all saved books
- Grid layout consistent with search results
- Pull-to-refresh functionality
- Empty state with helpful guidance
- Navigation to book details with auto-refresh
- Proper error handling and retry mechanisms

✅ **Architecture**
- Simple Clean Architecture approach
- BLoC pattern for state management
- Easy-to-understand code structure

✅ **Database Integration**
- SQLite local storage for saved books
- CRUD operations for book management
- Offline data persistence

## Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or later)
- Dart SDK
- Android Studio / Xcode (for device testing)
- Internet connection (for API functionality)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd book_finder_assignment_aayush
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build Commands

- **Debug APK**: `flutter build apk --debug`
- **Release APK**: `flutter build apk --release`
- **iOS Build**: `flutter build ios --release`

## 📖 Quick Feature Guide

### Using Favorites
1. **Search for books** on the main page with modern white theme
2. **Tap any book** to view details with 3D animated cover
3. **Tap "Favorite"** button (outline style) to add to favorites (becomes red filled "Favorited")
4. **Access favorites** via the heart icon (♡) in the top-right app bar
5. **View all saved books** in the dedicated Favorites page with heart indicators
6. **Remove from favorites** by tapping "Favorited" on any book's details page

### Navigation Tips
- **Pull down** on any screen to refresh content (works in all states)
- **Scroll down** on search results for automatic pagination
- **Tap book covers** to trigger 3D rotation animation
- **Heart icons** throughout the app indicate favorite status
- **Tap the back button** or swipe to return to previous screens
- **Favorites automatically refresh** when returning from book details

## 🏗 Architecture

### Simple Architecture Structure

```
lib/
├── core/                          # Basic utilities
│   ├── network/                   # Internet connection checking
│   ├── usecases/                  # Simple base classes
│   └── utils/                     # App constants
├── features/books/                # Main book feature
│   ├── data/                      # Data handling
│   │   ├── datasources/           # API calls and local database
│   │   ├── models/                # Data structures for JSON
│   │   └── repositories/          # Data management
│   ├── domain/                    # Business rules
│   │   ├── entities/              # Book data structure
│   │   ├── repositories/          # Data contracts
│   │   └── usecases/              # App functions (search, save, etc.)
│   └── presentation/              # User interface
│       ├── bloc/                  # State management (loading, data, errors)
│       │   ├── book_search/       # Search functionality state
│       │   ├── book_details/      # Book details and save/unsave state
│       │   └── saved_books/       # Favorites page state management
│       ├── pages/                 # App screens
│       │   ├── book_search_page.dart    # Main search page with favorites icon
│       │   ├── book_details_page.dart   # Book details with dynamic save button
│       │   └── saved_books_page.dart    # Favorites/saved books page
│       └── widgets/               # Reusable UI parts
└── injection_container.dart       # Dependency setup
```

### Basic Clean Architecture Pattern

1. **Domain Layer** (Business Rules)
   - Book Entity: Represents book data
   - Use Cases: App functions like search books, save book, etc.
   - Repository Contracts: Rules for how data should be handled

2. **Data Layer** (Data Management)
   - Models: Convert JSON data to Dart objects
   - Data Sources: Get data from API and local database
   - Repository: Manages where data comes from (internet or local storage)

3. **Presentation Layer** (User Interface)
   - BLoC: State management and business logic coordination
   - Pages: Screen implementations
   - Widgets: Reusable UI components

### State Management with BLoC

- **BookSearchBloc**: Manages book search functionality and pagination
- **BookDetailsBloc**: Handles book details and save/unsave operations
- **SavedBooksBloc**: Manages locally saved books and favorites page functionality

## 📡 API Integration

### Open Library API Endpoints

1. **Search Books**: `https://openlibrary.org/search.json?title={query}&limit=20&page={page}`
2. **Book Details**: `https://openlibrary.org/works/{work_id}.json`
3. **Book Covers**: `https://covers.openlibrary.org/b/id/{cover_id}-M.jpg`

### Pagination Strategy

- 20 books per page for optimal performance
- Infinite scrolling with automatic loading
- Cached results for smooth user experience

### Error Handling

- **Enhanced Network Handling**: 10-second timeout with graceful fallbacks
- **Universal Pull-to-Refresh**: Recovery mechanism on all screens including error states
- **Smart Error Messages**: Context-aware user-friendly error messages
- **Retry Mechanisms**: Comprehensive retry functionality for failed requests
- **State Preservation**: Maintains user data during error recovery

## Database Design

### SQLite Schema

```sql
CREATE TABLE books (
    id TEXT PRIMARY KEY,                    -- Book work ID
    title TEXT NOT NULL,                    -- Book title
    author TEXT,                           -- Comma-separated authors
    cover_url TEXT,                        -- Cover image URL
    publish_year INTEGER,                  -- First publication year
    description TEXT,                      -- Book description
    is_saved INTEGER DEFAULT 1,           -- Save status (boolean)
    created_at TEXT DEFAULT CURRENT_TIMESTAMP  -- Save timestamp
);
```

### Database Operations

- **Create**: Save new books to favorites with complete metadata
- **Read**: Retrieve saved books and check favorite status
- **Update**: Modify book information and sync descriptions
- **Delete**: Remove books from favorites
- **Migration**: Robust database migration from v1 to v3 with error recovery

### Favorite Status Management

The app intelligently tracks book favorite status across different screens:

1. **Search Results**: Each book card shows heart indicator for favorited books
2. **Book Details**: Modern conditional button design reflects real-time favorite state
3. **Favorites Page**: Only shows currently favorited books with heart indicators
4. **Auto-Refresh**: Favorites list updates when books are unfavorited
5. **Visual Consistency**: Heart icons throughout app for unified favorite indication

### Technical Implementation

```dart
// Favorite status checking in repository
final isSaved = await databaseService.isBookSaved(response.key);
return BookModel(..., isSaved: isSaved);

// Modern conditional button design in UI
ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: currentBook.isSaved ? Colors.red[500] : Colors.white,
    foregroundColor: currentBook.isSaved ? Colors.white : Colors.grey[700],
    side: currentBook.isSaved ? null : BorderSide(color: Colors.grey[300]!),
  ),
  icon: Icon(currentBook.isSaved ? Icons.favorite : Icons.favorite_border),
  label: Text(currentBook.isSaved ? 'Favorited' : 'Favorite'),
)
```

## 📱 Navigation & User Flow

### Main Navigation
1. **Home Page**: Search functionality with favorites icon in top-right
2. **Book Details**: Accessible via tapping any book from search or favorites
3. **Favorites Page**: Accessible via heart icon, shows all saved books
4. **Back Navigation**: Smooth transitions between all screens

### User Journey
```
Search Page ──────┐
    │             │
    ▼             ▼
Book Details ◄── Favorites Page
    │             ▲
    └─────────────┘
```

### Interactive Elements
- **Search Bar**: Real-time search with 500ms debounce and validation
- **Book Cards**: Tappable with visual feedback and compact design
- **Favorite Button**: Modern conditional design with visual changes
  - *Unfavorited*: "Favorite" with grey outline style (OutlinedButton)
  - *Favorited*: "Favorited" with red filled background and heart icon
- **Heart Icons**: Consistent heart-based indicators throughout app
- **Pull-to-Refresh**: Universal refresh functionality on all screens and states
- **Infinite Scroll**: Automatic pagination with 200px trigger distance

## 🎨 UI/UX Design Decisions

### Design Principles
- **Modern White Theme**: Clean, minimal design with white backgrounds
- **Direct Styling**: Theme-free approach with direct color and style application
- **Heart-Based Iconography**: Consistent heart icons for favorite functionality
- **Conditional Design**: Buttons and elements adapt based on state
- **Performance**: Smooth animations and transitions with 3D effects
- **Responsiveness**: Adaptive layouts optimized for different screens
- **Consistency**: Unified design language with modern outline/filled patterns

### Color Scheme
- **Primary**: White backgrounds with clean grey accents
- **Favorites**: Red heart-based color scheme (red[50], red[500], red[600])
- **Interactive**: Grey outlines for unfavorited, red fills for favorited states
- **Text**: Black87 for primary text, grey[600-700] for secondary text
- **Error**: Red tones for error states with proper contrast

### Typography
- Clear hierarchy with appropriate font sizes
- Readable body text with proper line heights
- Bold headings for emphasis

## 🚀 Performance Optimizations

### Image Loading
- Cached network images for reduced bandwidth
- Lazy loading for better memory management
- Placeholder and error widgets for graceful degradation

### Database Performance
- Indexed queries for fast lookups
- Efficient CRUD operations
- Connection pooling and proper resource management

### Network Optimization
- **500ms Debouncing**: Prevents excessive API calls during typing
- **10-Second Timeouts**: Robust timeout handling with proper error messages
- **Graceful Degradation**: Falls back to local data when network fails
- **Smart State Management**: Preserves user experience during network issues
- **Intelligent Caching**: Cached network images for optimal performance

## 🧪 Testing Strategy

### Unit Testing
- Business logic validation
- Use case testing
- Repository implementation testing

### Widget Testing
- UI component functionality
- User interaction testing
- State management validation

### Integration Testing
- End-to-end user flows
- API integration testing
- Database operations testing

## � Recent Improvements & Modernization

### Modern UI Overhaul
- **Theme-Free Architecture**: Removed Theme.of(context) complexity for direct styling
- **Modern White Design**: Clean, contemporary white-background interface
- **Heart-Based Favorites**: Replaced save/saved terminology with favorite/favorited
- **Conditional Button Design**: Modern outline buttons for unfavorited, filled for favorited
- **3D Animations**: Enhanced book cover rotation with smooth animations

### Enhanced User Experience  
- **Universal Pull-to-Refresh**: Added pull-to-refresh on ALL screens and states
- **Better Error Recovery**: 10-second timeouts with graceful fallback to previous states
- **Compact Book Cards**: Optimized layout prevents overflow with heart indicators
- **Debounced Search**: 500ms debouncing prevents excessive API calls
- **Smart State Management**: Maintains user context during navigation and errors

### Production-Ready Code Quality
- **Conditional Debug Logging**: Used `kDebugMode` for clean production builds
- **Robust Database Migration**: Enhanced v1→v3 migration with error recovery
- **Better Exception Handling**: Graceful error handling without verbose logging
- **Clean Code**: Removed excessive debug prints while maintaining essential debugging
- **Improved Performance**: Optimized network calls and state management

### Technical Improvements
```dart
// Modern Conditional Button Design
currentBook.isSaved 
  ? ElevatedButton(/* Red filled style */)
  : ElevatedButton(/* Grey outline style */)

// Production-Ready Logging  
if (kDebugMode) debugPrint('Essential debug info only');

// Enhanced Error Handling
final response = await http.get(url).timeout(
  const Duration(seconds: 10),
  onTimeout: () => throw Exception('Request timeout'),
);
```

## �📱 Cross-Platform Discussion

### Current Implementation (Flutter)

**Advantages:**
- Single codebase for iOS and Android
- Consistent UI across platforms
- Fast development with hot reload
- Excellent performance with native compilation
- Rich ecosystem and community support

**Architecture Benefits:**
- Clean architecture easily adaptable to other platforms
- Business logic separation enables code reuse
- Dependency injection facilitates testing and maintenance

### Adaptation to Native Platforms

#### iOS (Swift/SwiftUI)
```
Architecture Adaptation:
├── Domain Layer
│   ├── Entities → Swift structs/classes
│   ├── Use Cases → Swift protocols and implementations
│   └── Repository Protocols → Swift protocols
├── Data Layer
│   ├── Models → Codable Swift structs
│   ├── API Service → URLSession/Alamofire
│   └── Local Storage → Core Data/SQLite
└── Presentation Layer
    ├── ViewModels → ObservableObject classes
    ├── Views → SwiftUI views
    └── State Management → Combine framework
```

**Key Changes:**
- Replace BLoC with Combine + ObservableObject
- Use Core Data instead of SQLite
- Implement URLSession for networking
- Utilize SwiftUI for declarative UI

#### Android (Kotlin/Compose)
```
Architecture Adaptation:
├── Domain Layer
│   ├── Entities → Kotlin data classes
│   ├── Use Cases → Kotlin interfaces and implementations
│   └── Repository Interfaces → Kotlin interfaces
├── Data Layer
│   ├── Models → Kotlin data classes with serialization
│   ├── API Service → Retrofit + OkHttp
│   └── Local Storage → Room database
└── Presentation Layer
    ├── ViewModels → Android ViewModel with LiveData/StateFlow
    ├── Composables → Jetpack Compose functions
    └── State Management → StateFlow + Compose state
```

**Key Changes:**
- Replace BLoC with Android ViewModel
- Use Room instead of raw SQLite
- Implement Retrofit for networking
- Utilize Jetpack Compose for modern UI

### Migration Strategy

1. **Business Logic Preservation**
   - Keep use cases and entities identical
   - Maintain repository interfaces
   - Preserve validation and business rules

2. **Platform-Specific Adaptations**
   - Replace state management framework
   - Adapt to platform-specific storage solutions
   - Implement platform-native networking libraries
   - Use platform-specific UI frameworks

3. **Shared Components**
   - API contracts and data models
   - Business validation logic
   - Database schema design
   - Error handling strategies

## 🔧 Known Limitations & Future Enhancements

### Current Limitations
- Offline functionality limited to favorited books only
- Search focused on title/general queries
- No user authentication or cloud sync
- Limited book metadata from Open Library API

### Potential Improvements
- **Enhanced Search**: Author, ISBN, genre-based filtering
- **User Accounts**: Cloud sync for favorites across devices
- **Multiple Lists**: Reading lists, wish lists, completed books
- **Book Reviews**: User ratings and community reviews
- **Advanced Filters**: Publication year, language, rating filters
- **AI Recommendations**: Smart book suggestions based on favorites
- **Social Features**: Share books and reading progress
- **Theme Options**: Dark mode and customizable color schemes
- **Reading Progress**: Track reading status and progress

### Technical Improvements Made
- ✅ **Production Logging**: Conditional debug prints with kDebugMode
- ✅ **Modern UI**: Theme-free direct styling approach
- ✅ **Enhanced Error Handling**: 10-second timeouts and graceful fallbacks  
- ✅ **Universal Pull-to-Refresh**: Works on all screens and states
- ✅ **Database Migration**: Robust v1→v3 migration with error recovery
- ✅ **Modern Button Design**: Conditional outline/filled button patterns

### Future Technical Enhancements
- Add comprehensive unit and widget tests
- Implement offline search caching
- Add analytics and performance monitoring
- Enhanced accessibility features
- Deep linking and navigation improvements
- Advanced state persistence

## 📄 Dependencies

### Core Dependencies
- **flutter_bloc** (^8.1.3): State management
- **get_it** (^7.6.4): Dependency injection
- **dartz** (^0.10.1): Functional programming utilities

### Network & Data
- **http** (^1.1.0): HTTP client for API calls
- **sqflite** (^2.3.0): SQLite database
- **connectivity_plus** (^5.0.1): Network connectivity

### UI & UX
- **cached_network_image** (^3.3.0): Image caching
- **shimmer** (^3.0.0): Loading animations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support and questions:
- Create an issue in the repository
- Review the documentation
- Check existing issues for similar problems

---

**Built with ❤️ using Flutter**
