import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../../models/cat.dart';
import '../../utils/helpers.dart';

class CatListItem extends StatelessWidget {
  final Cat cat;
  final String breedName;
  final String furPatternName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CatListItem({
    Key? key,
    required this.cat,
    required this.breedName,
    required this.furPatternName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final photoPath = cat.primaryPhotoPath;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          radius: 25,
          child: photoPath != null
              ? ClipOval(
                  child: photoPath.startsWith('assets/')
                      ? Image.asset(photoPath, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildFallbackIcon(context))
                      : Image.file(File(photoPath), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildFallbackIcon(context)),
                )
              : _buildFallbackIcon(context),
        ),
        title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$breedName • $furPatternName', maxLines: 1, overflow: TextOverflow.ellipsis),
            if (cat.dateMet != null)
              Text(
                AppHelpers.formatDate(cat.dateMet),
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        onTap: onTap,
        trailing: SizedBox(
          width: 40,
          child: PopupMenuButton(
            padding: EdgeInsets.zero,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text(l10n.edit)])),
              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text(l10n.delete, style: TextStyle(color: Colors.red))])),
            ],
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return ClipOval(child: Image.asset('assets/images/palico-neutral.png', width: 50, height: 50, fit: BoxFit.cover));
  }
}
