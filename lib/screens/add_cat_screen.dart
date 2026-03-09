import 'package:flutter/material.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../services/cat_service.dart';
import '../widgets/forms/cat_form_widget.dart';

class AddCatScreen extends StatelessWidget {
  final CatService _catService = CatService();

  AddCatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCat)),
      body: CatFormWidget(
        saveButtonLabel: l10n.addCat,
        onSave: (cat, imagePath) async {
          await _catService.addCat(cat);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.catAddedSuccess(cat.name))),
            );
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}
