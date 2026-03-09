import '../database/database_helper.dart';
import '../models/cat.dart';
import '../models/breed.dart';
import '../models/fur_pattern.dart';
import '../models/cat_photo.dart';

class CatService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Cat operations
  Future<int> addCat(Cat cat) async {
    return await _databaseHelper.insertCat(cat);
  }

  Future<void> addCatWithDetails(Cat cat, List<String> aliases, List<String> photoPaths) async {
    final catId = await _databaseHelper.insertCat(cat);
    if (aliases.isNotEmpty) {
      await _databaseHelper.updateAliases(catId, aliases);
    }
    if (photoPaths.isNotEmpty) {
      await _databaseHelper.updatePhotos(catId, photoPaths);
    }
  }

  Future<void> updateCatWithDetails(Cat cat, List<String> aliases, List<String> photoPaths) async {
    await _databaseHelper.updateCat(cat);
    await _databaseHelper.updateAliases(cat.id, aliases);
    await _databaseHelper.updatePhotos(cat.id, photoPaths);
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

  Future<List<Cat>> getCatsFiltered({
    int offset = 0,
    int limit = 15,
    String? searchName,
    int? breedId,
    int? furPatternId,
    String? dateFrom,
    String? dateTo,
  }) async {
    return await _databaseHelper.getCatsFiltered(
      offset: offset,
      limit: limit,
      searchName: searchName,
      breedId: breedId,
      furPatternId: furPatternId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  Future<int> getCatsFilteredCount({
    String? searchName,
    int? breedId,
    int? furPatternId,
    String? dateFrom,
    String? dateTo,
  }) async {
    return await _databaseHelper.getCatsFilteredCount(
      searchName: searchName,
      breedId: breedId,
      furPatternId: furPatternId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
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

  Future<List<Cat>> getCatsByBreed(int breedId) async {
    return await _databaseHelper.getCatsByBreed(breedId);
  }

  Future<List<Cat>> getCatsWithLocation() async {
    final allCats = await getAllCats();
    return allCats.where((cat) => cat.hasLocation).toList();
  }

  Future<List<Map<String, dynamic>>> getCatsWithDetails() async {
    return await _databaseHelper.getCatsWithDetails();
  }

  // Breed operations (formerly species)
  Future<List<Breed>> getAllBreeds() async {
    return await _databaseHelper.getBreeds();
  }

  Future<void> insertBreed(Breed breed) async {
    await _databaseHelper.insertBreed(breed);
  }

  // Fur pattern operations
  Future<List<FurPattern>> getAllFurPatterns() async {
    return await _databaseHelper.getFurPatterns();
  }

  Future<void> insertFurPattern(FurPattern furPattern) async {
    await _databaseHelper.insertFurPattern(furPattern);
  }

  // Alias operations
  Future<List<String>> getAliasesForCat(int catId) async {
    return await _databaseHelper.getAliasesForCat(catId);
  }

  Future<void> updateAliases(int catId, List<String> aliases) async {
    await _databaseHelper.updateAliases(catId, aliases);
  }

  // Photo operations
  Future<List<CatPhoto>> getPhotosForCat(int catId) async {
    return await _databaseHelper.getPhotosForCat(catId);
  }

  Future<void> addPhoto(int catId, String photoPath, int displayOrder) async {
    await _databaseHelper.insertPhoto(catId, photoPath, displayOrder);
  }

  Future<void> deletePhoto(int photoId) async {
    await _databaseHelper.deletePhoto(photoId);
  }

  Future<void> updatePhotos(int catId, List<String> photoPaths) async {
    await _databaseHelper.updatePhotos(catId, photoPaths);
  }

  Future<int> getPhotoCount(int catId) async {
    return await _databaseHelper.getPhotoCount(catId);
  }

  // Utility methods
  Future<int> getNextCatId() async {
    final cats = await getAllCats();
    if (cats.isEmpty) return 1;
    return cats.map((cat) => cat.id).reduce((max, id) => id > max ? id : max) + 1;
  }

  Future<String?> getBreedName(int breedId) async {
    final breeds = await getAllBreeds();
    final found = breeds.where((b) => b.id == breedId);
    return found.isNotEmpty ? found.first.name : null;
  }

  Future<String?> getFurPatternName(int? furPatternId) async {
    if (furPatternId == null) return null;
    final patterns = await getAllFurPatterns();
    final found = patterns.where((p) => p.id == furPatternId);
    return found.isNotEmpty ? found.first.name : null;
  }
}
