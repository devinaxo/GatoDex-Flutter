import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/cat.dart';
import '../models/species.dart';
import '../models/fur_pattern.dart';
import '../services/cat_service.dart';
import '../services/cat_name_api_service.dart';
import '../widgets/location_picker_map.dart';

class AddCatScreen extends StatefulWidget {
  const AddCatScreen({Key? key}) : super(key: key);

  @override
  _AddCatScreenState createState() => _AddCatScreenState();
}

class _AddCatScreenState extends State<AddCatScreen> {
  final _formKey = GlobalKey<FormState>();
  final CatService _catService = CatService();
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Form data
  int? _selectedSpeciesId;
  int? _selectedFurPatternId;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedImagePath;
  DateTime? _selectedDate;

  // Data lists
  List<Species> _species = [];
  List<FurPattern> _furPatterns = [];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isFetchingName = false; // Track dice button loading state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final species = await _catService.getAllSpecies();
      final furPatterns = await _catService.getAllFurPatterns();

      setState(() {
        _species = species;
        _furPatterns = furPatterns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error cargando datos: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _generateRandomName() async {
    setState(() {
      _isFetchingName = true;
    });

    try {
      final randomName = await CatNameApiService.getRandomCatName();
      setState(() {
        _nameController.text = randomName;
        _isFetchingName = false;
      });
      
      // Show a subtle feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Nombre generado: $randomName!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isFetchingName = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo generar un nombre. Verifica tu conexión.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _dateController.clear();
    });
  }

  Future<void> _pickImage() async {
    try {
      // Show image source selection
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        // Check permissions based on source
        if (source == ImageSource.camera) {
          var cameraStatus = await Permission.camera.status;
          if (cameraStatus.isDenied) {
            cameraStatus = await Permission.camera.request();
          }
          
          if (!cameraStatus.isGranted) {
            _showError('Se necesita permiso de cámara para tomar fotos');
            return;
          }
        } else if (source == ImageSource.gallery) {
          // Check storage/photos permission
          try {
            // For Android 13+ (API 33+), use photos permission
            // For older versions, use storage permission
            Permission storagePermission = Permission.photos;
            var status = await storagePermission.status;
            if (status.isDenied) {
              status = await storagePermission.request();
            }
            
            // Fallback to storage permission if photos permission fails
            if (!status.isGranted) {
              storagePermission = Permission.storage;
              status = await storagePermission.status;
              if (status.isDenied) {
                status = await storagePermission.request();
              }
            }
            
            if (!status.isGranted) {
              _showError('Se necesita permiso de almacenamiento para acceder a las fotos');
              return;
            }
          } catch (e) {
            // If permission checking fails, try without permission check
            print('Permission check failed: $e');
          }
        }
        
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (image != null) {
          // Copy image to app directory
          final String newPath = await _saveImageToAppDirectory(image.path);
          setState(() {
            _selectedImagePath = newPath;
          });
        }
      }
    } catch (e) {
      // Handle permission or other errors gracefully
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        _showError('Se necesitan permisos para acceder a la cámara o galería. Por favor, otorga los permisos en la configuración de la app.');
      } else {
        _showError('Error seleccionando imagen: $e');
      }
    }
  }

  Future<String> _saveImageToAppDirectory(String imagePath) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = 'cat_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String newPath = path.join(appDir.path, fileName);
    
    await File(imagePath).copy(newPath);
    return newPath;
  }

  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  Future<void> _saveCat() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final catId = await _catService.getNextCatId();
      
      final newCat = Cat(
        id: catId,
        name: _nameController.text.trim(),
        speciesId: _selectedSpeciesId!,
        furPatternId: _selectedFurPatternId,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        dateMet: _selectedDate?.toIso8601String().split('T')[0],
        picturePath: _selectedImagePath,
      );

      await _catService.addCat(newCat);

      Navigator.pop(context, true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newCat.name} agregado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Error guardando gato: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Agregar Gato'),
          backgroundColor: Colors.orange,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Nuevo Gato'),
        backgroundColor: Colors.orange,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveCat,
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo section
              _buildPhotoSection(),
              SizedBox(height: 24),

              // Name field with dice button
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Gato',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 56, // Match TextFormField height
                    child: ElevatedButton(
                      onPressed: _isFetchingName ? null : _generateRandomName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: _isFetchingName
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              Icons.casino,
                              size: 24,
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Species dropdown
              DropdownButtonFormField<int>(
                value: _selectedSpeciesId,
                decoration: InputDecoration(
                  labelText: 'Especie',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _species.map((species) {
                  return DropdownMenuItem<int>(
                    value: species.id,
                    child: Text(species.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpeciesId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona una especie';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Fur pattern dropdown
              DropdownButtonFormField<int?>(
                value: _selectedFurPatternId,
                decoration: InputDecoration(
                  labelText: 'Patrón de Pelaje (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sin patrón específico'),
                  ),
                  ..._furPatterns.map((pattern) {
                    return DropdownMenuItem<int?>(
                      value: pattern.id,
                      child: Text(pattern.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFurPatternId = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Date field
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Fecha de Encuentro (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: _selectedDate != null
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: _clearDate,
                        )
                      : null,
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
              SizedBox(height: 24),

              // Location section
              _buildLocationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto del Gato',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200, width: 2),
                color: Colors.orange.shade50,
              ),
              child: _selectedImagePath != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _selectedImagePath!.startsWith('assets/')
                              ? Image.asset(
                                  _selectedImagePath!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImagePath!),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildPlaceholderImage(),
            ),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            'Toca para agregar foto',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 200,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 48,
            color: Colors.orange.shade400,
          ),
          SizedBox(height: 8),
          Text(
            'Agregar Foto',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación donde se encontró (Opcional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
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
        if (_selectedLatitude != null && _selectedLongitude != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Coordenadas: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}
