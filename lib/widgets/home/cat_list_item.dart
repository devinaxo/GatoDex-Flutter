import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/cat.dart';

class CatListItem extends StatelessWidget {
  final Cat cat;
  final String speciesName;
  final String furPatternName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CatListItem({
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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          radius: 25,
          child: cat.picturePath != null
              ? ClipOval(
                  child: cat.picturePath!.startsWith('assets/')
                      ? Image.asset(
                          cat.picturePath!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pets,
                              color: Theme.of(context).colorScheme.primary,
                              size: 25,
                            );
                          },
                        )
                      : Image.file(
                          File(cat.picturePath!),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pets,
                              color: Theme.of(context).colorScheme.primary,
                              size: 25,
                            );
                          },
                        ),
                )
              : Icon(
                  Icons.pets,
                  color: Theme.of(context).colorScheme.primary,
                  size: 25,
                ),
        ),
        title: Text(
          cat.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Especie: $speciesName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Patrón: $furPatternName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: onTap,
        trailing: SizedBox(
          width: 40,
          child: PopupMenuButton(
            padding: EdgeInsets.zero,
            itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          ),
        ),
      ),
    );
  }
}
