import 'package:flutter/material.dart';

/// Lightweight notifier that signals when cat data has been mutated
/// (add, edit, delete, import, bulk operations).
/// Screens displaying cat data listen to this and reload automatically.
class CatDataNotifier extends ChangeNotifier {
  static final CatDataNotifier _instance = CatDataNotifier._internal();
  factory CatDataNotifier() => _instance;
  CatDataNotifier._internal();

  void notifyDataChanged() {
    notifyListeners();
  }
}
