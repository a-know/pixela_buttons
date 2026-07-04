import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/card_config.dart';

class WatchSyncService {
  static const _channel = MethodChannel('com.a-know.pixelaButtons/watch_sync');

  static Future<void> syncCards({
    required String? username,
    required List<CardConfig> cards,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    try {
      await _channel.invokeMethod<void>('syncCards', {
        'username': username ?? '',
        'cards': cards.map((card) => card.toJson()).toList(),
      });
    } on PlatformException catch (error) {
      debugPrint('Failed to sync cards to Apple Watch: $error');
    } on MissingPluginException {
      debugPrint('Watch sync channel is not available on this platform.');
    }
  }
}
