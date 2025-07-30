import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import '../services/cat_service.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';
import '../widgets/home/cat_details_modal.dart';
import 'edit_cat_screen.dart';

class GatoMapaScreen extends StatefulWidget {
  @override
  _GatoMapaScreenState createState() => _GatoMapaScreenState();
}

class _GatoMapaScreenState extends State<GatoMapaScreen> {
  final CatService _catService = CatService();
  List<Cat> _allCats = [];
  List<Cat> _catsWithLocation = [];
  List<Species> _species = [];
  List<FurPattern> _furPatterns = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();
  
  // Map settings
  LatLng _center = LatLng(40.7128, -74.0060); // Default to NYC
  double _zoom = 10.0;

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
      
      final catsWithLocation = cats.where((cat) => cat.hasLocation).toList();
      
      if (catsWithLocation.isNotEmpty) {
        double avgLat = catsWithLocation
            .map((cat) => cat.latitude!)
            .reduce((a, b) => a + b) / catsWithLocation.length;
        double avgLng = catsWithLocation
            .map((cat) => cat.longitude!)
            .reduce((a, b) => a + b) / catsWithLocation.length;
        _center = LatLng(avgLat, avgLng);
      }

      setState(() {
        _allCats = cats;
        _catsWithLocation = catsWithLocation;
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

  Widget _buildCatMarker(Cat cat, BuildContext context) {
    return GestureDetector(
      onTap: () => _showCatDetailsModal(cat),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: cat.picturePath != null && File(cat.picturePath!).existsSync()
              ? Image.file(
                  File(cat.picturePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultMarker(context);
                  },
                )
              : _buildDefaultMarker(context),
        ),
      ),
    );
  }

  Widget _buildDefaultMarker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.pets,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _catsWithLocation.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Stats bar
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            Icons.pets,
                            'Total',
                            _allCats.length.toString(),
                          ),
                          _buildStatItem(
                            context,
                            Icons.location_on,
                            'Con Ubicación',
                            _catsWithLocation.length.toString(),
                          ),
                          _buildStatItem(
                            context,
                            Icons.location_off,
                            'Sin Ubicación',
                            (_allCats.length - _catsWithLocation.length).toString(),
                          ),
                        ],
                      ),
                    ),
                    // Map
                    Expanded(
                      child: Container(
                        color: isDark ? Colors.black : Colors.white,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _center,
                            initialZoom: _zoom,
                            backgroundColor: isDark ? Colors.black : Colors.white,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.pinchZoom |
                                  InteractiveFlag.drag |
                                  InteractiveFlag.doubleTapZoom,
                            ),
                          ),
                          children: [
                            // Map tile layer with dark mode filter
                            ColorFiltered(
                              colorFilter: isDark
                                  ? ColorFilter.matrix(<double>[
                                      -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
                                      -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
                                      -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
                                      0, 0, 0, 1, 0, // Alpha channel
                                    ])
                                  : ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                              child: TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.devinaxo.gatodex',
                                maxZoom: 19,
                              ),
                            ),
                            // Markers layer
                            MarkerLayer(
                              markers: _catsWithLocation.map((cat) {
                                return Marker(
                                  point: LatLng(cat.latitude!, cat.longitude!),
                                  width: 50,
                                  height: 50,
                                  child: _buildCatMarker(cat, context),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _catsWithLocation.isNotEmpty
          ? FloatingActionButton(
              onPressed: _centerMapOnCats,
              child: Icon(Icons.my_location),
              tooltip: 'Centrar en gatos',
            )
          : null,
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No hay gatos con ubicación',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega ubicaciones a tus gatos para verlos en el mapa',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              // Navigate back to home page to add cats
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Text('Agregar Gatos'),
          ),
        ],
      ),
    );
  }

  void _centerMapOnCats() {
    if (_catsWithLocation.isEmpty) return;

    double minLat = _catsWithLocation.first.latitude!;
    double maxLat = _catsWithLocation.first.latitude!;
    double minLng = _catsWithLocation.first.longitude!;
    double maxLng = _catsWithLocation.first.longitude!;

    for (final cat in _catsWithLocation) {
      if (cat.latitude! < minLat) minLat = cat.latitude!;
      if (cat.latitude! > maxLat) maxLat = cat.latitude!;
      if (cat.longitude! < minLng) minLng = cat.longitude!;
      if (cat.longitude! > maxLng) maxLng = cat.longitude!;
    }

    // Calculate center and zoom level
    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    
    // Animate to fit all markers
    _mapController.move(center, 10.0);
  }

  void _showCatDetailsModal(Cat cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CatDetailsModal(
        cat: cat,
        species: _species,
        furPatterns: _furPatterns,
        onEdit: () => _navigateToEditCat(cat),
        onDelete: () => _showDeleteDialog(cat),
      ),
    );
  }

  Future<void> _navigateToEditCat(Cat cat) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCatScreen(cat: cat)),
    );

    if (result == true) {
      _loadData();
    }
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
}
