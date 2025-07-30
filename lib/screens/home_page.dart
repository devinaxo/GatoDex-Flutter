import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cat_service.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';
import '../widgets/home/cat_view_container.dart';
import '../widgets/home/cat_details_modal.dart';
import 'edit_cat_screen.dart';
import 'add_cat_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CatService _catService = CatService();
  List<Species> _species = [];
  List<FurPattern> _furPatterns = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isMosaicView = false;
  
  // Pagination variables
  static const int _pageSize = 12;
  int _currentPage = 1; // changed to 1-based indexing for ui reasons
  int _totalPages = 0;
  bool _isLoadingMore = false;
  int _totalCats = 0;
  
  // Preloading system
  final Map<int, List<Cat>> _preloadedPages = {};
  final Set<int> _loadingPages = {};
  static const int _preloadDistance = 2; // Number of pages to preload ahead and behind

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    _loadData();
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMosaicView = prefs.getBool('is_mosaic_view') ?? false;
    });
  }

  Future<void> _saveViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_mosaic_view', _isMosaicView);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1; // changed to 1-based indexing for ui reasons
    });

    try {
      final species = await _catService.getAllSpecies();
      final furPatterns = await _catService.getAllFurPatterns();
      
      // Load first page of cats and total count
      final cats = await _catService.getCatsPaginated(offset: 0, limit: _pageSize);
      final totalCats = await _catService.getCatsCount();

      setState(() {
        _species = species;
        _furPatterns = furPatterns;
        _totalCats = totalCats;
        _totalPages = (totalCats / _pageSize).ceil();
        _isLoading = false;
      });
      
      // Clear preloaded pages and cache the current page
      _preloadedPages.clear();
      _preloadedPages[1] = cats;
      
      // Preload adjacent pages
      _preloadAdjacentPages(1);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando datos: $e')));
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final species = await _catService.getAllSpecies();
      final furPatterns = await _catService.getAllFurPatterns();
      
      final offset = (_currentPage - 1) * _pageSize;
      final cats = await _catService.getCatsPaginated(offset: offset, limit: _pageSize);
      final totalCats = await _catService.getCatsCount();

      setState(() {
        _species = species;
        _furPatterns = furPatterns;
        _totalCats = totalCats;
        _totalPages = (totalCats / _pageSize).ceil();
        _isRefreshing = false;
      });
      
      // Clear preloaded pages and cache the current page
      _preloadedPages.clear();
      _preloadedPages[_currentPage] = cats;
      
      // Preload adjacent pages
      _preloadAdjacentPages(_currentPage);
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error actualizando datos: $e')));
    }
  }

  Future<void> _preloadAdjacentPages(int centerPage) async {
    // Clean up pages that are too far from current page to free memory
    _cleanupDistantPages(centerPage);
    
    for (int i = 1; i <= _preloadDistance; i++) {
      // Preload previous pages
      final prevPage = centerPage - i;
      if (prevPage >= 1 && 
          !_preloadedPages.containsKey(prevPage) && 
          !_loadingPages.contains(prevPage)) {
        _preloadPage(prevPage);
      }
      
      // Preload next pages
      final nextPage = centerPage + i;
      if (nextPage <= _totalPages && 
          !_preloadedPages.containsKey(nextPage) && 
          !_loadingPages.contains(nextPage)) {
        _preloadPage(nextPage);
      }
    }
  }

  void _cleanupDistantPages(int centerPage) {
    final keysToRemove = <int>[];
    final maxDistance = _preloadDistance + 1; // Keep one extra page beyond preload distance
    
    for (final pageNumber in _preloadedPages.keys) {
      if ((pageNumber - centerPage).abs() > maxDistance) {
        keysToRemove.add(pageNumber);
      }
    }
    
    for (final key in keysToRemove) {
      _preloadedPages.remove(key);
    }
  }

  Future<void> _preloadPage(int page) async {
    _loadingPages.add(page);
    
    try {
      final cats = await _catService.getCatsPaginated(
        offset: (page - 1) * _pageSize,
        limit: _pageSize
      );
      
      _preloadedPages[page] = cats;
    } catch (e) {
      // Silently fail preloading to avoid disrupting user experience
      print('Failed to preload page $page: $e');
    } finally {
      _loadingPages.remove(page);
    }
  }

  Future<void> _loadPage(int page) async {
    if (page < 1 || page > _totalPages) return;

    // Check if page is already preloaded for seamless transition
    if (_preloadedPages.containsKey(page)) {
      setState(() {
        _currentPage = page;
      });
      
      // Preload adjacent pages for the new current page
      _preloadAdjacentPages(page);
      return;
    }

    // Fallback: Load page if not preloaded
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final cats = await _catService.getCatsPaginated(
        offset: (page - 1) * _pageSize, // Convert 1-based page to 0-based offset
        limit: _pageSize
      );

      setState(() {
        _currentPage = page;
        _isLoadingMore = false;
      });
      
      // Cache this page and preload adjacent pages
      _preloadedPages[page] = cats;
      _preloadAdjacentPages(page);
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando página: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLoading && _totalCats > 0)
                            Text(
                              '$_totalCats gatos • Página $_currentPage de $_totalPages',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          if (_loadingPages.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Precargando páginas...',
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 350),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return RotationTransition(
                                turns: animation,
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
                            child: IconButton(
                              key: ValueKey(_isMosaicView ? 'list_icon' : 'grid_icon'),
                              icon: Icon(_isMosaicView ? Icons.list : Icons.grid_view),
                              tooltip: _isMosaicView ? 'List View' : 'Mosaic View',
                              onPressed: () {
                                setState(() {
                                  _isMosaicView = !_isMosaicView;
                                });
                                _saveViewPreference();
                              },
                            ),
                          ),
                          IconButton(
                            icon: _isRefreshing 
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  )
                                : Icon(Icons.refresh),
                            tooltip: 'Actualizar',
                            onPressed: _isRefreshing ? null : () {
                              _refreshData();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CatViewContainer(
                    preloadedPages: _preloadedPages,
                    species: _species,
                    furPatterns: _furPatterns,
                    isMosaicView: _isMosaicView,
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    isLoadingMore: _isLoadingMore,
                    onCatTap: _showCatDetailsModal,
                    onEditCat: _navigateToEditCat,
                    onDeleteCat: _showDeleteDialog,
                    onPageChanged: _loadPage,
                    enableSmoothTransitions: true,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddCat();
        },
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
              _clearPreloadedPagesAndReload();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('${cat.name} eliminado')));
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearPreloadedPagesAndReload() async {
    _preloadedPages.clear();
    _loadingPages.clear();
    await _loadData();
  }

  Future<void> _navigateToEditCat(Cat cat) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCatScreen(cat: cat)),
    );

    // If the edit was successful, reload the data
    if (result == true) {
      _clearPreloadedPagesAndReload();
    }
  }

  Future<void> _navigateToAddCat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCatScreen()),
    );

    // If the add was successful, reload the data
    if (result == true) {
      _clearPreloadedPagesAndReload();
    }
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

}
