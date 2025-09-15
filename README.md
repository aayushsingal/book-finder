# Book Finder App 📚

A simple Flutter application that allows users to search for books and view detailed information using the Open Library API. Built with basic clean architecture principles, BLoC pattern, and easy-to-understand code structure for interview purposes.

## 🚀 Features

### Core Functionality
- **Book Search**: Real-time search functionality with the Open Library API
- **Book Details**: Comprehensive book information with animated cover images
- **Local Storage**: Save and manage favorite books using SQLite
- **Offline Support**: View saved books even without internet connection

### UI/UX Features
- **Responsive Design**: Optimized for different screen sizes
- **Shimmer Loading**: Smooth loading animations during API calls
- **Pull-to-Refresh**: Refresh search results with pull gesture
- **Infinite Scrolling**: Automatic pagination for seamless browsing
- **Animated Book Covers**: Interactive 3D rotation animation on book details
- **Error Handling**: Comprehensive error states with retry functionality
- **Empty States**: Informative messages for empty search results

### Technical Features
- **Clean Architecture**: Separation of concerns with Domain, Data, and Presentation layers
- **BLoC Pattern**: State management using Flutter BLoC
- **Dependency Injection**: Service locator pattern with GetIt
- **Network Caching**: Cached network images for better performance
- **Database**: Local SQLite database for offline book storage
- **Simple JSON Handling**: Direct JSON parsing using dart:convert

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
- Save/unsave functionality with local storage
- Smooth navigation back to search
- Loading states and error handling

✅ **Architecture**
- Simple Clean Architecture approach
- BLoC pattern for state management
- Easy-to-understand code structure

✅ **Database Integration**
- SQLite local storage for saved books
- CRUD operations for book management
- Offline data persistence

## 🛠 Setup Instructions

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
│       ├── pages/                 # App screens
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
- **SavedBooksBloc**: Manages locally saved books

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

- Network connectivity checks
- Graceful fallback to cached data
- User-friendly error messages
- Retry mechanisms for failed requests

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

- **Create**: Save new books to favorites
- **Read**: Retrieve saved books and check save status
- **Update**: Modify book information
- **Delete**: Remove books from favorites

## 🎨 UI/UX Design Decisions

### Design Principles
- **Material Design 3**: Modern, clean aesthetic
- **Accessibility**: High contrast, readable fonts
- **Performance**: Smooth animations and transitions
- **Responsiveness**: Adaptive layouts for different screens

### Color Scheme
- Primary: Blue-based color palette
- Accent: Complementary colors for actions
- Error: Red tones for error states
- Success: Green tones for positive feedback

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
- Request debouncing to prevent excessive API calls
- Intelligent caching strategies
- Connection timeout handling

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

## 📱 Cross-Platform Discussion

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
- Limited offline functionality (saved books only)
- Basic search (title-based only)
- No user authentication
- Limited book metadata available from API

### Potential Improvements
- **Enhanced Search**: Author, ISBN, genre-based search
- **User Accounts**: Cloud sync for saved books
- **Reading Lists**: Multiple categorized lists
- **Book Reviews**: User ratings and reviews
- **Advanced Filters**: Publication year, language, etc.
- **Recommendations**: AI-powered book suggestions
- **Social Features**: Share books with friends
- **Dark Mode**: Theme customization options

### Technical Debt
- Add comprehensive unit and widget tests
- Implement offline search caching
- Add analytics and crash reporting
- Optimize image caching strategies
- Add accessibility improvements
- Implement deep linking

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

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
