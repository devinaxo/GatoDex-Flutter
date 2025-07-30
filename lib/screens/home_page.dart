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
  List<Cat> _cats = [];
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
        _cats = cats;
        _species = species;
        _furPatterns = furPatterns;
        _totalCats = totalCats;
        _totalPages = (totalCats / _pageSize).ceil();
        _isLoading = false;
      });
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
        _cats = cats;
        _species = species;
        _furPatterns = furPatterns;
        _totalCats = totalCats;
        _totalPages = (totalCats / _pageSize).ceil();
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error actualizando datos: $e')));
    }
  }

  Future<void> _loadPage(int page) async {
    if (_isLoadingMore || page < 1 || page > _totalPages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final cats = await _catService.getCatsPaginated(
        offset: (page - 1) * _pageSize, // Convert 1-based page to 0-based offset
        limit: _pageSize
      );

      setState(() {
        _cats = cats;
        _currentPage = page;
        _isLoadingMore = false;
      });
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
                    color: Theme.of(context).colorScheme.surfaceVariant,
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
                    cats: _cats,
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
              _loadData();
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

  Future<void> _navigateToEditCat(Cat cat) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCatScreen(cat: cat)),
    );

    // If the edit was successful, reload the data
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToAddCat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCatScreen()),
    );

    // If the add was successful, reload the data
    if (result == true) {
      _loadData();
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
