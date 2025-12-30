import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class UserIdService {
  static const String _userIdKey = 'astravedam_user_id';
  
  // Generate or get existing user ID
  static Future<String> getOrCreateUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingId = prefs.getString(_userIdKey);
      
      if (existingId != null && existingId.isNotEmpty) {
        print('📱 Using existing user ID: $existingId');
        return existingId;
      }
      
      // Generate new ID: anon_timestamp_random
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = _generateRandomString(6);
      final newUserId = 'anon_${timestamp}_$random';
      
      print('📱 Generated new user ID: $newUserId');
      await prefs.setString(_userIdKey, newUserId);
      
      return newUserId;
    } catch (e) {
      // Fallback if SharedPreferences fails
      print('⚠️ Error with SharedPreferences: $e');
      return 'anon_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  // Helper to generate random string
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
  
  // For debugging/testing
  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    print('📱 Cleared user ID');
  }
  
  // Get current ID without creating new one
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      return null;
    }
  }
}