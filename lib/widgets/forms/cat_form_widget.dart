import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../../models/cat.dart';
import '../../models/breed.dart';
import '../../models/fur_pattern.dart';
import '../../services/cat_service.dart';
import '../../services/cat_name_api_service.dart';
import '../../services/image_service.dart';
import '../../utils/helpers.dart';
import '../../utils/breed_fur_translations.dart';
import 'location_picker_map.dart';

class CatFormWidget extends StatefulWidget {
  final Cat? initialCat;
  final String saveButtonLabel;
  final Future<void> Function(Cat cat, List<String> photoPaths, List<String> aliases) onSave;

  const CatFormWidget({
    Key? key,
    this.initialCat,
    required this.saveButtonLabel,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CatFormWidget> createState() => _CatFormWidgetState();
}

class _CatFormWidgetState extends State<CatFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final CatService _catService = CatService();
  final ImageService _imageService = ImageService();

  List<Breed> _breeds = [];
  List<FurPattern> _furPatterns = [];
  int? _selectedBreedId;
  int? _selectedFurPatternId;
  String? _selectedDate;
  double? _selectedLatitude;
  double? _selectedLongitude;
  List<String> _photoPaths = [];
  List<TextEditingController> _aliasControllers = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isGeneratingName = false;

  static const int _maxPhotos = 5;

  bool get _isEditMode => widget.initialCat != null;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _aliasControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    final breeds = await _catService.getAllBreeds();
    final furPatterns = await _catService.getAllFurPatterns();

    setState(() {
      _breeds = breeds;
      _furPatterns = furPatterns;
      _isLoading = false;
    });

    if (_isEditMode) {
      final cat = widget.initialCat!;
      _nameController.text = cat.name;
      _selectedBreedId = cat.breedId;
      _selectedFurPatternId = cat.furPatternId;
      _selectedDate = cat.dateMet;
      _selectedLatitude = cat.latitude;
      _selectedLongitude = cat.longitude;
      _photoPaths = cat.photos.map((p) => p.photoPath).toList();
      _aliasControllers = cat.aliases.map((a) => TextEditingController(text: a)).toList();
    } else if (breeds.isNotEmpty) {
      _selectedBreedId = breeds.first.id;
    }
  }

  Future<void> _generateRandomName() async {
    setState(() => _isGeneratingName = true);
    try {
      final name = await CatNameApiService.getRandomCatName();
      _nameController.text = name;
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneratingName(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingName = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photoPaths.length >= _maxPhotos) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.maxPhotosReached), backgroundColor: Colors.orange),
      );
      return;
    }

    bool hasPermission;
    if (source == ImageSource.camera) {
      hasPermission = await _imageService.requestCameraPermission(context);
    } else {
      hasPermission = await _imageService.requestGalleryPermission(context);
    }

    if (!hasPermission) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.permissionDenied), backgroundColor: Colors.red),
        );
      }
      return;
    }

    File? savedFile;
    if (source == ImageSource.camera) {
      savedFile = await _imageService.pickFromCamera();
    } else {
      savedFile = await _imageService.pickFromGallery();
    }

    if (savedFile != null && mounted) {
      setState(() => _photoPaths.add(savedFile!.path));
    }
  }

  void _showImagePickerOptions() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate != null ? DateTime.tryParse(_selectedDate!) ?? now : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _addAlias() {
    setState(() {
      _aliasControllers.add(TextEditingController());
    });
  }

  void _removeAlias(int index) {
    setState(() {
      _aliasControllers[index].dispose();
      _aliasControllers.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBreedId == null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectBreed), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final cat = Cat(
        id: _isEditMode ? widget.initialCat!.id : 0,
        name: _nameController.text.trim(),
        breedId: _selectedBreedId!,
        furPatternId: _selectedFurPatternId,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        dateMet: _selectedDate,
      );

      final aliases = _aliasControllers
          .map((c) => c.text.trim())
          .where((a) => a.isNotEmpty)
          .toList();

      await widget.onSave(cat, _photoPaths, aliases);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 24),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildBreedDropdown(),
            const SizedBox(height: 16),
            _buildFurPatternDropdown(),
            const SizedBox(height: 16),
            _buildAliasesSection(),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.photosLabel, style: Theme.of(context).textTheme.titleSmall),
            Text(l10n.photosCount(_photoPaths.length),
                style: TextStyle(
                  fontSize: 12,
                  color: _photoPaths.length >= _maxPhotos
                      ? Colors.orange
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                )),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._photoPaths.asMap().entries.map((entry) => _buildPhotoThumbnail(entry.key, entry.value)),
              if (_photoPaths.length < _maxPhotos) _buildAddPhotoButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(int index, String path) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: path.startsWith('assets/')
                ? Image.asset(path, width: 120, height: 120, fit: BoxFit.cover)
                : Image.file(File(path), width: 120, height: 120, fit: BoxFit.cover),
          ),
          // Order badge
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: index == 0 ? Theme.of(context).colorScheme.primary : Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                index == 0 ? '★' : '${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => _photoPaths.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(l10n.tapToAddPhoto,
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.catName,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
            ),
            validator: (value) => (value == null || value.trim().isEmpty) ? l10n.pleaseEnterName : null,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _isGeneratingName ? null : _generateRandomName,
          icon: _isGeneratingName
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.casino),
          tooltip: l10n.generateRandomName,
        ),
      ],
    );
  }

  Widget _buildBreedDropdown() {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<int>(
      value: _selectedBreedId,
      decoration: InputDecoration(
        labelText: l10n.breedLabel,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: _breeds.map((b) => DropdownMenuItem(
        value: b.id,
        child: Text(getLocalizedBreedName(context, b)),
      )).toList(),
      onChanged: (value) => setState(() => _selectedBreedId = value),
      validator: (value) => value == null ? l10n.pleaseSelectBreed : null,
    );
  }

  Widget _buildFurPatternDropdown() {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<int>(
      value: _selectedFurPatternId,
      decoration: InputDecoration(
        labelText: l10n.furPatternLabel,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.palette),
      ),
      items: [
        DropdownMenuItem<int>(value: null, child: Text(l10n.noPattern)),
        ..._furPatterns.map((fp) => DropdownMenuItem(
          value: fp.id,
          child: Text(getLocalizedFurPatternName(context, fp)),
        )),
      ],
      onChanged: (value) => setState(() => _selectedFurPatternId = value),
    );
  }

  Widget _buildAliasesSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.aliasesLabel, style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              onPressed: _addAlias,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addAlias),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        ..._aliasControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: l10n.aliasHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeAlias(index),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateField() {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.dateMetLabel,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null ? AppHelpers.formatDate(_selectedDate) : l10n.selectDate,
              style: TextStyle(
                color: _selectedDate != null ? null : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_selectedDate != null)
              GestureDetector(
                onTap: () => setState(() => _selectedDate = null),
                child: const Icon(Icons.clear, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.locationOptional,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        LocationPickerMap(
          initialLatitude: _selectedLatitude,
          initialLongitude: _selectedLongitude,
          onLocationSelected: (lat, lng) {
            setState(() {
              _selectedLatitude = lat;
              _selectedLongitude = lng;
            });
          },
        ),
        if (_selectedLatitude != null && _selectedLongitude != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.locationCoords(
              _selectedLatitude!.toStringAsFixed(6),
              _selectedLongitude!.toStringAsFixed(6),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context);
    return FilledButton.icon(
      onPressed: _isSaving ? null : _save,
      icon: _isSaving
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.save),
      label: Text(_isSaving ? l10n.saving : widget.saveButtonLabel),
      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
    );
  }
}

enum ImageSource { camera, gallery }
