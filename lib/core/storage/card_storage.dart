import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_config.dart';

class CardStorage {
  static const _cardsKey = 'pixela_cards';
  static const _usernameKey = 'pixela_username';

  static Future<List<CardConfig>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_cardsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => CardConfig.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveCards(List<CardConfig> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardsKey, jsonEncode(cards.map((c) => c.toJson()).toList()));
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }
}
