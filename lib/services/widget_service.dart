import 'dart:convert';
import 'package:home_widget/home_widget.dart';

import '../database/database_helper.dart';

/// Service responsible for syncing cat photo data to the home screen widget.
///
/// Data is stored via the home_widget package (SharedPreferences) so that the
/// native Android widget can read it directly. Widget updates are triggered
/// via [HomeWidget.updateWidget].
class WidgetService {
  static const String _androidWidgetProviderName = 'CatPhotoWidgetProvider';
  static const String _androidSmallWidgetProviderName = 'CatPhotoSmallWidgetProvider';
  static const String _iOSWidgetProviderName = 'CatPhotoWidget';

  // Keys used in home_widget SharedPreferences
  static const String _keyPhotoPaths = 'cat_photo_paths';
  static const String _keyCatNames = 'cat_photo_names';
  static const String _keyCatIds = 'cat_photo_ids';
  static const String _keyCurrentIndex = 'cat_photo_index';

  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// Syncs all cat photos to the widget storage and triggers widget updates.
  ///
  /// Call this whenever cats or photos are added, updated, or deleted.
  Future<void> syncPhotos() async {
    try {
      final db = DatabaseHelper();
      final cats = await db.getCats();

      final photoPaths = <String>[];
      final catNames = <String>[];
      final catIds = <int>[];

      for (final cat in cats) {
        for (final photo in cat.photos) {
          photoPaths.add(photo.photoPath);
          catNames.add(cat.name);
          catIds.add(cat.id);
        }
      }

      // Store data in home_widget SharedPreferences (readable by native code)
      await HomeWidget.saveWidgetData<String>(
        _keyPhotoPaths,
        jsonEncode(photoPaths),
      );
      await HomeWidget.saveWidgetData<String>(
        _keyCatNames,
        jsonEncode(catNames),
      );
      await HomeWidget.saveWidgetData<String>(
        _keyCatIds,
        jsonEncode(catIds),
      );

      // Trigger widget updates
      await HomeWidget.updateWidget(
        androidName: _androidWidgetProviderName,
        iOSName: _iOSWidgetProviderName,
      );
      await HomeWidget.updateWidget(
        androidName: _androidSmallWidgetProviderName,
        iOSName: _iOSWidgetProviderName,
      );
    } catch (e) {
      // Silently fail so widget sync never blocks the UI
      // ignore: avoid_print
      print('WidgetService sync error: $e');
    }
  }
}
