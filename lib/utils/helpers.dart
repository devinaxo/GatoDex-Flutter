import 'dart:io';

class AppHelpers {
  // Date formatting
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Fecha Desconocida';
    }
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }
  
  static String getCurrentDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  // Location formatting
  static String formatCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return 'Sin Ubicación';
    }
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
  
  // File operations
  static Future<bool> fileExists(String? path) async {
    if (path == null || path.isEmpty) return false;
    try {
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }
  
  static String getFileName(String path) {
    return path.split('/').last;
  }
  
  // Validation helpers
  static bool isValidLatitude(double? latitude) {
    if (latitude == null) return false;
    return latitude >= -90 && latitude <= 90;
  }
  
  static bool isValidLongitude(double? longitude) {
    if (longitude == null) return false;
    return longitude >= -180 && longitude <= 180;
  }
  
  static bool isValidCoordinates(double? latitude, double? longitude) {
    return isValidLatitude(latitude) && isValidLongitude(longitude);
  }
  
  // String helpers
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  // ID generation helper
  static int generateId() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}
