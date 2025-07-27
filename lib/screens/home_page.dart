import 'dart:io';
import 'package:flutter/material.dart';
import '../services/cat_service.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';
import '../utils/helpers.dart';
import '../widgets/cat_location_map.dart';
import 'edit_cat_screen.dart';
import 'add_cat_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CatService _catService = CatService();
  List<Cat> _cats = [];
  List<Species> _species = [];
  List<FurPattern> _furPatterns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cats = await _catService.getAllCats();
      final species = await _catService.getAllSpecies();
      final furPatterns = await _catService.getAllFurPatterns();

      setState(() {
        _cats = cats;
        _species = species;
        _furPatterns = furPatterns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando datos: $e')),
      );
    }
  }

  String _getSpeciesName(int speciesId) {
    final species = _species.where((s) => s.id == speciesId);
    return species.isNotEmpty ? species.first.name : 'Especie Desconocida';
  }

  String _getFurPatternName(int? furPatternId) {
    if (furPatternId == null) return 'Sin Patrón';
    final pattern = _furPatterns.where((p) => p.id == furPatternId);
    return pattern.isNotEmpty ? pattern.first.name : 'Patrón Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GatoDex'),
        backgroundColor: Colors.orange,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'add_test_data',
                child: Row(
                  children: [
                    Icon(Icons.science, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Agregar Datos de Prueba'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpiar Todo', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Actualizar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    Icon(Icons.backup, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Copia de Seguridad'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'add_test_data':
                  _addTestCats();
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
                case 'refresh':
                  _loadData();
                  break;
                case 'backup':
                  _navigateToBackup();
                  break;
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay gatos registrados',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8),
                      Text('¡Agrega tu primer gato!'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _cats.length,
                  itemBuilder: (context, index) {
                    final cat = _cats[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          radius: 25,
                          child: cat.picturePath != null
                              ? ClipOval(
                                  child: cat.picturePath!.startsWith('assets/')
                                      ? Image.asset(
                                          cat.picturePath!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.pets,
                                              color: Colors.orange,
                                              size: 25,
                                            );
                                          },
                                        )
                                      : Image.file(
                                          File(cat.picturePath!),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.pets,
                                              color: Colors.orange,
                                              size: 25,
                                            );
                                          },
                                        ),
                                )
                              : Icon(
                                  Icons.pets,
                                  color: Colors.orange,
                                  size: 25,
                                ),
                        ),
                        title: Text(
                          cat.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Especie: ${_getSpeciesName(cat.speciesId)}'),
                            Text('Patrón: ${_getFurPatternName(cat.furPatternId)}'),
                            if (cat.hasLocation)
                              Text('Ubicación: ${cat.coordinatesString}'),
                            if (cat.dateMet != null)
                              Text('Encontrado: ${AppHelpers.formatDate(cat.dateMet)}'),
                          ],
                        ),
                        onTap: () {
                          _showCatDetailsModal(cat);
                        },
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Editar'),
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
                            if (value == 'edit') {
                              _navigateToEditCat(cat);
                            } else if (value == 'delete') {
                              _showDeleteDialog(cat);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCatDialog();
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(Cat cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Gato'),
        content: Text('¿Estás seguro de que quieres eliminar a ${cat.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _catService.deleteCat(cat.id);
              Navigator.pop(context);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${cat.name} eliminado')),
              );
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Gato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Qué quieres hacer?'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addTestCats();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Agregar Gatos de Prueba'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToAddCat();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Agregar Gato Real'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTestCats() async {
    try {
      // Get the starting ID and increment for each cat
      int baseId = await _catService.getNextCatId();
      
      // Create test cats with different properties to showcase the UI
      final testCats = [
        Cat(
          id: baseId,
          name: 'Whiskers',
          speciesId: 1, // Pelo Corto Doméstico
          furPatternId: 2, // Atigrado
          latitude: 40.7128, // Nueva York
          longitude: -74.0060,
          dateMet: '2025-01-15',
          picturePath: 'assets/images/default_cat.jpg',
        ),
        Cat(
          id: baseId + 1,
          name: 'Luna',
          speciesId: 3, // Persa
          furPatternId: 1, // Sólido
          latitude: 41.3851, // Barcelona
          longitude: 2.1734,
          dateMet: '2024-12-20',
          picturePath: null,
        ),
        Cat(
          id: baseId + 2,
          name: 'Mittens',
          speciesId: 5, // Siamés
          furPatternId: 9, // Colorpoint
          latitude: null, // Sin ubicación
          longitude: null,
          dateMet: '2025-07-10',
          picturePath: 'assets/images/default_cat.jpg',
        ),
        Cat(
          id: baseId + 3,
          name: 'Shadow',
          speciesId: 2, // Pelo Largo Doméstico
          furPatternId: 10, // Humo
          latitude: 51.5074, // Londres
          longitude: -0.1278,
          dateMet: null, // Sin fecha
          picturePath: null,
        ),
        Cat(
          id: baseId + 4,
          name: 'Fluffy',
          speciesId: 8, // Ragdoll
          furPatternId: 5, // Bicolor
          latitude: 48.8566, // París
          longitude: 2.3522,
          dateMet: '2025-03-22',
          picturePath: 'assets/images/default_cat.jpg',
        ),
        Cat(
          id: baseId + 5,
          name: 'Tigger',
          speciesId: 9, // Bengalí
          furPatternId: 7, // Manchado
          latitude: 35.6762, // Tokio
          longitude: 139.6503,
          dateMet: '2025-05-14',
          picturePath: null,
        ),
        Cat(
          id: baseId + 6,
          name: 'Snowball',
          speciesId: 6, // Británico de Pelo Corto
          furPatternId: 1, // Sólido
          latitude: 55.7558, // Moscú
          longitude: 37.6176,
          dateMet: '2024-11-08',
          picturePath: 'assets/images/default_cat.jpg',
        ),
        Cat(
          id: baseId + 7,
          name: 'Patches',
          speciesId: 1, // Pelo Corto Doméstico
          furPatternId: 3, // Carey
          latitude: -33.8688, // Sídney
          longitude: 151.2093,
          dateMet: '2025-06-30',
          picturePath: null,
        ),
      ];

      // Add each test cat to the database
      for (Cat cat in testCats) {
        await _catService.addCat(cat);
        print('Added cat: ${cat.name} with ID: ${cat.id}'); // Debug print
      }

      // Refresh the data to show new cats
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${testCats.length} gatos de prueba agregados exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error adding test cats: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error agregando gatos de prueba: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpiar Todos los Datos'),
        content: Text('¿Estás seguro de que quieres eliminar TODOS los gatos? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllCats();
            },
            child: Text('Eliminar Todo', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllCats() async {
    try {
      // Get all cats and delete them one by one
      final allCats = await _catService.getAllCats();
      for (Cat cat in allCats) {
        await _catService.deleteCat(cat.id);
      }

      // Refresh the data
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Todos los gatos han sido eliminados'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error eliminando datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToEditCat(Cat cat) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCatScreen(cat: cat),
      ),
    );

    // If the edit was successful, reload the data
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToAddCat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCatScreen(),
      ),
    );

    // If the add was successful, reload the data
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToBackup() async {
    final result = await Navigator.pushNamed(context, '/backup');
    
    // If backup operations were performed, refresh the data
    if (result == true) {
      _loadData();
    }
  }

  void _showCatDetailsModal(Cat cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cat photo section
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 450,
                            maxHeight: 600,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: cat.picturePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: cat.picturePath!.startsWith('assets/')
                                      ? Image.asset(
                                          cat.picturePath!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildDefaultCatImage();
                                          },
                                        )
                                      : Image.file(
                                          File(cat.picturePath!),
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildDefaultCatImage();
                                          },
                                        ),
                                )
                              : _buildDefaultCatImage(),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Cat name
                      Center(
                        child: Text(
                          cat.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Cat details
                      _buildDetailRow(
                        icon: Icons.pets,
                        label: 'Especie',
                        value: _getSpeciesName(cat.speciesId),
                      ),
                      
                      _buildDetailRow(
                        icon: Icons.palette,
                        label: 'Patrón de Pelaje',
                        value: _getFurPatternName(cat.furPatternId),
                      ),
                      
                      if (cat.hasLocation) ...[
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.orange.shade600,
                                    size: 24,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ubicación',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          cat.coordinatesString!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              CatLocationMap(
                                latitude: cat.latitude!,
                                longitude: cat.longitude!,
                                catName: cat.name,
                                height: 250,
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      if (cat.dateMet != null)
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Fecha de Encuentro',
                          value: AppHelpers.formatDate(cat.dateMet),
                        ),
                      
                      if (cat.picturePath != null)
                        _buildDetailRow(
                          icon: Icons.photo,
                          label: 'Foto',
                          value: cat.picturePath!.split('/').last,
                        ),
                      
                      SizedBox(height: 32),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _navigateToEditCat(cat);
                              },
                              icon: Icon(Icons.edit),
                              label: Text('Editar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showDeleteDialog(cat);
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                              label: Text('Eliminar', style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCatImage() {
    return Container(
      constraints: BoxConstraints(
        minWidth: 200,
        minHeight: 200,
        maxWidth: 300,
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.orange.shade100,
      ),
      child: Icon(
        Icons.pets,
        size: 80,
        color: Colors.orange.shade600,
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.orange.shade600,
            size: 24,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
