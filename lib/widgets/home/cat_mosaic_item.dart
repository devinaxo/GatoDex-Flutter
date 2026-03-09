import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../../models/cat.dart';
import '../../utils/helpers.dart';

class CatMosaicItem extends StatelessWidget {
  final Cat cat;
  final String speciesName;
  final String furPatternName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CatMosaicItem({
    Key? key,
    required this.cat,
    required this.speciesName,
    required this.furPatternName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  cat.picturePath != null
                      ? cat.picturePath!.startsWith('assets/')
                          ? Image.asset(cat.picturePath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(context))
                          : Image.file(File(cat.picturePath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(context))
                      : _buildPlaceholder(context),
                  Positioned(
                    top: 4, right: 4,
                    child: SizedBox(
                      width: 28, height: 28,
                      child: PopupMenuButton(
                        padding: EdgeInsets.zero,
                        icon: Container(
                          decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.more_vert, size: 16, color: Colors.white),
                        ),
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text(l10n.edit)])),
                          PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 16), SizedBox(width: 8), Text(l10n.delete, style: TextStyle(color: Colors.red))])),
                        ],
                        onSelected: (v) { if (v == 'edit') onEdit(); if (v == 'delete') onDelete(); },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(speciesName, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (cat.dateMet != null) ...[
                    const SizedBox(height: 1),
                    Text(AppHelpers.formatDate(cat.dateMet), style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)), maxLines: 1),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(child: Image.asset('assets/images/palico-neutral.png', width: 48, height: 48)),
    );
  }
}
