# Gatodex - Organized Project Structure

## Project Structure

```
lib/
├── models/              # Data models
│   ├── cat.dart        # Cat model with all properties
│   ├── species.dart    # Species model
│   └── fur_pattern.dart # Fur pattern model
├── database/           # Database-related classes
│   ├── database_helper.dart # Database operations and setup
│   └── database_test.dart   # Test file for database functionality
├── services/           # Business logic layer
│   └── cat_service.dart # Service layer for cat operations
├── screens/            # UI screens/pages
│   └── home_page.dart  # Main home page UI
├── widgets/            # Reusable UI components
│   └── cat_card.dart   # Card widget for displaying cat info
├── utils/              # Helper functions and constants
│   ├── constants.dart  # App constants and strings
│   └── helpers.dart    # Utility functions
└── main.dart           # App entry point
```

## Key Features

### Database Structure
- **Species Table**: Predefined cat breeds
- **Fur Patterns Table**: Various fur patterns
- **Cats Table**: Main cat data with needed relationships

### Models
- **Cat**: Complete cat information with location coordinates and photo path
- **Species**: Cat breed information
- **FurPattern**: Fur pattern information

### Services
- **CatService**: Business logic layer for all cat-related operations
- Provides methods for CRUD operations, searching, and data retrieval

### Database Helper
- Singleton pattern for database management
- Automatic table creation and initial data population
- Support for complex queries with JOIN operations

### Utilities
- **Constants**: Centralized app strings and configuration
- **Helpers**: Date formatting, coordinate validation, file operations

## Usage

### Adding a New Cat
```dart
final catService = CatService();
final cat = Cat(
  id: await catService.getNextCatId(),
  name: 'Fluffy',
  speciesId: 1,
  furPatternId: 2,
  latitude: 40.7128,
  longitude: -74.0060,
  dateMet: AppHelpers.getCurrentDateString(),
  picturePath: '/path/to/photo.jpg',
);
await catService.addCat(cat);
```

### Getting All Cats
```dart
final cats = await catService.getAllCats();
```

### Searching Cats
```dart
final results = await catService.searchCats('Whiskers');
```
