import 'package:flutter/material.dart';
import '../services/cat_service.dart';
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';
import '../widgets/home/cat_view_container.dart';
import '../widgets/home/cat_details_modal.dart';
import 'edit_cat_screen.dart';
import 'settings_screen.dart';
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
  bool _isMosaicView = false;

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

      setState(() {
        _cats = cats;
        _species = species;
        _furPatterns = furPatterns;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('gatoDex'),
        actions: [
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
              },
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Actualizar'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'settings':
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                  break;
                case 'refresh':
                  _loadData();
                  break;
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CatViewContainer(
              cats: _cats,
              species: _species,
              furPatterns: _furPatterns,
              isMosaicView: _isMosaicView,
              onCatTap: _showCatDetailsModal,
              onEditCat: _navigateToEditCat,
              onDeleteCat: _showDeleteDialog,
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
