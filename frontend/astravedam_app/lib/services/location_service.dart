import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _apiKey = '8185187c36e24029853d31ebe39daa14';
  static const String _baseUrl = 'https://api.geoapify.com/v1/geocode/autocomplete';
  
  // This function gets location suggestions as user types
  static Future<List<LocationSuggestion>> getSuggestions(String query) async {
    // Don't search if query is too short
    if (query.isEmpty || query.length < 2) {
      return [];
    }
    
    try {
      print('🔍 Searching for: $query');
      
      // Call Geoapify API
      final response = await http.get(
        Uri.parse('$_baseUrl?text=$query&apiKey=$_apiKey&limit=5'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];
        
        // Convert API response to our LocationSuggestion objects
        return features.map((feature) {
          final properties = feature['properties'];
          final geometry = feature['geometry'];
          
          return LocationSuggestion(
            address: properties['formatted'],
            city: properties['city'] ?? properties['name'] ?? '',
            state: properties['state'] ?? '',
            country: properties['country'] ?? '',
            lat: geometry['coordinates'][1],
            lon: geometry['coordinates'][0],
          );
        }).toList();
      } else {
        print('❌ Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception: $e');
      return [];
    }
  }
}

// This class holds one location suggestion
class LocationSuggestion {
  final String address;  // Full address like "Mumbai, Maharashtra, India"
  final String city;      // Just the city name
  final String state;     // State/province
  final String country;   // Country
  final double lat;       // Latitude
  final double lon;       // Longitude
  
  LocationSuggestion({
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.lat,
    required this.lon,
  });
  
  // This is what displays in the dropdown
  String get displayName {
    if (state.isNotEmpty) {
      return '$city, $state, $country';
    } else {
      return '$city, $country';
    }
  }
}