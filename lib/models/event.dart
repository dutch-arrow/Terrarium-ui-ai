class TerrariumEvent {
  final DateTime timestamp;
  final String message;
  final String? device;
  final bool? state;
  final String? reason;
  final String? type;

  TerrariumEvent({
    required this.timestamp,
    required this.message,
    this.device,
    this.state,
    this.reason,
    this.type,
  });

  factory TerrariumEvent.fromJson(Map<String, dynamic> json) {
    return TerrariumEvent(
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
      message: json['message'],
      device: json['device'] as String?,
      state: json['state'] as bool?,
      reason: json['reason'] as String?,
      type: json['type'] as String?,
    );
  }
}
