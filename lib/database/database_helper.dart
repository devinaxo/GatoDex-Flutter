import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'gatodex_database.db'),
      onCreate: (db, version) async {
        // Create species table first
        await db.execute(
          'CREATE TABLE species(id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
        );
        
        // Insert initial species data
        await _insertInitialSpecies(db);
        
        // Create fur_patterns table
        await db.execute(
          'CREATE TABLE fur_patterns(id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
        );
        
        // Insert initial fur patterns data
        await _insertInitialFurPatterns(db);
        
        // Create cats table with all fields
        await db.execute(
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
  }

  Future<void> _insertInitialSpecies(Database db) async {
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
  }

  Future<void> _insertInitialFurPatterns(Database db) async {
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
  }

  // CRUD Operations for Cats
  Future<void> insertCat(Cat cat) async {
    final db = await database;
    await db.insert(
      'cats',
      cat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Cat>> getCats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cats');
    return List.generate(maps.length, (i) {
      return Cat.fromMap(maps[i]);
    });
  }

  Future<Cat?> getCat(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cats',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Cat.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateCat(Cat cat) async {
    final db = await database;
    await db.update(
      'cats',
      cat.toMap(),
      where: 'id = ?',
      whereArgs: [cat.id],
    );
  }

  Future<void> deleteCat(int id) async {
    final db = await database;
    await db.delete(
      'cats',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Operations for Species
  Future<List<Species>> getSpecies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('species');
    return List.generate(maps.length, (i) {
      return Species.fromMap(maps[i]);
    });
  }

  // Operations for Fur Patterns
  Future<List<FurPattern>> getFurPatterns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fur_patterns');
    return List.generate(maps.length, (i) {
      return FurPattern.fromMap(maps[i]);
    });
  }

  // Advanced query to get cats with details
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

  // Search cats by name
  Future<List<Cat>> searchCatsByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cats',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return List.generate(maps.length, (i) {
      return Cat.fromMap(maps[i]);
    });
  }

  // Get cats by species
  Future<List<Cat>> getCatsBySpecies(int speciesId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cats',
      where: 'species_id = ?',
      whereArgs: [speciesId],
    );
    return List.generate(maps.length, (i) {
      return Cat.fromMap(maps[i]);
    });
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
