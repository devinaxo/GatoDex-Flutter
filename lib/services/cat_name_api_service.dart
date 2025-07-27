import 'dart:convert';
import 'package:http/http.dart' as http;

class CatNameApiService {
  static const String _baseUrl = 'https://tools.estevecastells.com/api/cats/v1';
  
  /// Fetches a random cat name from the Cat Name API
  /// Returns a single random cat name
  static Future<String> getRandomCatName() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'GatoDex-Flutter/1.0',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> names = jsonDecode(response.body);
        if (names.isNotEmpty) {
          return names.first as String;
        } else {
          throw Exception('No names returned from API');
        }
      } else {
        throw Exception('Failed to fetch cat name: ${response.statusCode}');
      }
    } catch (e) {
      // Return a fallback name if API fails
      throw Exception('Error fetching cat name: $e');
    }
  }
  
  /// Fetches multiple random cat names
  /// [limit] - Number of names to fetch (max 1000)
  static Future<List<String>> getMultipleCatNames({int limit = 5}) async {
    try {
      // Ensure limit doesn't exceed API maximum
      final safeLimit = limit > 1000 ? 1000 : limit;
      
      final response = await http.get(
        Uri.parse('$_baseUrl?limit=$safeLimit'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'GatoDex-Flutter/1.0',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> names = jsonDecode(response.body);
        return names.cast<String>();
      } else {
        throw Exception('Failed to fetch cat names: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cat names: $e');
    }
  }
}
