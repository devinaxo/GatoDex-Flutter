import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cat.dart';
import '../models/breed.dart';
import '../models/fur_pattern.dart';
import '../models/cat_photo.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const int _currentDatabaseVersion = 2;
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
        await _createTablesV2(db);
        await _insertInitialDataV2(db);
        await _insertAppVersionInfo(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _upgradeDatabase(db, oldVersion, newVersion);
      },
      version: _currentDatabaseVersion,
    );
  }

  // ──────────────────────────────────────────────
  // Schema V2 (fresh install)
  // ──────────────────────────────────────────────

  Future<void> _createTablesV2(Database db) async {
    await db.execute(
      'CREATE TABLE breeds(id INTEGER PRIMARY KEY, name TEXT NOT NULL, name_key TEXT)',
    );
    await db.execute(
      'CREATE TABLE fur_patterns(id INTEGER PRIMARY KEY, name TEXT NOT NULL, name_key TEXT)',
    );
    await db.execute('''CREATE TABLE cats(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      breed_id INTEGER NOT NULL,
      fur_pattern_id INTEGER,
      latitude REAL,
      longitude REAL,
      date_met TEXT,
      FOREIGN KEY (breed_id) REFERENCES breeds (id),
      FOREIGN KEY (fur_pattern_id) REFERENCES fur_patterns (id)
    )''');
    await db.execute('''CREATE TABLE cat_aliases(
      id INTEGER PRIMARY KEY,
      cat_id INTEGER NOT NULL,
      alias TEXT NOT NULL,
      display_order INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (cat_id) REFERENCES cats (id) ON DELETE CASCADE
    )''');
    await db.execute('''CREATE TABLE cat_photos(
      id INTEGER PRIMARY KEY,
      cat_id INTEGER NOT NULL,
      photo_path TEXT NOT NULL,
      display_order INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (cat_id) REFERENCES cats (id) ON DELETE CASCADE
    )''');
    await db.execute('''CREATE TABLE app_info(
      id INTEGER PRIMARY KEY,
      app_version TEXT NOT NULL,
      database_version INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''');
  }

  Future<void> _insertInitialDataV2(Database db) async {
    await _insertInitialBreeds(db);
    await _insertInitialFurPatterns(db);
  }

  // ──────────────────────────────────────────────
  // Migration v1 → v2
  // ──────────────────────────────────────────────

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateV1toV2(db);
    }
  }

  Future<void> _migrateV1toV2(Database db) async {
    // 1. Create new breeds table with name_key
    await db.execute(
      'CREATE TABLE breeds(id INTEGER PRIMARY KEY, name TEXT NOT NULL, name_key TEXT)',
    );

    // 2. Migrate species → breeds, mapping old Spanish names to keys
    final oldSpecies = await db.query('species');
    final speciesKeyMap = _buildSpeciesKeyMap();

    for (final row in oldSpecies) {
      final oldName = row['name'] as String;
      final nameKey = speciesKeyMap[oldName];
      await db.insert('breeds', {
        'id': row['id'],
        'name': nameKey != null ? oldName : oldName,
        'name_key': nameKey,
      });
    }

    // 3. Add name_key column to fur_patterns
    await db.execute('ALTER TABLE fur_patterns ADD COLUMN name_key TEXT');

    // 4. Update seeded fur patterns with keys
    final furPatternKeyMap = _buildFurPatternKeyMap();
    for (final entry in furPatternKeyMap.entries) {
      await db.execute(
        'UPDATE fur_patterns SET name_key = ? WHERE name = ?',
        [entry.value, entry.key],
      );
    }

    // 5. Create cat_aliases table
    await db.execute('''CREATE TABLE cat_aliases(
      id INTEGER PRIMARY KEY,
      cat_id INTEGER NOT NULL,
      alias TEXT NOT NULL,
      display_order INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (cat_id) REFERENCES cats (id) ON DELETE CASCADE
    )''');

    // 6. Create cat_photos table
    await db.execute('''CREATE TABLE cat_photos(
      id INTEGER PRIMARY KEY,
      cat_id INTEGER NOT NULL,
      photo_path TEXT NOT NULL,
      display_order INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (cat_id) REFERENCES cats (id) ON DELETE CASCADE
    )''');

    // 7. Migrate picture_path data from cats to cat_photos
    final catsWithPhotos = await db.rawQuery(
      'SELECT id, picture_path FROM cats WHERE picture_path IS NOT NULL',
    );
    final now = DateTime.now().toIso8601String();
    for (final cat in catsWithPhotos) {
      await db.insert('cat_photos', {
        'cat_id': cat['id'],
        'photo_path': cat['picture_path'],
        'display_order': 0,
        'created_at': now,
      });
    }

    // 8. Recreate cats table without picture_path, with breed_id instead of species_id
    // SQLite doesn't support DROP COLUMN or RENAME COLUMN on older versions,
    // so we recreate the table.
    await db.execute('''CREATE TABLE cats_new(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      breed_id INTEGER NOT NULL,
      fur_pattern_id INTEGER,
      latitude REAL,
      longitude REAL,
      date_met TEXT,
      FOREIGN KEY (breed_id) REFERENCES breeds (id),
      FOREIGN KEY (fur_pattern_id) REFERENCES fur_patterns (id)
    )''');
    await db.execute('''
      INSERT INTO cats_new (id, name, breed_id, fur_pattern_id, latitude, longitude, date_met)
      SELECT id, name, species_id, fur_pattern_id, latitude, longitude, date_met FROM cats
    ''');
    await db.execute('DROP TABLE cats');
    await db.execute('ALTER TABLE cats_new RENAME TO cats');

    // 9. Drop old species table
    await db.execute('DROP TABLE IF EXISTS species');
  }

  /// Maps old Spanish seeded species names to their key identifiers.
  Map<String, String> _buildSpeciesKeyMap() => {
    'Pelo Corto Doméstico': 'domestic_shorthair',
    'Pelo Largo Doméstico': 'domestic_longhair',
    'Persa': 'persian',
    'Maine Coon': 'maine_coon',
    'Siamés': 'siamese',
    'Británico de Pelo Corto': 'british_shorthair',
    'Azul Ruso': 'russian_blue',
    'Ragdoll': 'ragdoll',
    'Bengalí': 'bengal',
    'Scottish Fold': 'scottish_fold',
  };

  /// Maps old Spanish seeded fur pattern names to their key identifiers.
  Map<String, String> _buildFurPatternKeyMap() => {
    'Sólido': 'solid',
    'Atigrado': 'tabby',
    'Carey': 'calico',
    'Tortuga': 'tortoiseshell',
    'Bicolor': 'bicolor',
    'Tricolor': 'tricolor',
    'Manchado': 'spotted',
    'Punteado': 'pointed',
    'Colorpoint': 'colorpoint',
    'Humo': 'smoke',
    'Sombreado': 'shaded',
    'Chinchilla': 'chinchilla',
  };

  // ──────────────────────────────────────────────
  // Seed data
  // ──────────────────────────────────────────────

  Future<void> _insertAppVersionInfo(Database db) async {
    const currentAppVersion = '0.3.0';
    final now = DateTime.now().toIso8601String();
    await db.insert('app_info', {
      'app_version': currentAppVersion,
      'database_version': _currentDatabaseVersion,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> _insertInitialBreeds(Database db) async {
    final breeds = [
      {'name': 'Domestic Shorthair', 'name_key': 'domestic_shorthair'},
      {'name': 'Domestic Longhair', 'name_key': 'domestic_longhair'},
      {'name': 'Persian', 'name_key': 'persian'},
      {'name': 'Maine Coon', 'name_key': 'maine_coon'},
      {'name': 'Siamese', 'name_key': 'siamese'},
      {'name': 'British Shorthair', 'name_key': 'british_shorthair'},
      {'name': 'Russian Blue', 'name_key': 'russian_blue'},
      {'name': 'Ragdoll', 'name_key': 'ragdoll'},
      {'name': 'Bengal', 'name_key': 'bengal'},
      {'name': 'Scottish Fold', 'name_key': 'scottish_fold'},
    ];
    for (final breed in breeds) {
      await db.insert('breeds', breed);
    }
  }

  Future<void> _insertInitialFurPatterns(Database db) async {
    final patterns = [
      {'name': 'Solid', 'name_key': 'solid'},
      {'name': 'Tabby', 'name_key': 'tabby'},
      {'name': 'Calico', 'name_key': 'calico'},
      {'name': 'Tortoiseshell', 'name_key': 'tortoiseshell'},
      {'name': 'Bicolor', 'name_key': 'bicolor'},
      {'name': 'Tricolor', 'name_key': 'tricolor'},
      {'name': 'Spotted', 'name_key': 'spotted'},
      {'name': 'Pointed', 'name_key': 'pointed'},
      {'name': 'Colorpoint', 'name_key': 'colorpoint'},
      {'name': 'Smoke', 'name_key': 'smoke'},
      {'name': 'Shaded', 'name_key': 'shaded'},
      {'name': 'Chinchilla', 'name_key': 'chinchilla'},
    ];
    for (final pattern in patterns) {
      await db.insert('fur_patterns', pattern);
    }
  }

  // ──────────────────────────────────────────────
  // CRUD: Cats
  // ──────────────────────────────────────────────

  Future<int> insertCat(Cat cat) async {
    final db = await database;
    return await db.insert('cats', cat.toMap(includeId: false),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Cat>> getCats() async {
    final db = await database;
    final maps = await db.query('cats');
    final cats = <Cat>[];
    for (final m in maps) {
      final cat = Cat.fromMap(m);
      final photos = await getPhotosForCat(cat.id);
      final aliases = await getAliasesForCat(cat.id);
      cats.add(cat.copyWith(photos: photos, aliases: aliases));
    }
    return cats;
  }

  Future<List<Cat>> getCatsPaginated({int offset = 0, int limit = 15}) async {
    final db = await database;
    final maps = await db.query('cats', orderBy: 'id DESC', limit: limit, offset: offset);
    final cats = <Cat>[];
    for (final m in maps) {
      final cat = Cat.fromMap(m);
      final photos = await getPhotosForCat(cat.id);
      final aliases = await getAliasesForCat(cat.id);
      cats.add(cat.copyWith(photos: photos, aliases: aliases));
    }
    return cats;
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
    int? breedId,
    int? furPatternId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (searchName != null && searchName.isNotEmpty) {
      // Search by cat name or aliases
      where.add('(cats.name LIKE ? OR cats.id IN (SELECT cat_id FROM cat_aliases WHERE alias LIKE ?))');
      args.add('%$searchName%');
      args.add('%$searchName%');
    }
    if (breedId != null) {
      where.add('cats.breed_id = ?');
      args.add(breedId);
    }
    if (furPatternId != null) {
      where.add('cats.fur_pattern_id = ?');
      args.add(furPatternId);
    }
    if (dateFrom != null) {
      where.add('cats.date_met >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null) {
      where.add('cats.date_met <= ?');
      args.add(dateTo);
    }

    final whereClause = where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : '';
    final maps = await db.rawQuery(
      'SELECT cats.* FROM cats $whereClause ORDER BY cats.id DESC LIMIT ? OFFSET ?',
      [...args, limit, offset],
    );

    final cats = <Cat>[];
    for (final m in maps) {
      final cat = Cat.fromMap(m);
      final photos = await getPhotosForCat(cat.id);
      final aliases = await getAliasesForCat(cat.id);
      cats.add(cat.copyWith(photos: photos, aliases: aliases));
    }
    return cats;
  }

  Future<int> getCatsFilteredCount({
    String? searchName,
    int? breedId,
    int? furPatternId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (searchName != null && searchName.isNotEmpty) {
      where.add('(cats.name LIKE ? OR cats.id IN (SELECT cat_id FROM cat_aliases WHERE alias LIKE ?))');
      args.add('%$searchName%');
      args.add('%$searchName%');
    }
    if (breedId != null) {
      where.add('cats.breed_id = ?');
      args.add(breedId);
    }
    if (furPatternId != null) {
      where.add('cats.fur_pattern_id = ?');
      args.add(furPatternId);
    }
    if (dateFrom != null) {
      where.add('cats.date_met >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null) {
      where.add('cats.date_met <= ?');
      args.add(dateTo);
    }

    final whereClause = where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : '';
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cats $whereClause', args.isNotEmpty ? args : null);
    return result.first['count'] as int;
  }

  Future<Cat?> getCat(int id) async {
    final db = await database;
    final maps = await db.query('cats', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final cat = Cat.fromMap(maps.first);
    final photos = await getPhotosForCat(cat.id);
    final aliases = await getAliasesForCat(cat.id);
    return cat.copyWith(photos: photos, aliases: aliases);
  }

  Future<void> updateCat(Cat cat) async {
    final db = await database;
    await db.update('cats', cat.toMap(includeId: true),
        where: 'id = ?', whereArgs: [cat.id]);
  }

  Future<void> deleteCat(int id) async {
    final db = await database;
    // Delete associated aliases, photos, then the cat
    await db.delete('cat_aliases', where: 'cat_id = ?', whereArgs: [id]);
    await db.delete('cat_photos', where: 'cat_id = ?', whereArgs: [id]);
    await db.delete('cats', where: 'id = ?', whereArgs: [id]);
  }

  // ──────────────────────────────────────────────
  // CRUD: Breeds (formerly Species)
  // ──────────────────────────────────────────────

  Future<List<Breed>> getBreeds() async {
    final db = await database;
    final maps = await db.query('breeds');
    return maps.map((m) => Breed.fromMap(m)).toList();
  }

  Future<void> insertBreed(Breed breed) async {
    final db = await database;
    await db.insert('breeds', {'name': breed.name, 'name_key': breed.nameKey},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ──────────────────────────────────────────────
  // CRUD: Fur Patterns
  // ──────────────────────────────────────────────

  Future<List<FurPattern>> getFurPatterns() async {
    final db = await database;
    final maps = await db.query('fur_patterns');
    return maps.map((m) => FurPattern.fromMap(m)).toList();
  }

  Future<void> insertFurPattern(FurPattern furPattern) async {
    final db = await database;
    await db.insert('fur_patterns', {'name': furPattern.name, 'name_key': furPattern.nameKey},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ──────────────────────────────────────────────
  // CRUD: Cat Aliases
  // ──────────────────────────────────────────────

  Future<List<String>> getAliasesForCat(int catId) async {
    final db = await database;
    final maps = await db.query('cat_aliases',
        where: 'cat_id = ?', whereArgs: [catId], orderBy: 'display_order ASC');
    return maps.map((m) => m['alias'] as String).toList();
  }

  Future<void> insertAlias(int catId, String alias, int displayOrder) async {
    final db = await database;
    await db.insert('cat_aliases', {
      'cat_id': catId,
      'alias': alias,
      'display_order': displayOrder,
    });
  }

  Future<void> deleteAliasesForCat(int catId) async {
    final db = await database;
    await db.delete('cat_aliases', where: 'cat_id = ?', whereArgs: [catId]);
  }

  Future<void> updateAliases(int catId, List<String> aliases) async {
    final db = await database;
    await db.delete('cat_aliases', where: 'cat_id = ?', whereArgs: [catId]);
    for (int i = 0; i < aliases.length; i++) {
      if (aliases[i].trim().isNotEmpty) {
        await db.insert('cat_aliases', {
          'cat_id': catId,
          'alias': aliases[i].trim(),
          'display_order': i,
        });
      }
    }
  }

  // ──────────────────────────────────────────────
  // CRUD: Cat Photos
  // ──────────────────────────────────────────────

  Future<List<CatPhoto>> getPhotosForCat(int catId) async {
    final db = await database;
    final maps = await db.query('cat_photos',
        where: 'cat_id = ?', whereArgs: [catId], orderBy: 'display_order ASC');
    return maps.map((m) => CatPhoto.fromMap(m)).toList();
  }

  Future<void> insertPhoto(int catId, String photoPath, int displayOrder) async {
    final db = await database;
    await db.insert('cat_photos', {
      'cat_id': catId,
      'photo_path': photoPath,
      'display_order': displayOrder,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deletePhoto(int photoId) async {
    final db = await database;
    await db.delete('cat_photos', where: 'id = ?', whereArgs: [photoId]);
  }

  Future<void> deletePhotosForCat(int catId) async {
    final db = await database;
    await db.delete('cat_photos', where: 'cat_id = ?', whereArgs: [catId]);
  }

  Future<int> getPhotoCount(int catId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cat_photos WHERE cat_id = ?', [catId]);
    return result.first['count'] as int;
  }

  Future<void> updatePhotos(int catId, List<String> photoPaths) async {
    final db = await database;
    await db.delete('cat_photos', where: 'cat_id = ?', whereArgs: [catId]);
    final now = DateTime.now().toIso8601String();
    for (int i = 0; i < photoPaths.length; i++) {
      await db.insert('cat_photos', {
        'cat_id': catId,
        'photo_path': photoPaths[i],
        'display_order': i,
        'created_at': now,
      });
    }
  }

  // ──────────────────────────────────────────────
  // Join queries
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCatsWithDetails() async {
    final db = await database;
    return db.rawQuery('''
      SELECT c.*, b.name as breed_name, fp.name as fur_pattern_name
      FROM cats c
      LEFT JOIN breeds b ON c.breed_id = b.id
      LEFT JOIN fur_patterns fp ON c.fur_pattern_id = fp.id
    ''');
  }

  Future<List<Cat>> searchCatsByName(String name) async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT cats.* FROM cats LEFT JOIN cat_aliases ON cats.id = cat_aliases.cat_id WHERE cats.name LIKE ? OR cat_aliases.alias LIKE ?',
      ['%$name%', '%$name%'],
    );
    final cats = <Cat>[];
    for (final m in maps) {
      final cat = Cat.fromMap(m);
      final photos = await getPhotosForCat(cat.id);
      final aliases = await getAliasesForCat(cat.id);
      cats.add(cat.copyWith(photos: photos, aliases: aliases));
    }
    return cats;
  }

  Future<List<Cat>> getCatsByBreed(int breedId) async {
    final db = await database;
    final maps = await db.query('cats', where: 'breed_id = ?', whereArgs: [breedId]);
    final cats = <Cat>[];
    for (final m in maps) {
      final cat = Cat.fromMap(m);
      final photos = await getPhotosForCat(cat.id);
      final aliases = await getAliasesForCat(cat.id);
      cats.add(cat.copyWith(photos: photos, aliases: aliases));
    }
    return cats;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // ──────────────────────────────────────────────
  // Database management
  // ──────────────────────────────────────────────

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
