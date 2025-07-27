import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/cat.dart';
import 'cat_service.dart';

class BackupService {
  final CatService _catService = CatService();
  
  /// Exports all cat data and images to a backup file
  Future<String> exportDatabase() async {
    try {
      // Get all cats, species, and fur patterns
      final cats = await _catService.getAllCats();
      final species = await _catService.getAllSpecies();
      final furPatterns = await _catService.getAllFurPatterns();
      
      // Create backup data structure
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'cats': cats.map((cat) => cat.toMap()).toList(),
          'species': species.map((s) => s.toMap()).toList(),
          'furPatterns': furPatterns.map((fp) => fp.toMap()).toList(),
        },
        'images': <String, String>{}, // Will store base64 encoded images
      };
      
      // Include images as base64 strings
      final Map<String, String> imageMap = backupData['images'] as Map<String, String>;
      for (final cat in cats) {
        if (cat.picturePath != null && !cat.picturePath!.startsWith('assets/')) {
          try {
            final imageFile = File(cat.picturePath!);
            if (await imageFile.exists()) {
              final imageBytes = await imageFile.readAsBytes();
              final base64Image = base64Encode(imageBytes);
              imageMap[cat.picturePath!] = base64Image;
            }
          } catch (e) {
            print('Error encoding image ${cat.picturePath}: $e');
          }
        }
      }
      
      // Get a more user-friendly directory
      Directory? directory;
      try {
        // Try to get a better directory location
        if (Platform.isWindows) {
          final userProfile = Platform.environment['USERPROFILE'];
          if (userProfile != null) {
            directory = Directory(path.join(userProfile, 'Documents'));
          }
        } else if (Platform.isAndroid) {
          // Try to get Downloads directory first (more accessible for users)
          try {
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              // Fallback to Documents
              directory = Directory('/storage/emulated/0/Documents');
              if (!await directory.exists()) {
                // Create Documents folder if it doesn't exist
                await directory.create(recursive: true);
              }
            }
          } catch (e) {
            // If external storage fails, use app-specific external storage
            directory = await getExternalStorageDirectory();
          }
        }
        
