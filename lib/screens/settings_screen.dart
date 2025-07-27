import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'backup_screen.dart';
import 'database_management_screen.dart';
import '../services/cat_service.dart';
import '../models/cat.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CatService _catService = CatService();
  bool _isAdvancedExpanded = false;
  bool _isAddingTestData = false;
  bool _dataChanged = false; // Track if data was modified

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dataChanged);
        return false; // Prevent default pop behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
          backgroundColor: Colors.orange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _dataChanged);
            },
          ),
        ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // General Section
          _buildSectionCard(
            title: 'General',
            children: [
              _buildListTile(
                icon: Icons.backup,
                title: 'Copia de Seguridad',
                subtitle: 'Gestionar copias de seguridad',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.info_outline,
                title: 'Acerca de',
                subtitle: 'Información de la aplicación',
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Advanced Testing Section
          _buildSectionCard(
            title: 'Testing (Avanzado!)',
            isExpandable: true,
            isExpanded: _isAdvancedExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isAdvancedExpanded = expanded;
              });
            },
            children: _isAdvancedExpanded ? [
              // Warning notice
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estas opciones son principalmente para desarrolladores. Si no sabes lo que estás haciendo, probablemente no deberías tocar esto.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildListTile(
                icon: Icons.storage,
                title: 'Gestión de BD',
                subtitle: 'Administrar base de datos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DatabaseManagementScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.add_circle_outline,
                title: 'Agregar Datos de Prueba',
                subtitle: _isAddingTestData 
                    ? 'Agregando datos...' 
                    : 'Añadir gatos de ejemplo',
                onTap: _isAddingTestData ? null : () => _showAddTestDataDialog(),
                trailing: _isAddingTestData 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              _buildListTile(
                icon: Icons.delete_forever,
                title: 'Eliminar Todos los Gatos',
                subtitle: 'Borra TODOS los gatos de la base de datos',
                onTap: () => _showClearAllCatsDialog(),
                iconColor: Colors.red,
                titleColor: Colors.red,
              ),
            ] : [],
          ),
        ],
      ),
    ), // End of Scaffold
    ); // End of WillPopScope
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    bool isExpandable = false,
    bool isExpanded = false,
    ValueChanged<bool>? onExpansionChanged,
  }) {
    Widget content = Card(
      elevation: 2,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                if (isExpandable) ...[
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.orange,
                  ),
                ],
              ],
            ),
          ),
          ...children,
        ],
      ),
    );

    if (isExpandable) {
      return GestureDetector(
        onTap: () => onExpansionChanged?.call(!isExpanded),
        child: content,
      );
    }

    return content;
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (iconColor ?? Colors.orange).withOpacity(0.1),
        child: Icon(icon, color: iconColor ?? Colors.orange),
      ),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _showAboutDialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    
    if (!mounted) return;
    
    showAboutDialog(
      context: context,
      applicationName: 'gatoDex',
      applicationVersion: packageInfo.version,
      applicationIcon: Image.asset(
        'assets/icon/meowth.png',
        width: 64,
        height: 64,
      ),
      children: [
        const Text(
          'Una aplicación para catalogar y gestionar información sobre gatos que te encuentres.',
        ),
        const SizedBox(height: 24),
        // Social media icons section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // GitHub icon and link
            Column(
              children: [
                GestureDetector(
                  onTap: () => _launchURL('https://devinaxo.github.io'),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/github-icon.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL('https://devinaxo.github.io'),
                  child: const Text(
                    'devinaxo.github.io',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            // Twitter icon and link
            Column(
              children: [
                GestureDetector(
                  onTap: () => _launchURL('https://twitter.com/devinachoes'),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/twitter-icon.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL('https://twitter.com/devinachoes'),
                  child: const Text(
                    'twitter.com/devinachoes',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Desarrollado con Flutter',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    print('Attempting to launch URL: $url'); // Debug output
    final Uri uri = Uri.parse(url);
    try {
      // First try to check if the URL can be launched
      bool canLaunch = await canLaunchUrl(uri);
      print('Can launch URL: $canLaunch'); // Debug output
      
      if (canLaunch) {
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('Launch result: $launched'); // Debug output
        
        if (!launched) {
          // Try with platform default mode if external application fails
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
          print('Second launch attempt result: $launched'); // Debug output
        }
        
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir el enlace: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Cannot launch URL: $url'); // Debug output
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se puede abrir este tipo de enlace: $url'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Exception launching URL: $e'); // Debug output
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el enlace: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddTestDataDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Datos de Prueba'),
        content: const Text(
          '¿Estás seguro de que quieres agregar gatos de prueba?\n\n'
          'Esto agregará 3 gatos de ejemplo:\n'
          '• Miau\n'
          '• Luna\n'
          '• Garfield\n\n'
          'Los gatos existentes no se eliminarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addTestData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar Datos'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearAllCatsDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('¡Peligro!'),
          ],
        ),
        content: const Text(
          '¿Estás COMPLETAMENTE SEGURO de que quieres eliminar TODOS los gatos?\n\n'
          '⚠️ Esta acción NO se puede deshacer.\n'
          '⚠️ Se perderán TODOS los datos de gatos.\n'
          '⚠️ Las fotos también se eliminarán.\n\n'
          'Solo procede si sabes exactamente lo que estás haciendo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllCats();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ELIMINAR TODO'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllCats() async {
    setState(() {
      _isAddingTestData = true; // Reuse the loading state
    });

    try {
      // Get all cats and delete them one by one
      final allCats = await _catService.getAllCats();
      for (var cat in allCats) {
        await _catService.deleteCat(cat.id);
      }

      if (mounted) {
        setState(() {
          _dataChanged = true; // Mark that data was modified
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Todos los gatos han sido eliminados!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar gatos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingTestData = false;
        });
      }
    }
  }

  Future<void> _addTestData() async {
    setState(() {
      _isAddingTestData = true;
    });

    try {
      // Get existing species and patterns to use their IDs
      final allSpecies = await _catService.getAllSpecies();
      final allPatterns = await _catService.getAllFurPatterns();

      if (allSpecies.isEmpty) {
        throw Exception('No hay especies disponibles. Necesitas al menos una especie para crear gatos de prueba.');
      }

      // Add test cats only
      final testCats = [
        Cat(
          id: 0, // Will be auto-generated
          name: 'Miau',
          speciesId: allSpecies.first.id,
          furPatternId: allPatterns.isNotEmpty ? allPatterns.first.id : null,
          dateMet: '2024-01-15',
          picturePath: 'assets/images/default_cat.jpg',
        ),
        Cat(
          id: 0, // Will be auto-generated
          name: 'Luna',
          speciesId: allSpecies.length > 1 ? allSpecies[1].id : allSpecies.first.id,
          furPatternId: allPatterns.length > 1 ? allPatterns[1].id : (allPatterns.isNotEmpty ? allPatterns.first.id : null),
          dateMet: '2024-02-20',
        ),
        Cat(
          id: 0, // Will be auto-generated
          name: 'Garfield',
          speciesId: allSpecies.length > 2 ? allSpecies[2].id : allSpecies.first.id,
          furPatternId: allPatterns.length > 2 ? allPatterns[2].id : (allPatterns.isNotEmpty ? allPatterns.first.id : null),
          dateMet: '2024-03-10',
          picturePath: 'assets/images/default_cat.jpg',
        ),
      ];

      for (var cat in testCats) {
        await _catService.addCat(cat);
      }

      if (mounted) {
        setState(() {
          _dataChanged = true; // Mark that data was modified
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡3 gatos de prueba agregados exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar gatos de prueba: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingTestData = false;
        });
      }
    }
  }
}
