import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  final String? initialImportPath;

  const BackupScreen({Key? key, this.initialImportPath}) : super(key: key);

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  List<BackupInfo> _backups = [];
  bool _isLoading = true;
  bool _isExporting = false;
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
    if (widget.initialImportPath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showImportDialog(widget.initialImportPath!);
      });
    }
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
      _showError(AppLocalizations.of(context).errorLoadingBackups(e.toString()));
    }
  }

  Future<void> _exportDatabase() async {
    final l10n = AppLocalizations.of(context);
    try {
      setState(() {
        _isExporting = true;
      });

      final backupPath = await _backupService.exportDatabase();
      
      setState(() {
        _isExporting = false;
      });

      _showSuccessDialog(
        l10n.backupCreated,
        l10n.backupCreatedMessage(backupPath),
      );

      _loadBackups();
      _needsRefresh = true;
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      _showError(l10n.errorCreatingBackup(e.toString()));
    }
  }

  Future<void> _importFromFile() async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'JSON'],
        allowMultiple: false,
        dialogTitle: l10n.selectBackupFile,
        withData: false,
        withReadStream: false,
        allowCompression: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        
        if (!filePath.toLowerCase().endsWith('.json')) {
          _showError(l10n.selectJsonFile);
          return;
        }
        
        await _showImportDialog(filePath);
      }
    } catch (e) {
      _showError(l10n.errorSelectingFile(e.toString()));
    }
  }

  Future<void> _importBackup(String backupPath, {bool replaceExisting = false}) async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await _backupService.importDatabase(
        backupPath,
        replaceExisting: replaceExisting,
      );

      if (result.success) {
        String message = '${l10n.importCompleted}\n';
        message += '${l10n.catsImported(result.importedCats)}\n';
        
        if (result.skippedCats > 0) {
          message += '${l10n.catsSkipped(result.skippedCats)}\n';
        }
        
        if (result.errors.isNotEmpty) {
          message += '\n${l10n.errors}\n${result.errors.join('\n')}';
        }

        _showSuccessDialog(l10n.importSuccess, message);
        _needsRefresh = true;
      } else {
        _showError(l10n.importError(result.errors.join(', ')));
      }
    } catch (e) {
      _showError(l10n.errorImportingData(e.toString()));
    }
  }

  Future<void> _showImportDialog(String filePath) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.importBackup),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.howToImport),
              SizedBox(height: 16),
              Text(
                l10n.file(filePath.split('/').last),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _importBackup(filePath, replaceExisting: false);
              },
              child: Text(l10n.addOnlyNew),
            ),
            TextButton(
              onPressed: () async {
                final confirmed = await _showConfirmDialog(
                  l10n.replaceAllData,
                  l10n.replaceAllConfirm,
                );
                
                if (confirmed) {
                  Navigator.of(context).pop();
                  _importBackup(filePath, replaceExisting: true);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.replaceAll),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _showConfirmDialog(
      l10n.deleteBackup,
      l10n.deleteBackupConfirm(backup.fileName),
    );

    if (confirmed) {
      try {
        await _backupService.deleteBackup(backup.filePath);
        _showSnackBar(l10n.backupDeleted, Colors.green);
        _loadBackups();
      } catch (e) {
        _showError(l10n.errorDeletingBackup(e.toString()));
      }
    }
  }

  Future<void> _shareBackup(BackupInfo backup) async {
    final l10n = AppLocalizations.of(context);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(backup.filePath)],
          subject: 'GatoDex Backup - ${backup.fileName}',
        ),
      );
    } catch (e) {
      _showError(l10n.errorSharingBackup(e.toString()));
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
    final l10n = AppLocalizations.of(context);
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
              child: Text(l10n.understood),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_needsRefresh);
        return false;
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                          label: Text(_isExporting ? l10n.creating : l10n.createBackup),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                          label: Text(l10n.importFromFile),
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
                                l10n.noBackups,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              SizedBox(height: 8),
                              Text(l10n.createFirstBackup),
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
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.backup,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  backup.fileName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${l10n.catsCount(backup.catsCount)} • ${backup.formattedSize}'),
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
                                          Text(l10n.import),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'share',
                                      child: Row(
                                        children: [
                                          Icon(Icons.share),
                                          SizedBox(width: 8),
                                          Text(l10n.share),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text(l10n.delete, style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'import':
                                        _showImportDialog(backup.filePath);
                                        break;
                                      case 'share':
                                        _shareBackup(backup);
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
      ),
    );
  }
}
