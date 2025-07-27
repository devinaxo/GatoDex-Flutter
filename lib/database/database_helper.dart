import 'dart:async';
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
    // Use the application documents directory for persistence across updates
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    
    print('=== DATABASE INITIALIZATION ===');
    print('Database path: $path');
    print('Documents directory: ${documentsDirectory.path}');
    
    // Check if database exists before opening
    final File dbFile = File(path);
    final bool existsBefore = await dbFile.exists();
    print('Database exists before opening: $existsBefore');
    
    if (existsBefore) {
      final FileStat stat = await dbFile.stat();
      print('Database size: ${stat.size} bytes');
      print('Database last modified: ${stat.modified}');
    }
    
    return openDatabase(
      path,
      onCreate: (db, version) async {
        print('Creating new database at version $version');
        await _createTables(db);
        await _insertInitialData(db);
        await _insertAppVersionInfo(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from version $oldVersion to $newVersion');
        await _upgradeDatabase(db, oldVersion, newVersion);
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        print('Downgrading database from version $oldVersion to $newVersion');
        // Handle downgrade if necessary (usually not recommended)
      },
      onOpen: (db) async {
        print('Database opened successfully');
        await _logDatabaseInfo(db);
      },
      version: _currentDatabaseVersion,
    );
  }

  Future<void> _createTables(Database db) async {
    // Create species table first
    await db.execute(
      'CREATE TABLE species(id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
    );
    
    // Create fur_patterns table
    await db.execute(
      'CREATE TABLE fur_patterns(id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
    );
    
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
    
    // Create app_info table to track versions and database history
    await db.execute(
      '''CREATE TABLE app_info(
        id INTEGER PRIMARY KEY,
        app_version TEXT NOT NULL,
        database_version INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )''',
    );
  }

  Future<void> _insertInitialData(Database db) async {
    await _insertInitialSpecies(db);
    await _insertInitialFurPatterns(db);
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    // Example structure for future migrations:
    
    if (oldVersion < 2) {
      // Migration from version 1 to 2
      // await db.execute('ALTER TABLE cats ADD COLUMN new_field TEXT');
    }
    
    if (oldVersion < 3) {
      // Migration from version 2 to 3
      // await db.execute('CREATE TABLE new_table(...)');
    }
    
    // Always re-insert initial data if tables were modified
    // (you might want to check if data exists first)
  }

  Future<void> _insertAppVersionInfo(Database db) async {
    try {
      // Get current app version from pubspec (you might want to pass this as parameter)
      const String currentAppVersion = '0.2.2'; // Update this when app version changes
      final String now = DateTime.now().toIso8601String();
      
      await db.insert('app_info', {
        'app_version': currentAppVersion,
        'database_version': _currentDatabaseVersion,
        'created_at': now,
        'updated_at': now,
      });
      
      print('App version info inserted: $currentAppVersion (DB v$_currentDatabaseVersion)');
    } catch (e) {
      print('Error inserting app version info: $e');
    }
  }

  Future<void> _logDatabaseInfo(Database db) async {
    try {
      // Count cats
      final result = await db.rawQuery('SELECT COUNT(*) FROM cats');
      final catCount = result.first.values.first as int;
      print('Database contains $catCount cats');
      
      // Get app version info if exists
      final appInfoResult = await db.query('app_info', orderBy: 'id DESC', limit: 1);
      if (appInfoResult.isNotEmpty) {
        final info = appInfoResult.first;
        print('Last app version: ${info['app_version']}');
        print('Database version: ${info['database_version']}');
        print('Last updated: ${info['updated_at']}');
      }
      
      print('=== DATABASE READY ===');
    } catch (e) {
      print('Error logging database info: $e');
    }
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
      cat.toMap(includeId: false), // Don't include ID, let SQLite auto-assign
      conflictAlgorithm: ConflictAlgorithm.abort, // Don't replace, fail if conflict
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
      cat.toMap(includeId: true), // Include ID for updates
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

  // Database persistence and backup methods
  Future<String> getDatabasePath() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  Future<bool> databaseExists() async {
    final String path = await getDatabasePath();
    return File(path).exists();
  }

  Future<void> backupDatabase(String backupPath) async {
    try {
      final String dbPath = await getDatabasePath();
      final File dbFile = File(dbPath);
      
      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);
        print('Database backed up to: $backupPath');
      } else {
        throw Exception('Database file does not exist at: $dbPath');
      }
    } catch (e) {
      print('Error backing up database: $e');
      rethrow;
    }
  }

  Future<void> restoreDatabase(String backupPath) async {
    try {
      final String dbPath = await getDatabasePath();
      final File backupFile = File(backupPath);
      
      if (await backupFile.exists()) {
        // Close current database connection
        if (_database != null) {
          await _database!.close();
          _database = null;
        }
        
        // Copy backup file to database location
        await backupFile.copy(dbPath);
        print('Database restored from: $backupPath');
        
        // Reinitialize database connection
        await database;
      } else {
        throw Exception('Backup file does not exist at: $backupPath');
      }
    } catch (e) {
      print('Error restoring database: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final String path = await getDatabasePath();
    final File dbFile = File(path);
    final bool exists = await dbFile.exists();
    
    Map<String, dynamic> info = {
      'path': path,
      'exists': exists,
      'version': _currentDatabaseVersion,
      'name': _databaseName,
    };
    
    if (exists) {
      final FileStat stat = await dbFile.stat();
      info['size'] = stat.size;
      info['modified'] = stat.modified.toIso8601String();
    }
    
    return info;
  }

  // Method to manually trigger database recreation (for testing)
  Future<void> recreateDatabase() async {
    try {
      final String dbPath = await getDatabasePath();
      
      // Close current database connection
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      // Delete existing database file
      final File dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('Existing database deleted');
      }
      
      // Reinitialize database (this will trigger onCreate)
      await database;
      print('Database recreated successfully');
    } catch (e) {
      print('Error recreating database: $e');
      rethrow;
    }
  }

  // Update app version info when app is updated
  Future<void> updateAppVersionInfo(String newAppVersion) async {
    try {
      final db = await database;
      final String now = DateTime.now().toIso8601String();
      
      // Check if this version already exists
      final existing = await db.query(
        'app_info',
        where: 'app_version = ?',
        whereArgs: [newAppVersion],
      );
      
      if (existing.isEmpty) {
        await db.insert('app_info', {
          'app_version': newAppVersion,
          'database_version': _currentDatabaseVersion,
          'created_at': now,
          'updated_at': now,
        });
        
        print('App version updated to: $newAppVersion');
        
        // Create automatic backup after version update
        await _createAutomaticBackup(newAppVersion);
      }
    } catch (e) {
      print('Error updating app version info: $e');
    }
  }

  // Create automatic backup when version changes
  Future<void> _createAutomaticBackup(String appVersion) async {
    try {
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String backupDir = join(documentsDirectory.path, 'backups');
      
      // Create backups directory if it doesn't exist
      final Directory backupDirectory = Directory(backupDir);
      if (!await backupDirectory.exists()) {
        await backupDirectory.create(recursive: true);
      }
      
      final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final String backupPath = join(backupDir, 'auto_backup_v${appVersion}_$timestamp.db');
      
      await backupDatabase(backupPath);
      print('Automatic backup created: $backupPath');
    } catch (e) {
      print('Error creating automatic backup: $e');
    }
  }

  // Get all app version history
  Future<List<Map<String, dynamic>>> getAppVersionHistory() async {
    try {
      final db = await database;
      return await db.query('app_info', orderBy: 'created_at DESC');
    } catch (e) {
      print('Error getting app version history: $e');
      return [];
    }
  }
}
