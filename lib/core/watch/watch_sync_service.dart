import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/card_config.dart';
import '../storage/secure_storage.dart';

class WatchSyncService {
  static const _channel = MethodChannel('com.a-know.pixelaButtons/watch_sync');

  static Future<void> syncCards({
    required String? username,
    required List<CardConfig> cards,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    try {
      final token = await SecureStorage.getToken();
      final hasSession =
          username != null &&
          username.isNotEmpty &&
          token != null &&
          token.isNotEmpty;
      await _channel.invokeMethod<void>('syncCards', {
        'username': hasSession ? username : '',
        'token': hasSession ? token : '',
        'cards': hasSession
            ? cards.map((card) => card.toJson()).toList()
            : const [],
      });
    } on PlatformException catch (error) {
      debugPrint('Failed to sync cards to Apple Watch: $error');
    } on MissingPluginException {
      debugPrint('Watch sync channel is not available on this platform.');
    }
  }
}
