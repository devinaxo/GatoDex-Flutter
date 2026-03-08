import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/cat.dart';
import '../../models/species.dart';
import '../../models/fur_pattern.dart';
import '../../utils/helpers.dart';
import '../shared/cat_location_map.dart';
import '../shared/fullscreen_image_viewer.dart';

class CatDetailsModal extends StatefulWidget {
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

  @override
  State<CatDetailsModal> createState() => _CatDetailsModalState();
}

class _CatDetailsModalState extends State<CatDetailsModal> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getSpeciesName(int speciesId) {
    final foundSpecies = widget.species.where((s) => s.id == speciesId);
    return foundSpecies.isNotEmpty ? foundSpecies.first.name : 'Especie Desconocida';
  }

  String _getFurPatternName(int? furPatternId) {
    if (furPatternId == null) return 'Sin Patrón';
    final pattern = widget.furPatterns.where((p) => p.id == furPatternId);
    return pattern.isNotEmpty ? pattern.first.name : 'Patrón Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              if (widget.cat.picturePath != null) {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                      FullscreenImageViewer(
                                        imagePath: widget.cat.picturePath,
                                        heroTag: 'cat_image_${widget.cat.id}',
                                      ),
                                  ),
                                );
                              }
                            },
                            child: Stack(
                              children: [
                                Hero(
                                  tag: 'cat_image_${widget.cat.id}',
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                                      border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: widget.cat.picturePath != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: widget.cat.picturePath!.startsWith('assets/')
                                                ? Image.asset(widget.cat.picturePath!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _buildDefaultCatImage(context))
                                                : Image.file(File(widget.cat.picturePath!), fit: BoxFit.contain, errorBuilder: (_, __, ___) => _buildDefaultCatImage(context)),
                                          )
                                        : _buildDefaultCatImage(context),
                                  ),
                                ),
                                if (widget.cat.picturePath != null)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                                      child: const Icon(Icons.fullscreen, color: Colors.white, size: 16),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: Text(
                            widget.cat.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),

                        const SizedBox(height: 24),

                        _buildDetailRow(context, icon: Icons.pets, label: 'Especie', value: _getSpeciesName(widget.cat.speciesId)),
                        _buildDetailRow(context, icon: Icons.palette, label: 'Patrón de Pelaje', value: _getFurPatternName(widget.cat.furPatternId)),

                        if (widget.cat.hasLocation) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 24),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Ubicación', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 4),
                                          Text(widget.cat.coordinatesString!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                CatLocationMap(latitude: widget.cat.latitude!, longitude: widget.cat.longitude!, catName: widget.cat.name, height: 250),
                              ],
                            ),
                          ),
                        ],

                        if (widget.cat.dateMet != null)
                          _buildDetailRow(context, icon: Icons.calendar_today, label: 'Fecha de Encuentro', value: AppHelpers.formatDate(widget.cat.dateMet)),

                        if (widget.cat.picturePath != null)
                          _buildDetailRow(context, icon: Icons.photo, label: 'Foto', value: widget.cat.picturePath!.split('/').last),

                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onEdit();
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onDelete();
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
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
