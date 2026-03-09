class AppConstants {
  // Database
  static const String databaseName = 'gatodex_database.db';
  static const int databaseVersion = 2;
  
  // Table names
  static const String catsTable = 'cats';
  static const String breedsTable = 'breeds';
  static const String furPatternsTable = 'fur_patterns';
  static const String catAliasesTable = 'cat_aliases';
  static const String catPhotosTable = 'cat_photos';
  
  // App name (non-translatable brand name)
  static const String appName = 'Gatodex';
  
  // Image paths
  static const String defaultCatImage = 'assets/images/default_cat.png';
  static const String placeholderImage = 'assets/images/placeholder.png';

  // Photo limits
  static const int maxPhotosPerCat = 5;
}

class DatabaseConstants {
  // Cat table columns
  static const String catId = 'id';
  static const String catName = 'name';
  static const String catBreedId = 'breed_id';
  static const String catFurPatternId = 'fur_pattern_id';
  static const String catLatitude = 'latitude';
  static const String catLongitude = 'longitude';
  static const String catDateMet = 'date_met';
  
  // Breed table columns
  static const String breedId = 'id';
  static const String breedName = 'name';
  static const String breedNameKey = 'name_key';
  
  // Fur patterns table columns
  static const String furPatternId = 'id';
  static const String furPatternName = 'name';
  static const String furPatternNameKey = 'name_key';

  // Cat aliases table columns
  static const String aliasId = 'id';
  static const String aliasCatId = 'cat_id';
  static const String aliasName = 'alias';
  static const String aliasDisplayOrder = 'display_order';

  // Cat photos table columns
  static const String photoId = 'id';
  static const String photoCatId = 'cat_id';
  static const String photoPath = 'photo_path';
  static const String photoDisplayOrder = 'display_order';
  static const String photoCreatedAt = 'created_at';
}
