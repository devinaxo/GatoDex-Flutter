import 'package:flutter/material.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../models/cat.dart';
import '../services/cat_service.dart';
import '../services/cat_data_notifier.dart';
import '../widgets/forms/cat_form_widget.dart';

class EditCatScreen extends StatelessWidget {
  final Cat cat;
  final CatService _catService = CatService();

  EditCatScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editCat)),
      body: CatFormWidget(
        initialCat: cat,
        saveButtonLabel: l10n.saveChanges,
        onSave: (updatedCat, imagePath) async {
          await _catService.updateCat(updatedCat);
          CatDataNotifier().notifyDataChanged();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.catUpdatedSuccess(updatedCat.name))),
            );
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}
