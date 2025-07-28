import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/cat.dart';
import '../../models/species.dart';
import '../../models/fur_pattern.dart';
import '../../utils/helpers.dart';
import '../shared/cat_location_map.dart';
import '../shared/fullscreen_image_viewer.dart';

class CatDetailsModal extends StatelessWidget {
  final Cat cat;
  final List<Species> species;
  final List<FurPattern> furPatterns;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CatDetailsModal({
    Key? key,
    required this.cat,
    required this.species,
    required this.furPatterns,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  String _getSpeciesName(int speciesId) {
    final foundSpecies = species.where((s) => s.id == speciesId);
    return foundSpecies.isNotEmpty ? foundSpecies.first.name : 'Especie Desconocida';
  }

  String _getFurPatternName(int? furPatternId) {
    if (furPatternId == null) return 'Sin Patrón';
    final pattern = furPatterns.where((p) => p.id == furPatternId);
    return pattern.isNotEmpty ? pattern.first.name : 'Patrón Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                      child: GestureDetector(
                        onTap: () {
                          if (cat.picturePath != null) {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (context, animation, secondaryAnimation) => 
                                  FullscreenImageViewer(
                                    imagePath: cat.picturePath,
                                    heroTag: 'cat_image_${cat.id}',
                                  ),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Hero(
                              tag: 'cat_image_${cat.id}',
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: 450,
                                  maxHeight: 600,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.1),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: cat.picturePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: cat.picturePath!.startsWith('assets/')
                                            ? Image.asset(
                                                cat.picturePath!,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return _buildDefaultCatImage(context);
                                                },
                                              )
                                            : Image.file(
                                                File(cat.picturePath!),
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return _buildDefaultCatImage(context);
                                                },
                                              ),
                                      )
                                    : _buildDefaultCatImage(context),
                              ),
                            ),
                            // Tap indicator overlay (only show for images)
                            if (cat.picturePath != null)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Cat name
                    Center(
                      child: Text(
                        cat.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Cat details
                    _buildDetailRow(
                      context,
                      icon: Icons.pets,
                      label: 'Especie',
                      value: _getSpeciesName(cat.speciesId),
                    ),

                    _buildDetailRow(
                      context,
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
                                  color: Theme.of(context).colorScheme.primary,
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
                        context,
                        icon: Icons.calendar_today,
                        label: 'Fecha de Encuentro',
                        value: AppHelpers.formatDate(cat.dateMet),
                      ),

                    if (cat.picturePath != null)
                      _buildDetailRow(
                        context,
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
                              onEdit();
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Editar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                            label: Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
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
    );
  }

  Widget _buildDefaultCatImage(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 200,
        minHeight: 200,
        maxWidth: 300,
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Icon(
        Icons.pets,
        size: 80,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
