import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/birth_data.dart';
import '../constants.dart';

class ApiService {
  // Use constant from AppConstants
  static String get baseUrl => AppConstants.baseUrl;
  
  // Check server health
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.healthEndpoint}'),
      ).timeout(Duration(seconds: 10));
      
      print('❤️ Server health: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  // Calculate birth chart
  static Future<Map<String, dynamic>> calculateChart(Map<String, dynamic> birthData, {String? token}) async {
    try {
      print('📡 Sending to backend: $baseUrl${AppConstants.calculateChartEndpoint}');
      
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.calculateChartEndpoint}'),
        headers: headers,
        body: json.encode(birthData),
      ).timeout(Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Server error: ${response.statusCode} - ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: Please check your connection');
    }
  }

  // Get user charts
  static Future<List<dynamic>> getUserCharts({String? anonymousId, String? token}) async {
    try {
      String url = '$baseUrl${AppConstants.chartsEndpoint}';
      
      // Add query param for anonymous users
      if (anonymousId != null) {
        url += '?userId=$anonymousId';
      }
      
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['charts'] ?? [];
      }
      
      return [];
    } catch (e) {
      print('❌ Error fetching charts: $e');
      return [];
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.authMeEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['user'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }
}