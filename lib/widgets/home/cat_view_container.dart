import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/cat.dart';
import '../../models/species.dart';
import '../../models/fur_pattern.dart';
import 'cat_list_item.dart';
import 'cat_mosaic_item.dart';

class CatViewContainer extends StatefulWidget {
  final List<Cat> cats;
  final List<Species> species;
  final List<FurPattern> furPatterns;
  final bool isMosaicView;
  final Function(Cat) onCatTap;
  final Function(Cat) onEditCat;
  final Function(Cat) onDeleteCat;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final Function(int) onPageChanged;

  const CatViewContainer({
    Key? key,
    required this.cats,
    required this.species,
    required this.furPatterns,
    required this.isMosaicView,
    required this.onCatTap,
    required this.onEditCat,
    required this.onDeleteCat,
    required this.currentPage,
    required this.totalPages,
    required this.isLoadingMore,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  State<CatViewContainer> createState() => _CatViewContainerState();
}

class _CatViewContainerState extends State<CatViewContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(CatViewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _animatePageChange(oldWidget.currentPage, widget.currentPage);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animatePageChange(int fromPage, int toPage) {
    if (fromPage == toPage) return;
    
    // Determine slide direction
    final slideDirection = toPage < fromPage ? -1.0 : 1.0;
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(slideDirection, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward(from: 0);
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _triggerStrongHapticFeedback() {
    HapticFeedback.mediumImpact();
  }

  void _handlePageChange(int newPage) {
    if (newPage != widget.currentPage && newPage >= 1 && newPage <= widget.totalPages) {
      _triggerHapticFeedback();
      widget.onPageChanged(newPage);
    }
  }

  void _handleSwipePageChange(int newPage) {
    if (newPage != widget.currentPage && newPage >= 1 && newPage <= widget.totalPages) {
      _triggerStrongHapticFeedback(); // Stronger feedback for swipes
      widget.onPageChanged(newPage);
    }
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
    if (widget.cats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay gatos registrados',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text('¡Agrega tu primer gato!'),
          ],
        ),
      );
    }

    return GestureDetector(
      onPanEnd: (DragEndDetails details) {
        // Only handle horizontal swipes if there are multiple pages
        if (widget.totalPages <= 1) return;
        
        final velocity = details.velocity.pixelsPerSecond;
        const double velocityThreshold = 200.0; // Lower threshold for easier swiping
        
        // Swipe right (previous page)
        if (velocity.dx > velocityThreshold && widget.currentPage > 1) {
          _handleSwipePageChange(widget.currentPage - 1);
        }
        // Swipe left (next page) 
        else if (velocity.dx < -velocityThreshold && widget.currentPage < widget.totalPages) {
          _handleSwipePageChange(widget.currentPage + 1);
        }
      },
      onPanUpdate: (DragUpdateDetails details) {
        // Optional: Could add visual feedback here during the drag
        // For now, we'll keep it simple to avoid performance issues
      },
      child: widget.isMosaicView ? _buildMosaicView(context) : _buildListView(context),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView.builder(
              key: ValueKey('list_view'),
              itemCount: widget.cats.length,
              itemBuilder: (context, index) {
                final cat = widget.cats[index];
                return CatListItem(
                  cat: cat,
                  speciesName: _getSpeciesName(cat.speciesId),
                  furPatternName: _getFurPatternName(cat.furPatternId),
                  onTap: () => widget.onCatTap(cat),
                  onEdit: () => widget.onEditCat(cat),
                  onDelete: () => widget.onDeleteCat(cat),
                );
              },
            ),
          ),
        ),
        if (widget.totalPages > 1) _buildPaginationControls(context),
      ],
    );
  }

  Widget _buildMosaicView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: GridView.builder(
              key: ValueKey('mosaic_view'),
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: widget.cats.length,
              itemBuilder: (context, index) {
                final cat = widget.cats[index];
                return CatMosaicItem(
                  cat: cat,
                  speciesName: _getSpeciesName(cat.speciesId),
                  furPatternName: _getFurPatternName(cat.furPatternId),
                  onTap: () => widget.onCatTap(cat),
                  onEdit: () => widget.onEditCat(cat),
                  onDelete: () => widget.onDeleteCat(cat),
                );
              },
            ),
          ),
        ),
        if (widget.totalPages > 1) _buildPaginationControls(context),
      ],
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous page button
          IconButton(
            onPressed: widget.currentPage > 1 ? () => _handlePageChange(widget.currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          
          // Page numbers
          ...List.generate(widget.totalPages, (index) {
            final page = index + 1; // Convert 0-based index to 1-based page
            final isCurrentPage = page == widget.currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: InkWell(
                onTap: () => _handlePageChange(page),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: isCurrentPage ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ) : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '$page',
                      style: TextStyle(
                        fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          
          // Next page button
          IconButton(
            onPressed: widget.currentPage < widget.totalPages ? () => _handlePageChange(widget.currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
