import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../database/database_helper.dart';

class DatabaseManagementScreen extends StatefulWidget {
  @override
  _DatabaseManagementScreenState createState() => _DatabaseManagementScreenState();
}

class _DatabaseManagementScreenState extends State<DatabaseManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _databaseInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final info = await _dbHelper.getDatabaseInfo();
      setState(() {
        _databaseInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('${AppLocalizations.of(context).error}: $e');
    }
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _copyPathToClipboard() async {
    if (_databaseInfo != null) {
      final l10n = AppLocalizations.of(context);
      await Clipboard.setData(ClipboardData(text: _databaseInfo!['path']));
      _showSuccessMessage(l10n.dbPathCopied);
    }
  }

  Future<void> _recreateDatabase() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recreateDatabase),
        content: Text(l10n.recreateDbConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.recreate, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.recreateDatabase();
        await _loadDatabaseInfo();
        _showSuccessMessage(l10n.dbRecreatedSuccess);
      } catch (e) {
        _showErrorDialog(l10n.errorRecreatingDb(e.toString()));
      }
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Theme.of(context).colorScheme.primary) : null,
        title: Text(title),
        subtitle: Text(value),
        onTap: onTap,
        trailing: onTap != null ? Icon(Icons.copy) : null,
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.databaseManagement),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDatabaseInfo,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _databaseInfo == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(l10n.errorLoadingDbInfo),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDatabaseInfo,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Database status section
                      Text(
                        l10n.databaseStatus,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      _buildInfoCard(
                        title: l10n.status,
                        value: _databaseInfo!['exists'] ? l10n.existsAndActive : l10n.doesNotExist,
                        icon: _databaseInfo!['exists'] ? Icons.check_circle : Icons.error,
                      ),
                      
                      _buildInfoCard(
                        title: l10n.fileName,
                        value: _databaseInfo!['name'],
                        icon: Icons.storage,
                      ),
                      
                      _buildInfoCard(
                        title: l10n.versionLabel,
                        value: _databaseInfo!['version'].toString(),
                        icon: Icons.info,
                      ),
                      
                      if (_databaseInfo!['exists']) ...[
                        _buildInfoCard(
                          title: l10n.fileSize,
                          value: _formatFileSize(_databaseInfo!['size']),
                          icon: Icons.folder,
                        ),
                        
                        _buildInfoCard(
                          title: l10n.lastModified,
                          value: DateTime.parse(_databaseInfo!['modified']).toString(),
                          icon: Icons.access_time,
                        ),
                      ],
                      
                      _buildInfoCard(
                        title: l10n.filePath,
                        value: _databaseInfo!['path'],
                        icon: Icons.folder_open,
                        onTap: _copyPathToClipboard,
                      ),
                      
                      SizedBox(height: 32),
                      
                      SizedBox(height: 24),
                      
                      // Actions section
                      Text(
                        l10n.maintenanceActions,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/backup'),
                              icon: Icon(Icons.backup),
                              label: Text(l10n.backupButton),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _recreateDatabase,
                              icon: Icon(Icons.refresh),
                              label: Text(l10n.recreateDb),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
