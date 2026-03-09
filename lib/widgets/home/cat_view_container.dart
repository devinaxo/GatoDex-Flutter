import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../../models/cat.dart';
import '../../models/breed.dart';
import '../../models/fur_pattern.dart';
import '../../utils/breed_fur_translations.dart';
import 'cat_list_item.dart';
import 'cat_mosaic_item.dart';

class CatViewContainer extends StatefulWidget {
  final Map<int, List<Cat>> preloadedPages;
  final List<Breed> breeds;
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
    required this.breeds,
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheCurrentPageImages());
  }

  @override
  void didUpdateWidget(CatViewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage && !_isPageChanging) {
      _animateToPage(widget.currentPage - 1);
    }
    if (oldWidget.preloadedPages != widget.preloadedPages) {
      _precacheCurrentPageImages();
    }
  }

  void _precacheCurrentPageImages() {
    final cats = widget.preloadedPages[widget.currentPage] ?? [];
    for (final cat in cats) {
      final photoPath = cat.primaryPhotoPath;
      if (photoPath != null && !photoPath.startsWith('assets/')) {
        final file = File(photoPath);
        if (file.existsSync()) {
          precacheImage(FileImage(file), context);
        }
      }
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
    final hasAnyCats = widget.preloadedPages.values.any((cats) => cats.isNotEmpty);
    
    if (!hasAnyCats) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/palico-failure.png', width: 80, height: 80),
            SizedBox(height: 16),
            Text(
              l10n.noCatsRegistered,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(l10n.addYourFirstCat),
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
              final newPage = pageIndex + 1;
              if (newPage != widget.currentPage && !_isPageChanging) {
                _triggerHapticFeedback();
                widget.onPageChanged(newPage);
              }
            },
            itemCount: widget.totalPages,
            itemBuilder: (context, pageIndex) {
              final pageNumber = pageIndex + 1;
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
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(l10n.loadingPage(pageNumber)),
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
          breedName: _getBreedName(cat.breedId),
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
          breedName: _getBreedName(cat.breedId),
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
          IconButton(
            onPressed: widget.currentPage > 1 ? () => _handlePageChange(widget.currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          
          ..._buildPaginationItems(context),
          
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
    
    if (widget.totalPages <= 5) {
      for (int i = 1; i <= widget.totalPages; i++) {
        items.add(_buildPageButton(context, i));
      }
    } else {
      items.add(_buildPageButton(context, 1));
      
      if (widget.currentPage <= 3) {
        items.add(_buildPageButton(context, 2));
        items.add(_buildPageButton(context, 3));
        items.add(_buildEllipsisButton(context));
        items.add(_buildPageButton(context, widget.totalPages));
      } else if (widget.currentPage >= widget.totalPages - 2) {
        items.add(_buildEllipsisButton(context));
        items.add(_buildPageButton(context, widget.totalPages - 2));
        items.add(_buildPageButton(context, widget.totalPages - 1));
        items.add(_buildPageButton(context, widget.totalPages));
      } else {
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
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.goToPage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.enterPageNumber(widget.totalPages)),
              const SizedBox(height: 16),
              TextField(
                controller: dialogController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.pageNumber,
                  border: const OutlineInputBorder(),
                  hintText: l10n.pageExample(widget.totalPages ~/ 2),
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
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                _jumpToPageFromDialog(dialogController.text);
                Navigator.of(context).pop();
              },
              child: Text(l10n.go),
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
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidPageNumber(widget.totalPages)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    HapticFeedback.lightImpact();
    _handlePageChange(page);
  }
}
