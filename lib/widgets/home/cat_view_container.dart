import 'package:flutter/material.dart';
import '../../models/cat.dart';
import '../../models/species.dart';
import '../../models/fur_pattern.dart';
import 'cat_list_item.dart';
import 'cat_mosaic_item.dart';

class CatViewContainer extends StatelessWidget {
  final List<Cat> cats;
  final List<Species> species;
  final List<FurPattern> furPatterns;
  final bool isMosaicView;
  final Function(Cat) onCatTap;
  final Function(Cat) onEditCat;
  final Function(Cat) onDeleteCat;

  const CatViewContainer({
    Key? key,
    required this.cats,
    required this.species,
    required this.furPatterns,
    required this.isMosaicView,
    required this.onCatTap,
    required this.onEditCat,
    required this.onDeleteCat,
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
    if (cats.isEmpty) {
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

    return isMosaicView ? _buildMosaicView() : _buildListView();
  }

  Widget _buildListView() {
    return ListView.builder(
      key: ValueKey('list_view'),
      itemCount: cats.length,
      itemBuilder: (context, index) {
        final cat = cats[index];
        return CatListItem(
          cat: cat,
          speciesName: _getSpeciesName(cat.speciesId),
          furPatternName: _getFurPatternName(cat.furPatternId),
          onTap: () => onCatTap(cat),
          onEdit: () => onEditCat(cat),
          onDelete: () => onDeleteCat(cat),
        );
      },
    );
  }

  Widget _buildMosaicView() {
    return GridView.builder(
      key: ValueKey('mosaic_view'),
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
          onTap: () => onCatTap(cat),
          onEdit: () => onEditCat(cat),
          onDelete: () => onDeleteCat(cat),
        );
      },
    );
  }
}
