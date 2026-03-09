import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../../models/cat.dart';
import '../../models/breed.dart';
import '../../models/fur_pattern.dart';
import '../../utils/helpers.dart';
import '../../utils/breed_fur_translations.dart';
import '../shared/cat_location_map.dart';
import '../shared/fullscreen_image_viewer.dart';

class CatDetailsModal extends StatefulWidget {
  final Cat cat;
  final List<Breed> breeds;
  final List<FurPattern> furPatterns;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CatDetailsModal({
    Key? key,
    required this.cat,
    required this.breeds,
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

  String _getBreedName(int breedId) {
    final l10n = AppLocalizations.of(context);
    final found = widget.breeds.where((b) => b.id == breedId);
    if (found.isEmpty) return l10n.unknownBreed;
    return getLocalizedBreedName(context, found.first);
  }

  String _getFurPatternName(int? furPatternId) {
    final l10n = AppLocalizations.of(context);
    if (furPatternId == null) return l10n.noPattern;
    final pattern = widget.furPatterns.where((p) => p.id == furPatternId);
    if (pattern.isEmpty) return l10n.unknownPattern;
    return getLocalizedFurPatternName(context, pattern.first);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryPhoto = widget.cat.primaryPhotoPath;

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
                        // Photo gallery
                        if (widget.cat.photos.isNotEmpty)
                          _buildPhotoGallery(context)
                        else
                          Center(child: _buildDefaultCatImage(context)),

                        const SizedBox(height: 24),

                        Center(
                          child: Text(
                            widget.cat.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),

                        // Aliases
                        if (widget.cat.aliases.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(l10n.aliasesDetailLabel,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    alignment: WrapAlignment.center,
                                    children: widget.cat.aliases.map((alias) => Chip(
                                      label: Text(alias, style: const TextStyle(fontSize: 12)),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                    )).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        _buildDetailRow(context, icon: Icons.pets, label: l10n.breedDetailLabel, value: _getBreedName(widget.cat.breedId)),
                        _buildDetailRow(context, icon: Icons.palette, label: l10n.furPatternDetailLabel, value: _getFurPatternName(widget.cat.furPatternId)),

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
                                          Text(l10n.locationLabel, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
                          _buildDetailRow(context, icon: Icons.calendar_today, label: l10n.dateMetDetailLabel, value: AppHelpers.formatDate(widget.cat.dateMet)),

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
                                label: Text(l10n.edit),
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
                                label: Text(l10n.delete, style: TextStyle(color: Colors.red)),
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

  Widget _buildPhotoGallery(BuildContext context) {
    if (widget.cat.photos.length == 1) {
      return Center(
        child: GestureDetector(
          onTap: () => _openFullscreenImage(widget.cat.photos.first.photoPath),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildImage(widget.cat.photos.first.photoPath),
                  ),
                ),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.fullscreen, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Multiple photos — horizontal scroll
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.cat.photos.length,
        itemBuilder: (context, index) {
          final photo = widget.cat.photos[index];
          return GestureDetector(
            onTap: () => _openFullscreenImage(photo.photoPath),
            child: Container(
              width: 220,
              margin: EdgeInsets.only(right: index < widget.cat.photos.length - 1 ? 12 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 220, height: 280,
                      child: _buildImage(photo.photoPath, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                      child: Text('${index + 1}/${widget.cat.photos.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.fullscreen, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String path, {BoxFit fit = BoxFit.contain}) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit, errorBuilder: (_, __, ___) => _buildDefaultCatImage(context));
    }
    return Image.file(File(path), fit: fit, errorBuilder: (_, __, ___) => _buildDefaultCatImage(context));
  }

  void _openFullscreenImage(String path) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => FullscreenImageViewer(
          imagePath: path,
          heroTag: 'cat_image_${widget.cat.id}',
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
      child: Image.asset('assets/images/palico-neutral.png', width: 80, height: 80),
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
