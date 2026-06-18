import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'pixela_token';
  static const _debugFallbackKey = 'pixela_token_debug_fallback';

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } on PlatformException catch (error) {
      if (!_canUseDebugFallback(error)) rethrow;
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_debugFallbackKey);
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } on PlatformException catch (error) {
      if (!_canUseDebugFallback(error)) rethrow;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_debugFallbackKey, token);
    }
  }

  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } on PlatformException catch (error) {
      if (!_canUseDebugFallback(error)) rethrow;
    }
    if (kDebugMode && defaultTargetPlatform == TargetPlatform.iOS) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_debugFallbackKey);
    }
  }

  static bool _canUseDebugFallback(PlatformException error) =>
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.iOS &&
      error.details == -34018;
}
