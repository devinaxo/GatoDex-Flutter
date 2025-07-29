import '../database/database_helper.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';

class CatService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Cat operations
  Future<void> addCat(Cat cat) async {
    await _databaseHelper.insertCat(cat);
  }

  Future<List<Cat>> getAllCats() async {
    return await _databaseHelper.getCats();
  }

  Future<List<Cat>> getCatsPaginated({int offset = 0, int limit = 15}) async {
    return await _databaseHelper.getCatsPaginated(offset: offset, limit: limit);
  }

  Future<int> getCatsCount() async {
    return await _databaseHelper.getCatsCount();
  }

  Future<Cat?> getCatById(int id) async {
    return await _databaseHelper.getCat(id);
  }

  Future<void> updateCat(Cat cat) async {
    await _databaseHelper.updateCat(cat);
  }

  Future<void> deleteCat(int id) async {
    await _databaseHelper.deleteCat(id);
  }

  Future<List<Cat>> searchCats(String name) async {
    return await _databaseHelper.searchCatsByName(name);
  }

  Future<List<Cat>> getCatsBySpecies(int speciesId) async {
    return await _databaseHelper.getCatsBySpecies(speciesId);
  }

  Future<List<Map<String, dynamic>>> getCatsWithDetails() async {
    return await _databaseHelper.getCatsWithDetails();
  }

  // Species operations
  Future<List<Species>> getAllSpecies() async {
    return await _databaseHelper.getSpecies();
  }

  Future<void> insertSpecies(Species species) async {
    await _databaseHelper.insertSpecies(species);
  }

  // Fur pattern operations
  Future<List<FurPattern>> getAllFurPatterns() async {
    return await _databaseHelper.getFurPatterns();
  }

  Future<void> insertFurPattern(FurPattern furPattern) async {
    await _databaseHelper.insertFurPattern(furPattern);
  }

  // Utility methods
  Future<int> getNextCatId() async {
    final cats = await getAllCats();
    if (cats.isEmpty) return 1;
    return cats.map((cat) => cat.id).reduce((max, id) => id > max ? id : max) + 1;
  }

  Future<String?> getSpeciesName(int speciesId) async {
    final species = await getAllSpecies();
    final found = species.where((s) => s.id == speciesId);
    return found.isNotEmpty ? found.first.name : null;
  }

  Future<String?> getFurPatternName(int? furPatternId) async {
    if (furPatternId == null) return null;
    final patterns = await getAllFurPatterns();
    final found = patterns.where((p) => p.id == furPatternId);
    return found.isNotEmpty ? found.first.name : null;
  }
}
