import 'package:flutter/material.dart';
import '../services/cat_service.dart';
import '../widgets/forms/cat_form_widget.dart';

class AddCatScreen extends StatelessWidget {
  final CatService _catService = CatService();

  AddCatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Gato')),
      body: CatFormWidget(
        saveButtonLabel: 'Agregar Gato',
        onSave: (cat, imagePath) async {
          await _catService.addCat(cat);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${cat.name} agregado exitosamente')),
            );
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}
