import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'dart:math';  // ADD THIS LINE for Random class

class IdentityService {
  static const String _userIdKey = 'astravedam_user_id';
  
  // Get current identity (handles both anonymous and logged-in)
  static Future<Map<String, dynamic>> getIdentity() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    
    if (isLoggedIn) {
      // Registered user
      final userData = await AuthService.getUserData();
      return {
        'type': 'registered',
        'id': userData?['_id']?.toString(),
        'email': userData?['email'],
        'name': userData?['name'],
        'credits': userData?['credits'] ?? 0,
        'token': await AuthService.getToken(),
      };
    } else {
      // Anonymous user
      final anonId = await _getOrCreateAnonymousId();
      return {
        'type': 'anonymous',
        'id': anonId,
        'email': null,
        'name': null,
        'credits': 0,
        'token': null,
      };
    }
  }
  
  // Get user ID for API calls (automatically chooses right one)
  static Future<String> getUserIdForApi() async {
    final identity = await getIdentity();
    return identity['id']!;
  }
  
  // Check if user has enough credits
  static Future<bool> hasEnoughCredits(int requiredCredits) async {
    final identity = await getIdentity();
    
    if (identity['type'] == 'anonymous') {
      return false; // Anonymous users can't use paid features
    }
    
    final currentCredits = identity['credits'] ?? 0;
    return currentCredits >= requiredCredits;
  }
  
  // Get credits balance
  static Future<int> getCreditsBalance() async {
    final identity = await getIdentity();
    return identity['credits'] ?? 0;
  }
  
  // Private: Get or create anonymous ID
  static Future<String> _getOrCreateAnonymousId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingId = prefs.getString(_userIdKey);
      
      if (existingId != null && existingId.isNotEmpty) {
        return existingId;
      }
      
      // Generate new ID: anon_timestamp_random
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = _generateRandomString(6);
      final newUserId = 'anon_${timestamp}_$random';
      
      await prefs.setString(_userIdKey, newUserId);
      return newUserId;
    } catch (e) {
      // Fallback
      return 'anon_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  // Clear anonymous ID (used when user registers)
  static Future<void> clearAnonymousId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
    } catch (e) {
      print('⚠️ Error clearing anonymous ID: $e');
    }
  }
  
  // Generate random string
  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length, 
        (_) => chars.codeUnitAt(random.nextInt(chars.length))
      )
    );
  }
}