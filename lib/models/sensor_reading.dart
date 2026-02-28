class SensorReading {
  final DateTime timestamp;
  final double insideTemp;
  final double insideHumidity;
  final double outsideTemp;
  final double outsideHumidity;

  SensorReading({
    required this.timestamp,
    required this.insideTemp,
    required this.insideHumidity,
    required this.outsideTemp,
    required this.outsideHumidity,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
      insideTemp: double.parse(json['inside_temp']),
      insideHumidity: double.parse(json['inside_humidity']),
      outsideTemp: double.parse(json['outside_temp']),
      outsideHumidity: double.parse(json['outside_humidity']),
    );
  }
}
