class AppConstants {
  // Database
  static const String databaseName = 'gatodex_database.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String catsTable = 'cats';
  static const String speciesTable = 'species';
  static const String furPatternsTable = 'fur_patterns';
  
  // App strings
  static const String appName = 'Gatodex';
  static const String noCatsFound = 'No se encontraron gatos';
  static const String addCat = 'Agregar Gato';
  static const String editCat = 'Editar Gato';
  static const String deleteCat = 'Eliminar Gato';
  static const String catName = 'Nombre del Gato';
  static const String species = 'Especie';
  static const String furPattern = 'Patrón de Pelaje';
  static const String location = 'Ubicación';
  static const String dateMet = 'Fecha de Encuentro';
  static const String picture = 'Foto';
  
  // Default values
  static const String unknownSpecies = 'Especie Desconocida';
  static const String unknownFurPattern = 'Patrón Desconocido';
  static const String noLocation = 'Sin Ubicación';
  static const String noDate = 'Fecha Desconocida';
  
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
