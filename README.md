# Book Finder App 📚

A Flutter application for searching books using the Open Library API. Features search, book details, and favorites functionality with clean architecture and BLoC pattern.

## Features

- **Book Search**: Search books with real-time results
- **Book Details**: View detailed book information  
- **Favorites**: Save and manage favorite books locally
- **Modern UI**: Clean design with animations and responsive layout
- **Offline Support**: View saved books without internet

## Requirements Met

✅ **Search Screen** - Search bar, grid results, loading states  
✅ **Details Screen** - Book info, favorite button, animations  
✅ **Favorites Screen** - Saved books list, empty states  
✅ **Architecture** - Clean Architecture with BLoC pattern  
✅ **Database** - SQLite for local storage  

## Setup

### Prerequisites
- Flutter SDK (3.8.1+)
- Internet connection for API

### Installation
```bash
git clone <repository-url>
cd book_finder_assignment_aayush
flutter pub get
flutter run
```

## Architecture

```
lib/
├── core/                    # Utilities and base classes
├── features/books/
│   ├── data/               # API and database
│   ├── domain/             # Business logic
│   └── presentation/       # UI and BLoC
└── injection_container.dart # Dependencies
```

**Clean Architecture Layers:**
- **Domain**: Business rules and entities
- **Data**: API calls and local storage  
- **Presentation**: UI screens and state management

## API Integration

Uses Open Library API:
- Search: `https://openlibrary.org/search.json`
- Details: `https://openlibrary.org/works/{id}.json`
- Covers: `https://covers.openlibrary.org/b/id/{id}-M.jpg`

## Database

SQLite database stores favorite books with:
- Book ID, title, authors
- Cover URL, description
- Publication year, save status

## App Flow

Simple user journey through the app:

```
    Search/Home Page
    ┌─────────────────┐
    │                 │
    ▼                 ▼
Book Details    Favorites Page
    │                 │
    │                 │
    └─────────┬───────┘
              ▼
    Search/Home Page
```

**How to use:**
1. **Search** for books on the main screen
2. **Tap any book** to view detailed information
3. **Tap "Favorite"** to save books locally
4. **Access favorites** via the heart icon in top-right
5. **View saved books** anytime, even offline
6. **Return to search** from both details and favorites pages

## Testing

Simple test suite covering:
- **BLoC Tests**: State management logic
- **Widget Tests**: UI functionality
- **Mock Data**: Fake API responses

Run tests: `flutter test`

## Dependencies

**Core**: flutter_bloc, get_it, dartz  
**Network**: http, connectivity_plus  
**Database**: sqflite  
**UI**: cached_network_image, shimmer  

---

**Made with ❤️ using Flutter**