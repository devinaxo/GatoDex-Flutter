import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/cat.dart';
import '../../models/species.dart';
import '../../models/fur_pattern.dart';
import 'cat_list_item.dart';
import 'cat_mosaic_item.dart';

class CatViewContainer extends StatefulWidget {
  final Map<int, List<Cat>> preloadedPages; // Changed from single cats list to preloaded pages map
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
  final bool enableSmoothTransitions;

  const CatViewContainer({
    Key? key,
    required this.preloadedPages,
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
    this.enableSmoothTransitions = true,
  }) : super(key: key);

  @override
  State<CatViewContainer> createState() => _CatViewContainerState();
}

class _CatViewContainerState extends State<CatViewContainer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  bool _isPageChanging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.currentPage - 1,
    );
  }

  @override
  void didUpdateWidget(CatViewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage && !_isPageChanging) {
      _animateToPage(widget.currentPage - 1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int pageIndex) async {
    if (_pageController.hasClients && !_isPageChanging) {
      _isPageChanging = true;
      try {
        await _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      } finally {
        _isPageChanging = false;
      }
    }
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _handlePageChange(int newPage) {
    if (newPage != widget.currentPage && newPage >= 1 && newPage <= widget.totalPages) {
      _triggerHapticFeedback();
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
    final hasAnyCats = widget.preloadedPages.values.any((cats) => cats.isNotEmpty);
    
    if (!hasAnyCats) {
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

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (pageIndex) {
              final newPage = pageIndex + 1; // Convert back to 1-based indexing
              if (newPage != widget.currentPage && !_isPageChanging) {
                _triggerHapticFeedback();
                widget.onPageChanged(newPage);
              }
            },
            itemCount: widget.totalPages,
            itemBuilder: (context, pageIndex) {
              final pageNumber = pageIndex + 1; // Convert to 1-based indexing
              final cats = widget.preloadedPages[pageNumber] ?? [];
              
              if (cats.isEmpty) {
                return _buildLoadingPage(context, pageNumber);
              }
              
              return widget.isMosaicView 
                  ? _buildMosaicPageContent(context, cats)
                  : _buildListPageContent(context, cats);
            },
          ),
        ),
        if (widget.totalPages > 1) _buildPaginationControls(context),
      ],
    );
  }

  Widget _buildLoadingPage(BuildContext context, int pageNumber) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando página $pageNumber...'),
        ],
      ),
    );
  }

  Widget _buildListPageContent(BuildContext context, List<Cat> cats) {
    return ListView.builder(
      key: ValueKey('list_page_${widget.currentPage}'),
      itemCount: cats.length,
      itemBuilder: (context, index) {
        final cat = cats[index];
        return CatListItem(
          cat: cat,
          speciesName: _getSpeciesName(cat.speciesId),
          furPatternName: _getFurPatternName(cat.furPatternId),
          onTap: () => widget.onCatTap(cat),
          onEdit: () => widget.onEditCat(cat),
          onDelete: () => widget.onDeleteCat(cat),
        );
      },
    );
  }

  Widget _buildMosaicPageContent(BuildContext context, List<Cat> cats) {
    return GridView.builder(
      key: ValueKey('mosaic_page_${widget.currentPage}'),
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cats.length,
      itemBuilder: (context, index) {
        final cat = cats[index];
        return CatMosaicItem(
          cat: cat,
          speciesName: _getSpeciesName(cat.speciesId),
          furPatternName: _getFurPatternName(cat.furPatternId),
          onTap: () => widget.onCatTap(cat),
          onEdit: () => widget.onEditCat(cat),
          onDelete: () => widget.onDeleteCat(cat),
        );
      },
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
          
          // Smart pagination with ellipsis
          ..._buildPaginationItems(context),
          
          // Next page button
          IconButton(
            onPressed: widget.currentPage < widget.totalPages ? () => _handlePageChange(widget.currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPaginationItems(BuildContext context) {
    List<Widget> items = [];
    
    // If there are 5 or fewer pages, show all pages
    if (widget.totalPages <= 5) {
      for (int i = 1; i <= widget.totalPages; i++) {
        items.add(_buildPageButton(context, i));
      }
    } else {
      // Show smart pagination with ellipsis
      // Always show page 1
      items.add(_buildPageButton(context, 1));
      
      // Determine what to show in the middle
      if (widget.currentPage <= 3) {
        // Current page is near the beginning: 1 2 3 [...] last
        items.add(_buildPageButton(context, 2));
        items.add(_buildPageButton(context, 3));
        items.add(_buildEllipsisButton(context));
        items.add(_buildPageButton(context, widget.totalPages));
      } else if (widget.currentPage >= widget.totalPages - 2) {
        // Current page is near the end: 1 [...] n-2 n-1 n
        items.add(_buildEllipsisButton(context));
        items.add(_buildPageButton(context, widget.totalPages - 2));
        items.add(_buildPageButton(context, widget.totalPages - 1));
        items.add(_buildPageButton(context, widget.totalPages));
      } else {
        // Current page is in the middle: 1 [...] current [...] last
        items.add(_buildEllipsisButton(context));
        items.add(_buildPageButton(context, widget.currentPage));
        items.add(_buildEllipsisButton(context));
        items.add(_buildPageButton(context, widget.totalPages));
      }
    }
    
    return items;
  }

  Widget _buildPageButton(BuildContext context, int page) {
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
  }

  Widget _buildEllipsisButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: _showPageJumpDialog,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              '...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPageJumpDialog() {
    final TextEditingController dialogController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ir a página'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Introduce un número de página (1-${widget.totalPages}):'),
              const SizedBox(height: 16),
              TextField(
                controller: dialogController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Número de página',
                  border: const OutlineInputBorder(),
                  hintText: 'Ej: ${widget.totalPages ~/ 2}',
                ),
                onSubmitted: (value) {
                  _jumpToPageFromDialog(dialogController.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _jumpToPageFromDialog(dialogController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Ir'),
            ),
          ],
        );
      },
    );
  }

  void _jumpToPageFromDialog(String pageText) {
    if (pageText.isEmpty) return;
    
    final page = int.tryParse(pageText);
    if (page == null || page < 1 || page > widget.totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor introduce un número válido entre 1 y ${widget.totalPages}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    HapticFeedback.lightImpact();
    _handlePageChange(page);
  }
}
