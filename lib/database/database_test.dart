import 'package:flutter/widgets.dart';
import '../services/cat_service.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';
import '../utils/helpers.dart';

/// Demo file to test the new database structure and services
/// This replaces the old db_test.dart functionality
void testDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final catService = CatService();
  
  print('=== Gatodex Database Test ===\n');
  
  // Test getting species
  print('Available species:');
  List<Species> availableSpecies = await catService.getAllSpecies();
  for (Species species in availableSpecies) {
    print('  ${species.id}: ${species.name}');
  }
  
  // Test getting fur patterns
  print('\nAvailable fur patterns:');
  List<FurPattern> availableFurPatterns = await catService.getAllFurPatterns();
  for (FurPattern pattern in availableFurPatterns) {
    print('  ${pattern.id}: ${pattern.name}');
  }
  
  // Test adding a cat
  print('\n=== Adding example cat ===');
  Cat exampleCat = Cat(
    id: await catService.getNextCatId(),
    name: 'Whiskers',
    speciesId: 1, // Pelo Corto Doméstico
    furPatternId: 2, // Atigrado
    latitude: 40.7128, // New York City coordinates as example
    longitude: -74.0060, // (you can get these from GPS or map selection)
    dateMet: AppHelpers.getCurrentDateString(),
    picturePath: '/storage/emulated/0/Pictures/whiskers.jpg', // Path to cat's photo
  );
  
  await catService.addCat(exampleCat);
  print('Cat "${exampleCat.name}" added successfully!');
  
  // Test getting all cats
  print('\n=== All cats in database ===');
  List<Cat> cats = await catService.getAllCats();
  for (Cat cat in cats) {
    print('  $cat');
  }
  
  // Test getting cats with details
  print('\n=== Detailed cat information ===');
  List<Map<String, dynamic>> catsWithDetails = await catService.getCatsWithDetails();
  for (Map<String, dynamic> catDetail in catsWithDetails) {
    String speciesName = catDetail['species_name'] ?? 'Unknown';
    String furPatternName = catDetail['fur_pattern_name'] ?? 'Unknown';
    
    print('  ${catDetail['name']} - Species: $speciesName, Fur: $furPatternName');
    
    if (catDetail['latitude'] != null && catDetail['longitude'] != null) {
      String location = AppHelpers.formatCoordinates(
        catDetail['latitude'], 
        catDetail['longitude']
      );
      print('    Location: $location');
    }
    
    if (catDetail['date_met'] != null) {
      String formattedDate = AppHelpers.formatDate(catDetail['date_met']);
      print('    Met on: $formattedDate');
    }
    
    print(''); // Empty line for readability
  }
  
  print('=== Database test completed ===');
}
