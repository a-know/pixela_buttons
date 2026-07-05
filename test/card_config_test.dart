import 'package:flutter_test/flutter_test.dart';
import 'package:pixela_buttons/core/models/card_config.dart';

void main() {
  test('fromJson accepts legacy cards without buttons', () {
    final card = CardConfig.fromJson({
      'id': 'card-1',
      'graphId': 'graph-1',
      'displayName': 'Graph 1',
      'emoji': '',
      'color': 'shibafu',
      'unit': 'times',
    });

    expect(card.id, 'card-1');
    expect(card.buttons, isEmpty);
  });
}
