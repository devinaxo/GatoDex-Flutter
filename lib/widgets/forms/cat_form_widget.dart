import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/cat.dart';
import '../../models/species.dart';
import '../../models/fur_pattern.dart';
import '../../services/cat_service.dart';
import '../../services/cat_name_api_service.dart';
import '../../services/image_service.dart';
import '../../utils/helpers.dart';
import 'location_picker_map.dart';

class CatFormWidget extends StatefulWidget {
  final Cat? initialCat;
  final String saveButtonLabel;
  final Future<void> Function(Cat cat, String? imagePath) onSave;

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

  List<Species> _species = [];
  List<FurPattern> _furPatterns = [];
  int? _selectedSpeciesId;
  int? _selectedFurPatternId;
  String? _selectedDate;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _imagePath;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isGeneratingName = false;

  bool get _isEditMode => widget.initialCat != null;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    final species = await _catService.getAllSpecies();
    final furPatterns = await _catService.getAllFurPatterns();

    setState(() {
      _species = species;
      _furPatterns = furPatterns;
      _isLoading = false;
    });

    if (_isEditMode) {
      final cat = widget.initialCat!;
      _nameController.text = cat.name;
      _selectedSpeciesId = cat.speciesId;
      _selectedFurPatternId = cat.furPatternId;
      _selectedDate = cat.dateMet;
      _selectedLatitude = cat.latitude;
      _selectedLongitude = cat.longitude;
      _imagePath = cat.picturePath;
    } else if (species.isNotEmpty) {
      _selectedSpeciesId = species.first.id;
    }
  }

  Future<void> _generateRandomName() async {
    setState(() => _isGeneratingName = true);
    try {
      final name = await CatNameApiService.getRandomCatName();
      _nameController.text = name;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generando nombre: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingName = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    bool hasPermission;
    if (source == ImageSource.camera) {
      hasPermission = await _imageService.requestCameraPermission(context);
    } else {
      hasPermission = await _imageService.requestGalleryPermission(context);
    }

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso denegado'), backgroundColor: Colors.red),
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
      setState(() => _imagePath = savedFile!.path);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = null);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpeciesId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una especie'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final cat = Cat(
        id: _isEditMode ? widget.initialCat!.id : 0,
        name: _nameController.text.trim(),
        speciesId: _selectedSpeciesId!,
        furPatternId: _selectedFurPatternId,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        dateMet: _selectedDate,
        picturePath: _imagePath,
      );

      await widget.onSave(cat, _imagePath);
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
            _buildSpeciesDropdown(),
            const SizedBox(height: 16),
            _buildFurPatternDropdown(),
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
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _imagePath!.startsWith('assets/')
                        ? Image.asset(_imagePath!, fit: BoxFit.cover)
                        : Image.file(File(_imagePath!), fit: BoxFit.cover),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('Toca para agregar foto', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
      ),
    );
  }

  Widget _buildNameField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Gato',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
            ),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Por favor ingresa un nombre' : null,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _isGeneratingName ? null : _generateRandomName,
          icon: _isGeneratingName
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.casino),
          tooltip: 'Generar nombre aleatorio',
        ),
      ],
    );
  }

  Widget _buildSpeciesDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedSpeciesId,
      decoration: const InputDecoration(
        labelText: 'Especie',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: _species.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
      onChanged: (value) => setState(() => _selectedSpeciesId = value),
      validator: (value) => value == null ? 'Por favor selecciona una especie' : null,
    );
  }

  Widget _buildFurPatternDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedFurPatternId,
      decoration: const InputDecoration(
        labelText: 'Patrón de Pelaje (Opcional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.palette),
      ),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('Sin Patrón')),
        ..._furPatterns.map((fp) => DropdownMenuItem(value: fp.id, child: Text(fp.name))),
      ],
      onChanged: (value) => setState(() => _selectedFurPatternId = value),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de Encuentro (Opcional)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null ? AppHelpers.formatDate(_selectedDate) : 'Seleccionar fecha',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Ubicación (Opcional)',
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
            'Ubicación: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return FilledButton.icon(
      onPressed: _isSaving ? null : _save,
      icon: _isSaving
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.save),
      label: Text(_isSaving ? 'Guardando...' : widget.saveButtonLabel),
      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
    );
  }
}

enum ImageSource { camera, gallery }
