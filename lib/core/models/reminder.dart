class Reminder {
  const Reminder({
    required this.id,
    required this.hour,
    required this.minute,
    this.enabled = true,
  });

  final int id;
  final int hour;
  final int minute;
  final bool enabled;

  Reminder copyWith({int? hour, int? minute, bool? enabled}) => Reminder(
    id: id,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    enabled: enabled ?? this.enabled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': hour,
    'minute': minute,
    'enabled': enabled,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'] as int,
    hour: json['hour'] as int,
    minute: json['minute'] as int,
    enabled: json['enabled'] as bool? ?? true,
  );
}
