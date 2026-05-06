import 'package:uuid/uuid.dart';
import 'button_config.dart';

class CardConfig {
  final String id;
  final String graphId;
  final String displayName;
  final String emoji;
  final String color;
  final String unit;
  final String? timezone;
  final String? graphType;
  final List<ButtonConfig> buttons;

  CardConfig({
    String? id,
    required this.graphId,
    required this.displayName,
    this.emoji = '',
    required this.color,
    required this.unit,
    this.timezone,
    this.graphType,
    List<ButtonConfig>? buttons,
  })  : id = id ?? const Uuid().v4(),
        buttons = buttons ?? [];

  factory CardConfig.fromJson(Map<String, dynamic> json) {
    final tz = json['timezone'] as String?;
    return CardConfig(
      id: json['id'] as String,
      graphId: json['graphId'] as String,
      displayName: json['displayName'] as String,
      emoji: json['emoji'] as String? ?? '',
      color: json['color'] as String,
      unit: json['unit'] as String,
      timezone: (tz != null && tz.isNotEmpty) ? tz : null,
      graphType: json['graphType'] as String?,
      buttons: (json['buttons'] as List<dynamic>)
          .map((b) => ButtonConfig.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'graphId': graphId,
        'displayName': displayName,
        'emoji': emoji,
        'color': color,
        'unit': unit,
        'timezone': timezone,
        'graphType': graphType,
        'buttons': buttons.map((b) => b.toJson()).toList(),
      };

  CardConfig copyWith({
    String? graphId,
    String? displayName,
    String? emoji,
    String? color,
    String? unit,
    String? timezone,
    String? graphType,
    List<ButtonConfig>? buttons,
  }) {
    return CardConfig(
      id: id,
      graphId: graphId ?? this.graphId,
      displayName: displayName ?? this.displayName,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      unit: unit ?? this.unit,
      timezone: timezone ?? this.timezone,
      graphType: graphType ?? this.graphType,
      buttons: buttons ?? this.buttons,
    );
  }
}
