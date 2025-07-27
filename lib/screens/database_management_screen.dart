import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      _showErrorDialog('Error loading database info: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
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
      await Clipboard.setData(ClipboardData(text: _databaseInfo!['path']));
      _showSuccessMessage('Database path copied to clipboard');
    }
  }

  Future<void> _recreateDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recrear Base de Datos'),
        content: Text(
          '¿Estás seguro de que quieres recrear la base de datos? '
          'Esto eliminará todos los datos existentes y creará una nueva base de datos con los datos iniciales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Recrear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.recreateDatabase();
        await _loadDatabaseInfo();
        _showSuccessMessage('Base de datos recreada exitosamente');
      } catch (e) {
        _showErrorDialog('Error recreando la base de datos: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Base de Datos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                      Text('Error cargando información de la base de datos'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDatabaseInfo,
                        child: Text('Reintentar'),
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
                        'Estado de la Base de Datos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      _buildInfoCard(
                        title: 'Estado',
                        value: _databaseInfo!['exists'] ? 'Existe y Activa' : 'No Existe',
                        icon: _databaseInfo!['exists'] ? Icons.check_circle : Icons.error,
                      ),
                      
                      _buildInfoCard(
                        title: 'Nombre del Archivo',
                        value: _databaseInfo!['name'],
                        icon: Icons.storage,
                      ),
                      
                      _buildInfoCard(
                        title: 'Versión',
                        value: _databaseInfo!['version'].toString(),
                        icon: Icons.info,
                      ),
                      
                      if (_databaseInfo!['exists']) ...[
                        _buildInfoCard(
                          title: 'Tamaño del Archivo',
                          value: _formatFileSize(_databaseInfo!['size']),
                          icon: Icons.folder,
                        ),
                        
                        _buildInfoCard(
                          title: 'Última Modificación',
                          value: DateTime.parse(_databaseInfo!['modified']).toString(),
                          icon: Icons.access_time,
                        ),
                      ],
                      
                      _buildInfoCard(
                        title: 'Ruta del Archivo',
                        value: _databaseInfo!['path'],
                        icon: Icons.folder_open,
                        onTap: _copyPathToClipboard,
                      ),
                      
                      SizedBox(height: 32),
                      
                      SizedBox(height: 24),
                      
                      // Actions section
                      Text(
                        'Acciones de Mantenimiento',
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
                              label: Text('Copia de Seguridad'),
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
                              label: Text('Recrear BD'),
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
