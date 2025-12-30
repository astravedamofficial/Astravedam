import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/birth_data.dart';

class ApiService {
  // ✅ CORRECT PRODUCTION URL
  static const String baseUrl = 'https://astravedam.onrender.com';
  
// static const String baseUrl = 'http://localhost:3000';
  static Future<Map<String, dynamic>> calculateChart(BirthData birthData) async {
    try {
      print('📡 Sending to PRODUCTION backend: $baseUrl');
      print('📊 Birth data: ${birthData.toJson()}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/calculate-chart'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(birthData.toJson()),
      ).timeout(Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Chart calculated successfully!');
        return data;
      } else {
        print('❌ Server error: ${response.statusCode} - ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: Please check your connection');
    }
  }

  static Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(Duration(seconds: 10));
      
      print('❤️ Server health: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }
}