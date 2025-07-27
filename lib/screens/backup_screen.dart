import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  List<BackupInfo> _backups = [];
  bool _isLoading = true;
  bool _isExporting = false;
  bool _needsRefresh = false; // Track if home page needs refresh

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final backups = await _backupService.getAvailableBackups();
      setState(() {
        _backups = backups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error cargando copias de seguridad: $e');
    }
  }

  Future<void> _exportDatabase() async {
    try {
      setState(() {
        _isExporting = true;
      });

      final backupPath = await _backupService.exportDatabase();
      
      setState(() {
        _isExporting = false;
      });

      _showSuccessDialog(
        'Copia de Seguridad Creada',
        'Los datos se han exportado exitosamente.\n\nArchivo guardado en:\n$backupPath',
      );

      // Refresh the backup list
      _loadBackups();
      
      // Indicate that a refresh is needed when going back to home
      _needsRefresh = true;
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      _showError('Error creando copia de seguridad: $e');
    }
  }

  Future<void> _importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'JSON'],
        allowMultiple: false,
        dialogTitle: 'Seleccionar archivo de copia de seguridad (.json)',
        withData: false,
        withReadStream: false,
        allowCompression: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        
        // Check if it's a JSON file
        if (!filePath.toLowerCase().endsWith('.json')) {
          _showError('Por favor selecciona un archivo .json de copia de seguridad');
          return;
        }
        
        await _showImportDialog(filePath);
      }
    } catch (e) {
      _showError('Error seleccionando archivo: $e');
    }
  }

  Future<void> _importBackup(String backupPath, {bool replaceExisting = false}) async {
    try {
      final result = await _backupService.importDatabase(
        backupPath,
        replaceExisting: replaceExisting,
      );

      if (result.success) {
        String message = 'Importación completada:\n';
        message += '• ${result.importedCats} gatos importados\n';
        
        if (result.skippedCats > 0) {
          message += '• ${result.skippedCats} gatos omitidos (ya existen)\n';
        }
        
        if (result.errors.isNotEmpty) {
          message += '\nErrores:\n${result.errors.join('\n')}';
        }

        _showSuccessDialog('Importación Exitosa', message);
        
        // Indicate that a refresh is needed when going back to home
        _needsRefresh = true;
      } else {
        _showError('Error en la importación: ${result.errors.join(', ')}');
      }
    } catch (e) {
      _showError('Error importando datos: $e');
    }
  }

  Future<void> _showImportDialog(String filePath) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Importar Copia de Seguridad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Cómo deseas importar los datos?'),
              SizedBox(height: 16),
              Text(
                'Archivo: ${filePath.split('/').last}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _importBackup(filePath, replaceExisting: false);
              },
              child: Text('Agregar Solo Nuevos'),
            ),
            TextButton(
              onPressed: () async {
                final confirmed = await _showConfirmDialog(
                  'Reemplazar Todos los Datos',
                  '¿Estás seguro? Esta acción eliminará todos los gatos existentes y los reemplazará con los datos del archivo de copia de seguridad.',
                );
                
                if (confirmed) {
                  Navigator.of(context).pop();
                  _importBackup(filePath, replaceExisting: true);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Reemplazar Todo'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirmed = await _showConfirmDialog(
      'Eliminar Copia de Seguridad',
      '¿Estás seguro de que deseas eliminar esta copia de seguridad?\n\n${backup.fileName}',
    );

    if (confirmed) {
      try {
        await _backupService.deleteBackup(backup.filePath);
        _showSnackBar('Copia de seguridad eliminada', Colors.green);
        _loadBackups();
      } catch (e) {
        _showError('Error eliminando copia de seguridad: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return the refresh flag when navigating back
        Navigator.of(context).pop(_needsRefresh);
        return false; // Prevent default pop
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text('Copia de Seguridad'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Action buttons
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Export button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportDatabase,
                          icon: _isExporting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.backup),
                          label: Text(_isExporting ? 'Creando...' : 'Crear Copia de Seguridad'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Import button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _importFromFile,
                          icon: Icon(Icons.restore),
                          label: Text('Importar desde Archivo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Divider(),
                
                // Backup list
                Expanded(
                  child: _backups.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.backup_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No hay copias de seguridad',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              SizedBox(height: 8),
                              Text('Crea tu primera copia de seguridad arriba'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _backups.length,
                          itemBuilder: (context, index) {
                            final backup = _backups[index];
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.shade100,
                                  child: Icon(
                                    Icons.backup,
                                    color: Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  backup.fileName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${backup.catsCount} gatos • ${backup.formattedSize}'),
                                    Text(
                                      backup.formattedDate,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'import',
                                      child: Row(
                                        children: [
                                          Icon(Icons.restore),
                                          SizedBox(width: 8),
                                          Text('Importar'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'import':
                                        _showImportDialog(backup.filePath);
                                        break;
                                      case 'delete':
                                        _deleteBackup(backup);
                                        break;
                                    }
                                  },
                                ),
                                onTap: () => _showImportDialog(backup.filePath),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      ), // Close WillPopScope child (Scaffold)
    ); // Close WillPopScope
  }
}
