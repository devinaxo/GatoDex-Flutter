import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/cat.dart';
import 'cat_service.dart';

class BackupService {
  final CatService _catService = CatService();

  Future<Directory> _getBackupDirectory() async {
    Directory? directory;

    try {
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          directory = Directory(path.join(userProfile, 'Documents'));
        }
      } else if (Platform.isAndroid) {
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = Directory('/storage/emulated/0/Documents');
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
          }
        } catch (_) {
          directory = await getExternalStorageDirectory();
        }
      }

      if (directory != null && !await directory.exists()) {
        directory = null;
      }
    } catch (_) {
      directory = null;
    }

    directory ??= await getApplicationDocumentsDirectory();
    final backupDir = Directory(path.join(directory.path, 'GatoDex-Backups'));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  Future<String> exportDatabase() async {
    try {
      final cats = await _catService.getAllCats();
      final species = await _catService.getAllSpecies();
      final furPatterns = await _catService.getAllFurPatterns();

      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'cats': cats.map((cat) => cat.toMap(includeId: true)).toList(),
          'species': species.map((s) => s.toMap()).toList(),
          'furPatterns': furPatterns.map((fp) => fp.toMap()).toList(),
        },
        'images': <String, String>{},
      };

      final imageMap = backupData['images'] as Map<String, String>;
      for (final cat in cats) {
        if (cat.picturePath != null && !cat.picturePath!.startsWith('assets/')) {
          try {
            final imageFile = File(cat.picturePath!);
            if (await imageFile.exists()) {
              imageMap[cat.picturePath!] = base64Encode(await imageFile.readAsBytes());
            }
          } catch (_) {}
        }
      }

      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final backupFile = File(path.join(backupDir.path, 'gatodex_backup_$timestamp.json'));

      await backupFile.writeAsString(jsonEncode(backupData), flush: true);
      return backupFile.path;
    } catch (e) {
      throw Exception('Error creating backup: $e');
    }
  }

  Future<ImportResult> importDatabase(String backupFilePath, {bool replaceExisting = false}) async {
    try {
      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) throw Exception('Backup file not found');

      final backupData = jsonDecode(await backupFile.readAsString()) as Map<String, dynamic>;
      if (!_validateBackupFormat(backupData)) throw Exception('Invalid backup file format');

      final data = backupData['data'] as Map<String, dynamic>;
      final images = backupData['images'] as Map<String, dynamic>? ?? {};

      if (replaceExisting) await _clearAllData();

      int importedCats = 0;
      int skippedCats = 0;
      final errors = <String>[];

      final catsData = data['cats'] as List<dynamic>;
      for (int i = 0; i < catsData.length; i++) {
        try {
          final cat = Cat.fromMap(catsData[i] as Map<String, dynamic>);
          final existingCats = await _catService.getAllCats();
          final catExists = existingCats.any((e) => e.name.toLowerCase() == cat.name.toLowerCase());

          String? newImagePath;
          if (cat.picturePath != null && images.containsKey(cat.picturePath)) {
            try {
              newImagePath = await _restoreImage(cat.picturePath!, images[cat.picturePath]!);
            } catch (_) {}
          }

          final newCat = Cat(
            id: 0,
            name: cat.name,
            speciesId: cat.speciesId,
            furPatternId: cat.furPatternId,
            latitude: cat.latitude,
            longitude: cat.longitude,
            dateMet: cat.dateMet,
            picturePath: newImagePath ?? cat.picturePath,
          );

          if (catExists && replaceExisting) {
            final existingCat = existingCats.firstWhere((e) => e.name.toLowerCase() == cat.name.toLowerCase());
            await _catService.updateCat(Cat(
              id: existingCat.id,
              name: newCat.name,
              speciesId: newCat.speciesId,
              furPatternId: newCat.furPatternId,
              latitude: newCat.latitude,
              longitude: newCat.longitude,
              dateMet: newCat.dateMet,
              picturePath: newCat.picturePath,
            ));
          } else if (!catExists) {
            await _catService.addCat(newCat);
          } else {
            skippedCats++;
            continue;
          }
          importedCats++;
        } catch (e) {
          errors.add('Error importing cat: $e');
        }
      }

      return ImportResult(success: true, importedCats: importedCats, skippedCats: skippedCats, errors: errors);
    } catch (e) {
      return ImportResult(success: false, importedCats: 0, skippedCats: 0, errors: ['Failed to import backup: $e']);
    }
  }

  Future<List<BackupInfo>> getAvailableBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) return [];

      final backupFiles = await backupDir.list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      final backups = <BackupInfo>[];
      for (final file in backupFiles) {
        try {
          final stat = await file.stat();
          final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
          backups.add(BackupInfo(
            filePath: file.path,
            fileName: path.basename(file.path),
            fileSize: stat.size,
            createdAt: data['timestamp'] != null ? DateTime.tryParse(data['timestamp']) : null,
            catsCount: (data['data']?['cats'] as List?)?.length ?? 0,
          ));
        } catch (_) {}
      }

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

  Future<void> deleteBackup(String backupFilePath) async {
    final file = File(backupFilePath);
    if (await file.exists()) await file.delete();
  }

  bool _validateBackupFormat(Map<String, dynamic> backupData) =>
      backupData.containsKey('version') && backupData.containsKey('data') && backupData['data'] is Map && (backupData['data'] as Map).containsKey('cats');

  Future<void> _clearAllData() async {
    final cats = await _catService.getAllCats();
    for (final cat in cats) {
      await _catService.deleteCat(cat.id);
    }
  }

  Future<String> _restoreImage(String originalPath, String base64Image) async {
    final imageBytes = base64Decode(base64Image);
    final appDir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(path.join(appDir.path, 'images'));
    if (!await imgDir.exists()) await imgDir.create(recursive: true);

    final fileName = 'cat_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newFile = File(path.join(imgDir.path, fileName));
    await newFile.writeAsBytes(imageBytes);
    return newFile.path;
  }
}

class ImportResult {
  final bool success;
  final int importedCats;
  final int skippedCats;
  final List<String> errors;

  ImportResult({required this.success, required this.importedCats, required this.skippedCats, required this.errors});
}

class BackupInfo {
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime? createdAt;
  final int catsCount;

  BackupInfo({required this.filePath, required this.fileName, required this.fileSize, required this.createdAt, required this.catsCount});

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    if (createdAt == null) return 'Fecha desconocida';
    final difference = DateTime.now().difference(createdAt!);
    if (difference.inDays > 0) return '${difference.inDays} día${difference.inDays == 1 ? '' : 's'} atrás';
    if (difference.inHours > 0) return '${difference.inHours} hora${difference.inHours == 1 ? '' : 's'} atrás';
    if (difference.inMinutes > 0) return '${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'} atrás';
    return 'Ahora';
  }
}
