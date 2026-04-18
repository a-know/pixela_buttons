import 'package:uuid/uuid.dart';

class ButtonConfig {
  final String id;
  final double value;

  ButtonConfig({String? id, required this.value}) : id = id ?? const Uuid().v4();

  factory ButtonConfig.fromJson(Map<String, dynamic> json) {
    return ButtonConfig(
      id: json['id'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'value': value};
}
