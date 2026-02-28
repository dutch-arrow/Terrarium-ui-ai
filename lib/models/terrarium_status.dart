class TerrariumStatus {
  final DateTime timestamp;
  final bool paused;
  final SensorData inside;
  final SensorData outside;
  final DeviceStates devices;

  TerrariumStatus({
    required this.timestamp,
    required this.paused,
    required this.inside,
    required this.outside,
    required this.devices,
  });

  factory TerrariumStatus.fromJson(Map<String, dynamic> json) {
    return TerrariumStatus(
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
      paused: json['paused'] as bool? ?? false,
      inside: SensorData.fromJson(json['sensors']['inside']),
      outside: SensorData.fromJson(json['sensors']['outside']),
      devices: DeviceStates.fromJson(json['devices']),
    );
  }
}

class SensorData {
  final double temperature;
  final double humidity;

  SensorData({
    required this.temperature,
    required this.humidity,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
    );
  }
}

class DeviceStates {
  final DeviceState light1;
  final DeviceState light2;
  final DeviceState light3;
  final DeviceState humidifier;
  final DeviceState sprayer;
  final DeviceState fan1;
  final DeviceState fan2;

  DeviceStates({
    required this.light1,
    required this.light2,
    required this.light3,
    required this.humidifier,
    required this.sprayer,
    required this.fan1,
    required this.fan2,
  });

  factory DeviceStates.fromJson(Map<String, dynamic> json) {
    return DeviceStates(
      light1: DeviceState.fromJson(json['light1']),
      light2: DeviceState.fromJson(json['light2']),
      light3: DeviceState.fromJson(json['light3']),
      humidifier: DeviceState.fromJson(json['humidifier']),
      sprayer: DeviceState.fromJson(json['sprayer']),
      fan1: DeviceState.fromJson(json['fan1']),
      fan2: DeviceState.fromJson(json['fan2']),
    );
  }
}

class DeviceState {
  final bool state;
  final String reason;

  DeviceState({
    required this.state,
    required this.reason,
  });

  factory DeviceState.fromJson(dynamic json) {
    // Handle both old format (bool) and new format ({state: bool, reason: string})
    if (json is bool) {
      // Backward compatibility: old format was just a boolean
      return DeviceState(state: json, reason: '');
    } else if (json is Map) {
      return DeviceState(
        state: json['state'] as bool? ?? false,
        reason: json['reason'] as String? ?? '',
      );
    } else {
      // Fallback for null or unexpected format
      return DeviceState(state: false, reason: '');
    }
  }
}