        // Check if the directory exists and is writable
        if (directory != null && !await directory.exists()) {
          directory = null;
        }
      } catch (e) {
        print('Error accessing preferred directory: $e');
        directory = null;
      }
      
      // Fallback to application documents directory
      directory ??= await getApplicationDocumentsDirectory();
      final backupDir = Directory(path.join(directory.path, 'GatoDex-Backups'));
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      // Create backup file with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final backupFileName = 'gatodex_backup_$timestamp.json';
      final backupFile = File(path.join(backupDir.path, backupFileName));
      
      // Write backup data to file
      await backupFile.writeAsString(jsonEncode(backupData), flush: true);
      
      return backupFile.path;
    } catch (e) {
      throw Exception('Error creating backup: $e');
    }
  }
  
  /// Imports cat data from a backup file
  Future<ImportResult> importDatabase(String backupFilePath, {bool replaceExisting = false}) async {
    try {
      final backupFile = File(backupFilePath);
      
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }
      
      // Read and parse backup file
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;
      
      // Validate backup format
      if (!_validateBackupFormat(backupData)) {
        throw Exception('Invalid backup file format');
      }
      
      final data = backupData['data'] as Map<String, dynamic>;
      final images = backupData['images'] as Map<String, dynamic>? ?? {};
      
      // Clear existing data if requested
      if (replaceExisting) {
        await _clearAllData();
      }
      
      int importedCats = 0;
      int skippedCats = 0;
      final errors = <String>[];
      
      // Import cats
      final catsData = data['cats'] as List<dynamic>;
      for (final catData in catsData) {
        try {
          final cat = Cat.fromMap(catData as Map<String, dynamic>);
          
          // Check if cat already exists (by name)
          final existingCats = await _catService.getAllCats();
          final catExists = existingCats.any((existing) => existing.name.toLowerCase() == cat.name.toLowerCase());
          
          if (catExists && !replaceExisting) {
            skippedCats++;
            continue;
          }
          
          // Restore image if it exists in backup
          String? newImagePath;
          if (cat.picturePath != null && images.containsKey(cat.picturePath)) {
            try {
              newImagePath = await _restoreImage(cat.picturePath!, images[cat.picturePath]!);
            } catch (e) {
              print('Error restoring image for ${cat.name}: $e');
              // Continue without image
            }
          }
          
          // Create new cat with restored image path
          final newCat = Cat(
            id: 0, // Temporary ID, database will assign the correct one
            name: cat.name,
            speciesId: cat.speciesId,
            furPatternId: cat.furPatternId,
            latitude: cat.latitude,
            longitude: cat.longitude,
            dateMet: cat.dateMet,
            picturePath: newImagePath ?? cat.picturePath,
          );
          
          if (catExists && replaceExisting) {
            // Update existing cat
            final existingCat = existingCats.firstWhere((existing) => existing.name.toLowerCase() == cat.name.toLowerCase());
            final updatedCat = Cat(
              id: existingCat.id,
              name: newCat.name,
              speciesId: newCat.speciesId,
              furPatternId: newCat.furPatternId,
              latitude: newCat.latitude,
              longitude: newCat.longitude,
              dateMet: newCat.dateMet,
              picturePath: newCat.picturePath,
            );
            await _catService.updateCat(updatedCat);
          } else {
            // Add new cat
            await _catService.addCat(newCat);
          }
          
          importedCats++;
        } catch (e) {
          errors.add('Error importing cat: $e');
        }
      }
      
      return ImportResult(
        success: true,
        importedCats: importedCats,
        skippedCats: skippedCats,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        importedCats: 0,
        skippedCats: 0,
        errors: ['Failed to import backup: $e'],
      );
    }
  }
  
  /// Lists available backup files
  Future<List<BackupInfo>> getAvailableBackups() async {
    try {
      // Use the same directory logic as export
      Directory? directory;
      try {
        if (Platform.isWindows) {
          final userProfile = Platform.environment['USERPROFILE'];
          if (userProfile != null) {
            directory = Directory(path.join(userProfile, 'Documents'));
          }
        } else if (Platform.isAndroid) {
          // Try to get Downloads directory first (more accessible for users)
          try {
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              // Fallback to Documents
              directory = Directory('/storage/emulated/0/Documents');
              if (!await directory.exists()) {
                // Create Documents folder if it doesn't exist
                await directory.create(recursive: true);
              }
            }
          } catch (e) {
            // If external storage fails, use app-specific external storage
            directory = await getExternalStorageDirectory();
          }
        }
        
        if (directory != null && !await directory.exists()) {
          directory = null;
        }
      } catch (e) {
        print('Error accessing preferred directory: $e');
        directory = null;
      }
      
      directory ??= await getApplicationDocumentsDirectory();
      final backupDir = Directory(path.join(directory.path, 'GatoDex-Backups'));
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final backupFiles = await backupDir.list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();
      
      final backups = <BackupInfo>[];
      
      for (final file in backupFiles) {
        try {
          final stat = await file.stat();
          final content = await file.readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;
          
          final catsCount = (data['data']?['cats'] as List?)?.length ?? 0;
          final timestamp = data['timestamp'] as String?;
          
          backups.add(BackupInfo(
            filePath: file.path,
            fileName: path.basename(file.path),
            fileSize: stat.size,
            createdAt: timestamp != null ? DateTime.tryParse(timestamp) : null,
            catsCount: catsCount,
          ));
        } catch (e) {
          print('Error reading backup file ${file.path}: $e');
        }
      }
      
      // Sort by creation date (newest first)
      backups.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return backups;
    } catch (e) {
      throw Exception('Error listing backups: $e');
    }
  }
  
  /// Deletes a backup file
  Future<void> deleteBackup(String backupFilePath) async {
    try {
      final file = File(backupFilePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Error deleting backup: $e');
    }
  }
  
  // Private helper methods
  
  bool _validateBackupFormat(Map<String, dynamic> backupData) {
    return backupData.containsKey('version') &&
        backupData.containsKey('data') &&
        backupData['data'] is Map &&
        (backupData['data'] as Map).containsKey('cats');
  }
  
  Future<void> _clearAllData() async {
    final cats = await _catService.getAllCats();
    for (final cat in cats) {
      await _catService.deleteCat(cat.id);
    }
  }
  
  Future<String> _restoreImage(String originalPath, String base64Image) async {
    try {
      final imageBytes = base64Decode(base64Image);
      
      // Get app directory for storing images
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'cat_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = path.join(appDir.path, fileName);
      
      final newFile = File(newPath);
      await newFile.writeAsBytes(imageBytes);
      
      return newPath;
    } catch (e) {
      throw Exception('Error restoring image: $e');
    }
  }
}

class ImportResult {
  final bool success;
  final int importedCats;
  final int skippedCats;
  final List<String> errors;
  
  ImportResult({
    required this.success,
    required this.importedCats,
    required this.skippedCats,
    required this.errors,
  });
}

class BackupInfo {
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime? createdAt;
  final int catsCount;
  
  BackupInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.createdAt,
    required this.catsCount,
  });
  
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  String get formattedDate {
    if (createdAt == null) return 'Fecha desconocida';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays == 1 ? '' : 's'} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours == 1 ? '' : 's'} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'} atrás';
    } else {
      return 'Ahora';
    }
  }
}
