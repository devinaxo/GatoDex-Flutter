import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cat_service.dart';
import '../services/image_service.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';
import '../widgets/home/cat_view_container.dart';
import '../widgets/home/cat_details_modal.dart';
import '../utils/helpers.dart';
import 'edit_cat_screen.dart';
import 'add_cat_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CatService _catService = CatService();
  final ImageService _imageService = ImageService();
  List<Species> _species = [];
  List<FurPattern> _furPatterns = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isMosaicView = false;

  static const int _pageSize = 12;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoadingMore = false;
  int _totalCats = 0;

  final Map<int, List<Cat>> _preloadedPages = {};
  final Set<int> _loadingPages = {};
  static const int _preloadDistance = 2;

  // Search & filter state
  final _searchController = TextEditingController();
  String? _searchQuery;
  int? _filterSpeciesId;
  int? _filterFurPatternId;
  String? _filterDateFrom;
  String? _filterDateTo;
  bool _showFilters = false;

  bool get _hasActiveFilters =>
      (_searchQuery != null && _searchQuery!.isNotEmpty) ||
      _filterSpeciesId != null ||
      _filterFurPatternId != null ||
      _filterDateFrom != null ||
      _filterDateTo != null;

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<List<Cat>> _fetchCats({required int offset, required int limit}) {
    return _catService.getCatsFiltered(
      offset: offset,
      limit: limit,
      searchName: _searchQuery,
      speciesId: _filterSpeciesId,
      furPatternId: _filterFurPatternId,
      dateFrom: _filterDateFrom,
      dateTo: _filterDateTo,
    );
  }

  Future<int> _fetchCount() {
    return _catService.getCatsFilteredCount(
      searchName: _searchQuery,
      speciesId: _filterSpeciesId,
      furPatternId: _filterFurPatternId,
      dateFrom: _filterDateFrom,
      dateTo: _filterDateTo,
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final results = await Future.wait([
        _catService.getAllSpecies(),
        _catService.getAllFurPatterns(),
        _fetchCats(offset: 0, limit: _pageSize),
        _fetchCount(),
      ]);

      final species = results[0] as List<Species>;
      final furPatterns = results[1] as List<FurPattern>;
      final cats = results[2] as List<Cat>;
      final totalCats = results[3] as int;

      setState(() {
        _species = species;
        _furPatterns = furPatterns;
        _totalCats = totalCats;
        _totalPages = (totalCats / _pageSize).ceil();
        _isLoading = false;
      });

      _preloadedPages.clear();
      _preloadedPages[1] = cats;
      _preloadAdjacentPages(1);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando datos: $e')));
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);

    try {
      final offset = (_currentPage - 1) * _pageSize;
      final results = await Future.wait([
        _catService.getAllSpecies(),
        _catService.getAllFurPatterns(),
        _fetchCats(offset: offset, limit: _pageSize),
        _fetchCount(),
      ]);

      final species = results[0] as List<Species>;
      final furPatterns = results[1] as List<FurPattern>;
      final cats = results[2] as List<Cat>;
      final totalCats = results[3] as int;

      setState(() {
        _species = species;
        _furPatterns = furPatterns;
        _totalCats = totalCats;
        _totalPages = (totalCats / _pageSize).ceil();
        _isRefreshing = false;
      });

      _preloadedPages.clear();
      _preloadedPages[_currentPage] = cats;
      _preloadAdjacentPages(_currentPage);
    } catch (e) {
      setState(() => _isRefreshing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error actualizando datos: $e')));
      }
    }
  }

  Future<void> _preloadAdjacentPages(int centerPage) async {
    _cleanupDistantPages(centerPage);
    for (int i = 1; i <= _preloadDistance; i++) {
      final prevPage = centerPage - i;
      if (prevPage >= 1 && !_preloadedPages.containsKey(prevPage) && !_loadingPages.contains(prevPage)) {
        _preloadPage(prevPage);
      }
      final nextPage = centerPage + i;
      if (nextPage <= _totalPages && !_preloadedPages.containsKey(nextPage) && !_loadingPages.contains(nextPage)) {
        _preloadPage(nextPage);
      }
    }
  }

  void _cleanupDistantPages(int centerPage) {
    final keysToRemove = <int>[];
    final maxDistance = _preloadDistance + 1;
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
      final cats = await _fetchCats(offset: (page - 1) * _pageSize, limit: _pageSize);
      _preloadedPages[page] = cats;
    } catch (_) {
    } finally {
      _loadingPages.remove(page);
    }
  }

  Future<void> _loadPage(int page) async {
    if (page < 1 || page > _totalPages) return;

    if (_preloadedPages.containsKey(page)) {
      setState(() => _currentPage = page);
      _preloadAdjacentPages(page);
      return;
    }

    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final cats = await _fetchCats(offset: (page - 1) * _pageSize, limit: _pageSize);
      setState(() {
        _currentPage = page;
        _isLoadingMore = false;
      });
      _preloadedPages[page] = cats;
      _preloadAdjacentPages(page);
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando página: $e')));
      }
    }
  }

  void _applyFilters() {
    _searchQuery = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();
    _clearPreloadedPagesAndReload();
  }

  void _clearAllFilters() {
    _searchController.clear();
    _searchQuery = null;
    _filterSpeciesId = null;
    _filterFurPatternId = null;
    _filterDateFrom = null;
    _filterDateTo = null;
    _clearPreloadedPagesAndReload();
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: _filterDateFrom != null ? DateTime.parse(_filterDateFrom!) : now.subtract(const Duration(days: 365)),
      end: _filterDateTo != null ? DateTime.parse(_filterDateTo!) : now,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: initialRange,
    );

    if (picked != null) {
      setState(() {
        _filterDateFrom = '${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}';
        _filterDateTo = '${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}';
      });
      _clearPreloadedPagesAndReload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Search bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    color: colorScheme.surfaceContainer,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Buscar por nombre...',
                                  prefixIcon: const Icon(Icons.search, size: 20),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            _applyFilters();
                                          },
                                        )
                                      : null,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                ),
                                onSubmitted: (_) => _applyFilters(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Badge(
                              isLabelVisible: _hasActiveFilters,
                              child: IconButton(
                                icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
                                tooltip: 'Filtros',
                                onPressed: () => setState(() => _showFilters = !_showFilters),
                              ),
                            ),
                          ],
                        ),
                        // Expandable filter section
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: _buildFilterSection(colorScheme),
                          crossFadeState: _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                  ),
                  // Stats header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.only(
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
                                '${_hasActiveFilters ? "Filtrado: " : ""}$_totalCats gatos • Página $_currentPage de $_totalPages',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, animation) {
                                return RotationTransition(turns: animation, child: FadeTransition(opacity: animation, child: child));
                              },
                              child: IconButton(
                                key: ValueKey(_isMosaicView ? 'list_icon' : 'grid_icon'),
                                icon: Icon(_isMosaicView ? Icons.list : Icons.grid_view),
                                tooltip: _isMosaicView ? 'Vista Lista' : 'Vista Mosaico',
                                onPressed: () {
                                  setState(() => _isMosaicView = !_isMosaicView);
                                  _saveViewPreference();
                                },
                              ),
                            ),
                            IconButton(
                              icon: _isRefreshing
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(colorScheme.primary)),
                                    )
                                  : const Icon(Icons.refresh),
                              tooltip: 'Actualizar',
                              onPressed: _isRefreshing ? null : _refreshData,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCat,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Species filter
              DropdownMenu<int?>(
                label: const Text('Especie'),
                width: 200,
                initialSelection: _filterSpeciesId,
                textStyle: const TextStyle(fontSize: 13),
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                dropdownMenuEntries: [
                  const DropdownMenuEntry(value: null, label: 'Todas'),
                  ..._species.map((s) => DropdownMenuEntry(value: s.id, label: s.name)),
                ],
                onSelected: (value) {
                  setState(() => _filterSpeciesId = value);
                  _clearPreloadedPagesAndReload();
                },
              ),
              // Fur pattern filter
              DropdownMenu<int?>(
                label: const Text('Patrón'),
                width: 200,
                initialSelection: _filterFurPatternId,
                textStyle: const TextStyle(fontSize: 13),
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                dropdownMenuEntries: [
                  const DropdownMenuEntry(value: null, label: 'Todos'),
                  ..._furPatterns.map((fp) => DropdownMenuEntry(value: fp.id, label: fp.name)),
                ],
                onSelected: (value) {
                  setState(() => _filterFurPatternId = value);
                  _clearPreloadedPagesAndReload();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.date_range, size: 16),
                label: Text(
                  _filterDateFrom != null && _filterDateTo != null
                      ? '${AppHelpers.formatDate(_filterDateFrom)} - ${AppHelpers.formatDate(_filterDateTo)}'
                      : 'Rango de fechas',
                ),
                onPressed: _selectDateRange,
              ),
              if (_filterDateFrom != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    setState(() {
                      _filterDateFrom = null;
                      _filterDateTo = null;
                    });
                    _clearPreloadedPagesAndReload();
                  },
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(maxWidth: 28, maxHeight: 28),
                ),
              ],
              const Spacer(),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Cat cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gato'),
        content: Text('¿Estás seguro de que quieres eliminar a ${cat.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await _imageService.deleteImage(cat.picturePath);
              await _catService.deleteCat(cat.id);
              Navigator.pop(context);
              _clearPreloadedPagesAndReload();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${cat.name} eliminado')));
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditCatScreen(cat: cat)));
    if (result == true) _clearPreloadedPagesAndReload();
  }

  Future<void> _navigateToAddCat() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddCatScreen()));
    if (result == true) _clearPreloadedPagesAndReload();
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
