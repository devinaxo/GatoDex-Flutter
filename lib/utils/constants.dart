class AppConstants {
  // Database
  static const String databaseName = 'gatodex_database.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String catsTable = 'cats';
  static const String speciesTable = 'species';
  static const String furPatternsTable = 'fur_patterns';
  
  // App name (non-translatable brand name)
  static const String appName = 'Gatodex';
  
  // Image paths
  static const String defaultCatImage = 'assets/images/default_cat.png';
  static const String placeholderImage = 'assets/images/placeholder.png';
}

class DatabaseConstants {
  // Cat table columns
  static const String catId = 'id';
  static const String catName = 'name';
  static const String catSpeciesId = 'species_id';
  static const String catFurPatternId = 'fur_pattern_id';
  static const String catLatitude = 'latitude';
  static const String catLongitude = 'longitude';
  static const String catDateMet = 'date_met';
  static const String catPicturePath = 'picture_path';
  
  // Species table columns
  static const String speciesId = 'id';
  static const String speciesName = 'name';
  
  // Fur patterns table columns
  static const String furPatternId = 'id';
  static const String furPatternName = 'name';
}
