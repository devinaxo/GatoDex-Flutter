import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const int _currentDatabaseVersion = 1;
  static const String _databaseName = 'gatodex_database.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return openDatabase(
      path,
      onCreate: (db, version) async {
        await _createTables(db);
        await _insertInitialData(db);
        await _insertAppVersionInfo(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _upgradeDatabase(db, oldVersion, newVersion);
      },
      version: _currentDatabaseVersion,
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute(
      'CREATE TABLE species(id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE fur_patterns(id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
    );
    await db.execute('''CREATE TABLE cats(
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
    )''');
    await db.execute('''CREATE TABLE app_info(
      id INTEGER PRIMARY KEY,
      app_version TEXT NOT NULL,
      database_version INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''');
  }

  Future<void> _insertInitialData(Database db) async {
    await _insertInitialSpecies(db);
    await _insertInitialFurPatterns(db);
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here:
    // if (oldVersion < 2) { ... }
  }

  Future<void> _insertAppVersionInfo(Database db) async {
    const currentAppVersion = '0.2.2';
    final now = DateTime.now().toIso8601String();
    await db.insert('app_info', {
      'app_version': currentAppVersion,
      'database_version': _currentDatabaseVersion,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> _insertInitialSpecies(Database db) async {
    for (final name in [
      'Pelo Corto Doméstico', 'Pelo Largo Doméstico', 'Persa',
      'Maine Coon', 'Siamés', 'Británico de Pelo Corto',
      'Azul Ruso', 'Ragdoll', 'Bengalí', 'Scottish Fold',
    ]) {
      await db.insert('species', {'name': name});
    }
  }

  Future<void> _insertInitialFurPatterns(Database db) async {
    for (final name in [
      'Sólido', 'Atigrado', 'Carey', 'Tortuga', 'Bicolor',
      'Tricolor', 'Manchado', 'Punteado', 'Colorpoint',
      'Humo', 'Sombreado', 'Chinchilla',
    ]) {
      await db.insert('fur_patterns', {'name': name});
    }
  }

  // CRUD: Cats
  Future<void> insertCat(Cat cat) async {
    final db = await database;
    await db.insert('cats', cat.toMap(includeId: false),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Cat>> getCats() async {
    final db = await database;
    final maps = await db.query('cats');
    return maps.map((m) => Cat.fromMap(m)).toList();
  }

  Future<List<Cat>> getCatsPaginated({int offset = 0, int limit = 15}) async {
    final db = await database;
    final maps = await db.query('cats', orderBy: 'id DESC', limit: limit, offset: offset);
    return maps.map((m) => Cat.fromMap(m)).toList();
  }

  Future<int> getCatsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cats');
    return result.first['count'] as int;
  }

  Future<List<Cat>> getCatsFiltered({
    int offset = 0,
    int limit = 15,
    String? searchName,
    int? speciesId,
    int? furPatternId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (searchName != null && searchName.isNotEmpty) {
      where.add('name LIKE ?');
      args.add('%$searchName%');
    }
    if (speciesId != null) {
      where.add('species_id = ?');
      args.add(speciesId);
    }
    if (furPatternId != null) {
      where.add('fur_pattern_id = ?');
      args.add(furPatternId);
    }
    if (dateFrom != null) {
      where.add('date_met >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null) {
      where.add('date_met <= ?');
      args.add(dateTo);
    }

    final maps = await db.query(
      'cats',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => Cat.fromMap(m)).toList();
  }

  Future<int> getCatsFilteredCount({
    String? searchName,
    int? speciesId,
    int? furPatternId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (searchName != null && searchName.isNotEmpty) {
      where.add('name LIKE ?');
      args.add('%$searchName%');
    }
    if (speciesId != null) {
      where.add('species_id = ?');
      args.add(speciesId);
    }
    if (furPatternId != null) {
      where.add('fur_pattern_id = ?');
      args.add(furPatternId);
    }
    if (dateFrom != null) {
      where.add('date_met >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null) {
      where.add('date_met <= ?');
      args.add(dateTo);
    }

    final whereClause = where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : '';
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cats $whereClause', args.isNotEmpty ? args : null);
    return result.first['count'] as int;
  }

  Future<Cat?> getCat(int id) async {
    final db = await database;
    final maps = await db.query('cats', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Cat.fromMap(maps.first) : null;
  }

  Future<void> updateCat(Cat cat) async {
    final db = await database;
    await db.update('cats', cat.toMap(includeId: true),
        where: 'id = ?', whereArgs: [cat.id]);
  }

  Future<void> deleteCat(int id) async {
    final db = await database;
    await db.delete('cats', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD: Species
  Future<List<Species>> getSpecies() async {
    final db = await database;
    final maps = await db.query('species');
    return maps.map((m) => Species.fromMap(m)).toList();
  }

  Future<void> insertSpecies(Species species) async {
    final db = await database;
    await db.insert('species', {'name': species.name},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // CRUD: Fur Patterns
  Future<List<FurPattern>> getFurPatterns() async {
    final db = await database;
    final maps = await db.query('fur_patterns');
    return maps.map((m) => FurPattern.fromMap(m)).toList();
  }

  Future<void> insertFurPattern(FurPattern furPattern) async {
    final db = await database;
    await db.insert('fur_patterns', {'name': furPattern.name},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCatsWithDetails() async {
    final db = await database;
    return db.rawQuery('''
      SELECT c.*, s.name as species_name, fp.name as fur_pattern_name
      FROM cats c
      LEFT JOIN species s ON c.species_id = s.id
      LEFT JOIN fur_patterns fp ON c.fur_pattern_id = fp.id
    ''');
  }

  Future<List<Cat>> searchCatsByName(String name) async {
    final db = await database;
    final maps = await db.query('cats', where: 'name LIKE ?', whereArgs: ['%$name%']);
    return maps.map((m) => Cat.fromMap(m)).toList();
  }

  Future<List<Cat>> getCatsBySpecies(int speciesId) async {
    final db = await database;
    final maps = await db.query('cats', where: 'species_id = ?', whereArgs: [speciesId]);
    return maps.map((m) => Cat.fromMap(m)).toList();
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Database management
  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  Future<bool> databaseExists() async {
    final path = await getDatabasePath();
    return File(path).exists();
  }

  Future<void> backupDatabase(String backupPath) async {
    final dbPath = await getDatabasePath();
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.copy(backupPath);
    } else {
      throw Exception('Database file does not exist at: $dbPath');
    }
  }

  Future<void> restoreDatabase(String backupPath) async {
    final dbPath = await getDatabasePath();
    final backupFile = File(backupPath);
    if (await backupFile.exists()) {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      await backupFile.copy(dbPath);
      await database;
    } else {
      throw Exception('Backup file does not exist at: $backupPath');
    }
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final path = await getDatabasePath();
    final dbFile = File(path);
    final exists = await dbFile.exists();

    final info = <String, dynamic>{
      'path': path,
      'exists': exists,
      'version': _currentDatabaseVersion,
      'name': _databaseName,
    };

    if (exists) {
      final stat = await dbFile.stat();
      info['size'] = stat.size;
      info['modified'] = stat.modified.toIso8601String();
    }

    return info;
  }

  Future<void> recreateDatabase() async {
    final dbPath = await getDatabasePath();
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    await database;
  }

  Future<void> updateAppVersionInfo(String newAppVersion) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      final existing = await db.query('app_info',
          where: 'app_version = ?', whereArgs: [newAppVersion]);

      if (existing.isEmpty) {
        await db.insert('app_info', {
          'app_version': newAppVersion,
          'database_version': _currentDatabaseVersion,
          'created_at': now,
          'updated_at': now,
        });
      }
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getAppVersionHistory() async {
    try {
      final db = await database;
      return await db.query('app_info', orderBy: 'created_at DESC');
    } catch (_) {
      return [];
    }
  }
}
