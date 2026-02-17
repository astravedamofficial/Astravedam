// lib/constants.dart
class AppConstants {
  // API URLs
  static const String baseUrl = 'https://astravedam.onrender.com';
  // For local testing, uncomment this and comment the above
  // static const String baseUrl = 'http://localhost:3000';
  
  // Geoapify
  static const String geoapifyKey = '8185187c36e24029853d31ebe39daa14';
  
  // Storage Keys
  static const String anonymousIdKey = 'astravedam_user_id';
  static const String tokenKey = 'auth_jwt_token';
  static const String userKey = 'auth_user_data';
  
  // API Endpoints
  static const String healthEndpoint = '/api/health';
  static const String calculateChartEndpoint = '/api/calculate-chart';
  static const String chartsEndpoint = '/api/charts';
  static const String authMeEndpoint = '/api/auth/me';
  static const String googleAuthEndpoint = '/api/auth/google';
}