import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import 'dart:io';
import '../services/cat_service.dart';
import '../services/image_service.dart';
import '../services/cat_data_notifier.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';
import '../widgets/home/cat_details_modal.dart';
import '../utils/map_tile_helper.dart';
import 'edit_cat_screen.dart';
import 'add_cat_screen.dart';

class GatoMapaScreen extends StatefulWidget {
  @override
  _GatoMapaScreenState createState() => _GatoMapaScreenState();
}

class _GatoMapaScreenState extends State<GatoMapaScreen> with TickerProviderStateMixin {
  final CatService _catService = CatService();
  final ImageService _imageService = ImageService();
  final CatDataNotifier _dataNotifier = CatDataNotifier();
  List<Cat> _allCats = [];
  List<Cat> _catsWithLocation = [];
  List<Species> _species = [];
  List<FurPattern> _furPatterns = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();
  LatLng _center = LatLng(0.0, 0.0);
  final double _zoom = 10.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _dataNotifier.addListener(_loadData);
  }

  @override
  void dispose() {
    _dataNotifier.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final cats = await _catService.getAllCats();
      final species = await _catService.getAllSpecies();
      final furPatterns = await _catService.getAllFurPatterns();
      final catsWithLocation = cats.where((cat) => cat.hasLocation).toList();

      if (catsWithLocation.isNotEmpty) {
        final avgLat = catsWithLocation.map((c) => c.latitude!).reduce((a, b) => a + b) / catsWithLocation.length;
        final avgLng = catsWithLocation.map((c) => c.longitude!).reduce((a, b) => a + b) / catsWithLocation.length;
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
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingData(e.toString()))),
        );
      }
    }
  }

  void _animatedMove(LatLng dest, double targetZoom) {
    final currentZoom = _mapController.camera.zoom;
    final currentCenter = _mapController.camera.center;
    final finalZoom = currentZoom >= targetZoom ? currentZoom : targetZoom;

    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    final latTween = Tween<double>(begin: currentCenter.latitude, end: dest.latitude);
    final lngTween = Tween<double>(begin: currentCenter.longitude, end: dest.longitude);
    final zoomTween = Tween<double>(begin: currentZoom, end: finalZoom);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(curve), lngTween.evaluate(curve)),
        zoomTween.evaluate(curve),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Widget _buildCatMarker(Cat cat, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _animatedMove(LatLng(cat.latitude!, cat.longitude!), 15.0);
        _showCatDetailsModal(cat);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: ClipOval(
          child: cat.picturePath != null && File(cat.picturePath!).existsSync()
              ? Image.file(
                  File(cat.picturePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultMarker(context),
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
      child: Icon(Icons.pets, color: Theme.of(context).colorScheme.onPrimary, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _catsWithLocation.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(context, Icons.pets, l10n.total, _allCats.length.toString()),
                          _buildStatItem(context, Icons.location_on, l10n.withLocation, _catsWithLocation.length.toString()),
                          _buildStatItem(context, Icons.location_off, l10n.withoutLocation, (_allCats.length - _catsWithLocation.length).toString()),
                        ],
                      ),
                    ),
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
                              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom,
                            ),
                          ),
                          children: [
                            MapTileHelper.buildTileLayer(isDark: isDark),
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
      floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_catsWithLocation.isNotEmpty)
              FloatingActionButton.small(
                heroTag: 'center',
                onPressed: _centerMapOnCats,
                tooltip: l10n.centerCatLocations,
                child: const Icon(Icons.center_focus_strong),
              ),
            if (_catsWithLocation.isNotEmpty) const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'refresh',
              onPressed: _loadData,
              tooltip: l10n.refreshData,
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.noCatsWithLocation, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(l10n.addLocationsHint, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(onPressed: _navigateToAddCat, child: Text(l10n.addCats)),
        ],
      ),
    );
  }

  void _centerMapOnCats() {
    if (_catsWithLocation.isEmpty) return;

    double minLat = _catsWithLocation.first.latitude!;
    double maxLat = minLat;
    double minLng = _catsWithLocation.first.longitude!;
    double maxLng = minLng;

    for (final cat in _catsWithLocation) {
      if (cat.latitude! < minLat) minLat = cat.latitude!;
      if (cat.latitude! > maxLat) maxLat = cat.latitude!;
      if (cat.longitude! < minLng) minLng = cat.longitude!;
      if (cat.longitude! > maxLng) maxLng = cat.longitude!;
    }

    _mapController.move(LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2), 10.0);
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
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditCatScreen(cat: cat)));
    if (result == true) _loadData();
  }

  Future<void> _navigateToAddCat() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddCatScreen()));
    if (result == true) _loadData();
  }

  void _showDeleteDialog(Cat cat) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCat),
        content: Text(l10n.deleteCatConfirm(cat.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              await _imageService.deleteImage(cat.picturePath);
              await _catService.deleteCat(cat.id);
              Navigator.pop(context);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.catDeleted(cat.name))));
              }
            },
            child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
