import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  // Use a fallback for emulator if running locally, otherwise configure for physical device
  // Note: 10.0.2.2 is the default IP for Android Emulator to connect to host localhost.
  // In production, this would be a real domain or configured via env variables.
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000/api');

  static Future<Map<String, dynamic>> getMetrics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/metrics'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load metrics');
      }
    } catch (e) {
      print('API fallback used for metrics (is backend running?): $e');
      return {'total_lots': 0, 'total_weight_kg': 0};
    }
  }

  static Future<List<dynamic>> getPrices([String? materialCategoryId]) async {
    try {
      final url = materialCategoryId != null 
          ? '$baseUrl/prices?material_category_id=$materialCategoryId' 
          : '$baseUrl/prices';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load prices');
      }
    } catch (e) {
      print('API fallback used for prices: $e');
      return [
        {'name': 'PCB', 'price': 162, 'trend': 'UP'},
        {'name': 'CABLE', 'price': 310, 'trend': 'STABLE'},
        {'name': 'BATTERY', 'price': 52, 'trend': 'DOWN'}
      ];
    }
  }

  static Future<Map<String, dynamic>> classify(String lotId, String imagePath) async {
    try {
      // In a real app, we would use a MultipartRequest to upload the file.
      // For this MVP demo, we simply hit the endpoint (which might just trigger demo logic).
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/lots/$lotId/classify'));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return json.decode(respStr);
      } else {
        throw Exception('Classification failed');
      }
    } catch (e) {
      print('Classification error: $e');
      rethrow;
    }
  }
}
