import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'gatodex_test_database.db'),
    onCreate: (db, version) async {
      // Create species table first
      await db.execute(
        'CREATE TABLE species(id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
      );
      
      // Insert some initial species
      await db.insert('species', {'name': 'Pelo Corto Doméstico'});
      await db.insert('species', {'name': 'Pelo Largo Doméstico'});
      await db.insert('species', {'name': 'Persa'});
      await db.insert('species', {'name': 'Maine Coon'});
      await db.insert('species', {'name': 'Siamés'});
      await db.insert('species', {'name': 'Británico de Pelo Corto'});
      await db.insert('species', {'name': 'Azul Ruso'});
      await db.insert('species', {'name': 'Ragdoll'});
      await db.insert('species', {'name': 'Bengalí'});
      await db.insert('species', {'name': 'Scottish Fold'});
      
      // Create fur_patterns table
      await db.execute(
        'CREATE TABLE fur_patterns(id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
      );
      
      // Insert some initial fur patterns
      await db.insert('fur_patterns', {'name': 'Sólido'});
      await db.insert('fur_patterns', {'name': 'Atigrado'});
      await db.insert('fur_patterns', {'name': 'Carey'});
      await db.insert('fur_patterns', {'name': 'Tortuga'});
      await db.insert('fur_patterns', {'name': 'Bicolor'});
      await db.insert('fur_patterns', {'name': 'Tricolor'});
      await db.insert('fur_patterns', {'name': 'Manchado'});
      await db.insert('fur_patterns', {'name': 'Punteado'});
      await db.insert('fur_patterns', {'name': 'Colorpoint'});
      await db.insert('fur_patterns', {'name': 'Humo'});
      await db.insert('fur_patterns', {'name': 'Sombreado'});
      await db.insert('fur_patterns', {'name': 'Chinchilla'});
      
      // Create cats table with all fields
      return db.execute(
        '''CREATE TABLE cats(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          species_id INTEGER NOT NULL,
          fur_pattern_id INTEGER,
          latitude REAL,
          longitude REAL,
          date_met TEXT,
          picture_path TEXT,
          FOREIGN KEY (species_id) REFERENCES species (id),
          FOREIGN KEY (fur_pattern_id) REFERENCES fur_patterns (id)
        )''',
      );
    },
    version: 1,
  );

  Future<void> insertCat(Cat cat) async {
    final db = await database;
    await db.insert(
      'cats',
      cat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Species>> getSpecies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('species');
    return List.generate(maps.length, (i) {
      return Species(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<List<FurPattern>> getFurPatterns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fur_patterns');
    return List.generate(maps.length, (i) {
      return FurPattern(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<List<Cat>> getCats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cats');
    return List.generate(maps.length, (i) {
      return Cat(
        id: maps[i]['id'],
        name: maps[i]['name'],
        speciesId: maps[i]['species_id'],
        furPatternId: maps[i]['fur_pattern_id'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        dateMet: maps[i]['date_met'],
        picturePath: maps[i]['picture_path'],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getCatsWithDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.*,
        s.name as species_name,
        fp.name as fur_pattern_name
      FROM cats c
      LEFT JOIN species s ON c.species_id = s.id
      LEFT JOIN fur_patterns fp ON c.fur_pattern_id = fp.id
    ''');
    return maps;
  }

  // Example usage
  List<Species> availableSpecies = await getSpecies();
  print('Available species:');
  for (Species species in availableSpecies) {
    print('  ${species.id}: ${species.name}');
  }
  
  List<FurPattern> availableFurPatterns = await getFurPatterns();
  print('\nAvailable fur patterns:');
  for (FurPattern pattern in availableFurPatterns) {
    print('  ${pattern.id}: ${pattern.name}');
  }
  
  Cat exampleCat = Cat(
    id: 1,
    name: 'Whiskers',
    speciesId: 1, // Pelo Corto Doméstico
    furPatternId: 2, // Atigrado
    latitude: 40.7128, // New York City coordinates as example
    longitude: -74.0060, // (you can get these from GPS or map selection)
    dateMet: '2025-01-15',
    picturePath: '/storage/emulated/0/Pictures/whiskers.jpg', // Path to cat's photo
  );
  
  await insertCat(exampleCat);
  
  List<Cat> cats = await getCats();
  print('\nCats in database:');
  for (Cat cat in cats) {
    print('  $cat');
  }
  
  // Get cats with detailed species and fur pattern names
  List<Map<String, dynamic>> catsWithDetails = await getCatsWithDetails();
  print('\nDetailed cat information:');
  for (Map<String, dynamic> catDetail in catsWithDetails) {
    print('  ${catDetail['name']} - Species: ${catDetail['species_name']}, Fur: ${catDetail['fur_pattern_name'] ?? 'Unknown'}');
    if (catDetail['latitude'] != null && catDetail['longitude'] != null) {
      print('    Location: ${catDetail['latitude']}, ${catDetail['longitude']}');
    }
    if (catDetail['date_met'] != null) {
      print('    Met on: ${catDetail['date_met']}');
    }
  }
}

class Species {
  final int id;
  final String name;

  Species({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Species{id: $id, name: $name}';
  }
}

class FurPattern {
  final int id;
  final String name;

  FurPattern({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'FurPattern{id: $id, name: $name}';
  }
}

class Cat {
  final int id;
  final String name;
  final int speciesId;
  final int? furPatternId;
  final double? latitude;
  final double? longitude;
  final String? dateMet;
  final String? picturePath;

  Cat({
    required this.id,
    required this.name,
    required this.speciesId,
    this.furPatternId,
    this.latitude,
    this.longitude,
    this.dateMet,
    this.picturePath,
  });

  // Helper method to check if location is available
  bool get hasLocation => latitude != null && longitude != null;

  // Helper method to get coordinates as a formatted string
  String? get coordinatesString {
    if (hasLocation) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species_id': speciesId,
      'fur_pattern_id': furPatternId,
      'latitude': latitude,
      'longitude': longitude,
      'date_met': dateMet,
      'picture_path': picturePath,
    };
  }

  @override
  String toString() {
    return 'Cat{id: $id, name: $name, speciesId: $speciesId, furPatternId: $furPatternId, latitude: $latitude, longitude: $longitude, dateMet: $dateMet, picturePath: $picturePath}';
  }
}
