import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_config.dart';

class CardStorage {
  static const _usernameKey = 'pixela_username';

  static String _cardsKey(String username) => 'pixela_cards_$username';

  static Future<List<CardConfig>> loadCards() async {
    final username = await getUsername();
    if (username == null || username.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_cardsKey(username));
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => CardConfig.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveCards(List<CardConfig> cards) async {
    final username = await getUsername();
    if (username == null || username.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _cardsKey(username), jsonEncode(cards.map((c) => c.toJson()).toList()));
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  static Future<void> clearUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
  }

  static const _localeKey = 'app_locale';

  static Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  static Future<void> saveLocale(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, languageCode);
    }
  }
}
