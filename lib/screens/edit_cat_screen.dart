import 'package:flutter/material.dart';
import '../models/cat.dart';
import '../services/cat_service.dart';
import '../widgets/forms/cat_form_widget.dart';

class EditCatScreen extends StatelessWidget {
  final Cat cat;
  final CatService _catService = CatService();

  EditCatScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Gato')),
      body: CatFormWidget(
        initialCat: cat,
        saveButtonLabel: 'Guardar Cambios',
        onSave: (updatedCat, imagePath) async {
          await _catService.updateCat(updatedCat);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${updatedCat.name} actualizado exitosamente')),
            );
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}
