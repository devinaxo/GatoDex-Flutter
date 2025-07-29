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

    return isMosaicView ? _buildMosaicView(context) : _buildListView(context);
  }

  Widget _buildListView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
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
          ),
        ),
        if (totalPages > 1) _buildPaginationControls(context),
      ],
    );
  }

  Widget _buildMosaicView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
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
          ),
        ),
        if (totalPages > 1) _buildPaginationControls(context),
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
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          
          // Page numbers
          ...List.generate(totalPages, (index) {
            final page = index + 1; // Convert 0-based index to 1-based page
            final isCurrentPage = page == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: InkWell(
                onTap: () => onPageChanged(page),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrentPage ? Theme.of(context).primaryColor : null,
                    border: Border.all(
                      color: isCurrentPage 
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '$page',
                      style: TextStyle(
                        color: isCurrentPage ? Colors.white : null,
                        fontWeight: isCurrentPage ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          
          // Next page button
          IconButton(
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
