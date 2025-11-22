import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/birth_data.dart';

class ApiService {
    static const String baseUrl = 'https://astravedam-backend.onrender.com';
    // static const String baseUrl = 'http://localhost:3000';

  static Future<Map<String, dynamic>> calculateChart(BirthData birthData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/calculate-chart'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(birthData.toJson()),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to calculate chart: ${response.statusCode}');
    }
  }
}