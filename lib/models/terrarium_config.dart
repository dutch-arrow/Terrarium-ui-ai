class TerrariumConfig {
  final ControlConfig control;

  TerrariumConfig({
    required this.control,
  });

  factory TerrariumConfig.fromJson(Map<String, dynamic> json) {
    return TerrariumConfig(
      control: ControlConfig.fromJson(json['control']),
    );
  }
}

class ControlConfig {
  final Map<String, LightConfig> lights;
  final HumidifierConfig humidifier;
  final SprayerConfig sprayer;
  final SensorConfig sensors;
  final TemperatureConfig temperature;
  final AlarmConfig alarms;
  final NotificationsConfig notifications;

  ControlConfig({
    required this.lights,
    required this.humidifier,
    required this.sprayer,
    required this.sensors,
    required this.temperature,
    required this.alarms,
    required this.notifications,
  });

  factory ControlConfig.fromJson(Map<String, dynamic> json) {
    final lightsJson = json['lights'] as Map<String, dynamic>;
    final lights = lightsJson.map(
      (key, value) => MapEntry(key, LightConfig.fromJson(value)),
    );

    // Provide defaults for new fields if not present (backward compatibility)
    final tempJson = json['temperature'] ?? {
      'target_temp': 24.0,
      'low_threshold': 22.0,
      'high_threshold': 26.0,
      'unit': 'C',
      'heating': {'enabled': true, 'method': 'intake_fan', 'fan_id': 'fan1'},
      'cooling': {
        'enabled': true,
        'escalation': {
          'step1_humidifier_duration_seconds': 10,
          'step2_humidifier_duration_seconds': 20,
          'step3_sprayer_duration_seconds': 20,
          'wait_interval_minutes': 10,
        }
      }
    };

    final alarmsJson = json['alarms'] ?? {
      'enabled': false,
      'temperature': {'high_alarm': 30.0, 'low_alarm': 18.0},
      'humidity': {'high_alarm': 90.0, 'low_alarm': 40.0},
      'sensor_failure_alarm': true,
      'cooldown_minutes': 30,
    };

    final notificationsJson = json['notifications'] ?? {
      'email': {
        'enabled': false,
        'smtp_server': 'smtp.gmail.com',
        'smtp_port': 587,
        'use_tls': true,
        'sender_email': '',
        'sender_password': '',
        'sender_name': 'Terrarium System',
        'recipient_email': '',
      }
    };

    return ControlConfig(
      lights: lights,
      humidifier: HumidifierConfig.fromJson(json['humidifier']),
      sprayer: SprayerConfig.fromJson(json['sprayer']),
      sensors: SensorConfig.fromJson(json['sensors']),
      temperature: TemperatureConfig.fromJson(tempJson),
      alarms: AlarmConfig.fromJson(alarmsJson),
      notifications: NotificationsConfig.fromJson(notificationsJson),
    );
  }
}

class LightConfig {
  final String name;
  final LightSchedule schedule;

  LightConfig({
    required this.name,
    required this.schedule,
  });

  factory LightConfig.fromJson(Map<String, dynamic> json) {
    return LightConfig(
      name: json['name'],
      schedule: LightSchedule.fromJson(json['schedule']),
    );
  }
}

class LightSchedule {
  final String onTime;
  final String offTime;

  LightSchedule({
    required this.onTime,
    required this.offTime,
  });

  factory LightSchedule.fromJson(Map<String, dynamic> json) {
    return LightSchedule(
      onTime: json['on_time'],
      offTime: json['off_time'],
    );
  }
}

class HumidifierConfig {
  final double minHumidity;
  final double maxHumidity;

  HumidifierConfig({
    required this.minHumidity,
    required this.maxHumidity,
  });

  factory HumidifierConfig.fromJson(Map<String, dynamic> json) {
    return HumidifierConfig(
      minHumidity: (json['min_humidity'] as num).toDouble(),
      maxHumidity: (json['max_humidity'] as num).toDouble(),
    );
  }
}

class SprayerConfig {
  final double sprayDurationSeconds;
  final double sprayIntervalHours;

  SprayerConfig({
    required this.sprayDurationSeconds,
    required this.sprayIntervalHours,
  });

  factory SprayerConfig.fromJson(Map<String, dynamic> json) {
    return SprayerConfig(
      sprayDurationSeconds: (json['spray_duration_seconds'] as num).toDouble(),
      sprayIntervalHours: (json['spray_interval_hours'] as num).toDouble(),
    );
  }
}

class SensorConfig {
  final int readIntervalSeconds;

  SensorConfig({
    required this.readIntervalSeconds,
  });

  factory SensorConfig.fromJson(Map<String, dynamic> json) {
    return SensorConfig(
      readIntervalSeconds: json['read_interval_seconds'] as int,
    );
  }
}

class TemperatureConfig {
  final double targetTemp;
  final double lowThreshold;
  final double highThreshold;
  final String unit;
  final HeatingConfig heating;
  final CoolingConfig cooling;

  TemperatureConfig({
    required this.targetTemp,
    required this.lowThreshold,
    required this.highThreshold,
    required this.unit,
    required this.heating,
    required this.cooling,
  });

  factory TemperatureConfig.fromJson(Map<String, dynamic> json) {
    return TemperatureConfig(
      targetTemp: (json['target_temp'] as num).toDouble(),
      lowThreshold: (json['low_threshold'] as num).toDouble(),
      highThreshold: (json['high_threshold'] as num).toDouble(),
      unit: json['unit'] as String,
      heating: HeatingConfig.fromJson(json['heating']),
      cooling: CoolingConfig.fromJson(json['cooling']),
    );
  }
}

class HeatingConfig {
  final bool enabled;
  final String method;
  final String fanId;

  HeatingConfig({
    required this.enabled,
    required this.method,
    required this.fanId,
  });

  factory HeatingConfig.fromJson(Map<String, dynamic> json) {
    return HeatingConfig(
      enabled: json['enabled'] as bool,
      method: json['method'] as String,
      fanId: json['fan_id'] as String,
    );
  }
}

class CoolingConfig {
  final bool enabled;
  final EscalationConfig escalation;

  CoolingConfig({
    required this.enabled,
    required this.escalation,
  });

  factory CoolingConfig.fromJson(Map<String, dynamic> json) {
    return CoolingConfig(
      enabled: json['enabled'] as bool,
      escalation: EscalationConfig.fromJson(json['escalation']),
    );
  }
}

class EscalationConfig {
  final int step1HumidifierDurationSeconds;
  final int step2HumidifierDurationSeconds;
  final int step3SprayerDurationSeconds;
  final int waitIntervalMinutes;

  EscalationConfig({
    required this.step1HumidifierDurationSeconds,
    required this.step2HumidifierDurationSeconds,
    required this.step3SprayerDurationSeconds,
    required this.waitIntervalMinutes,
  });

  factory EscalationConfig.fromJson(Map<String, dynamic> json) {
    return EscalationConfig(
      step1HumidifierDurationSeconds: json['step1_humidifier_duration_seconds'] as int,
      step2HumidifierDurationSeconds: json['step2_humidifier_duration_seconds'] as int,
      step3SprayerDurationSeconds: json['step3_sprayer_duration_seconds'] as int,
      waitIntervalMinutes: json['wait_interval_minutes'] as int,
    );
  }
}

class AlarmConfig {
  final bool enabled;
  final TemperatureAlarmConfig temperature;
  final HumidityAlarmConfig humidity;
  final bool sensorFailureAlarm;
  final int cooldownMinutes;

  AlarmConfig({
    required this.enabled,
    required this.temperature,
    required this.humidity,
    required this.sensorFailureAlarm,
    required this.cooldownMinutes,
  });

  factory AlarmConfig.fromJson(Map<String, dynamic> json) {
    return AlarmConfig(
      enabled: json['enabled'] as bool,
      temperature: TemperatureAlarmConfig.fromJson(json['temperature']),
      humidity: HumidityAlarmConfig.fromJson(json['humidity']),
      sensorFailureAlarm: json['sensor_failure_alarm'] as bool,
      cooldownMinutes: json['cooldown_minutes'] as int,
    );
  }
}

class TemperatureAlarmConfig {
  final double highAlarm;
  final double lowAlarm;

  TemperatureAlarmConfig({
    required this.highAlarm,
    required this.lowAlarm,
  });

  factory TemperatureAlarmConfig.fromJson(Map<String, dynamic> json) {
    return TemperatureAlarmConfig(
      highAlarm: (json['high_alarm'] as num).toDouble(),
      lowAlarm: (json['low_alarm'] as num).toDouble(),
    );
  }
}

class HumidityAlarmConfig {
  final double highAlarm;
  final double lowAlarm;

  HumidityAlarmConfig({
    required this.highAlarm,
    required this.lowAlarm,
  });

  factory HumidityAlarmConfig.fromJson(Map<String, dynamic> json) {
    return HumidityAlarmConfig(
      highAlarm: (json['high_alarm'] as num).toDouble(),
      lowAlarm: (json['low_alarm'] as num).toDouble(),
    );
  }
}

class NotificationsConfig {
  final EmailConfig email;

  NotificationsConfig({
    required this.email,
  });

  factory NotificationsConfig.fromJson(Map<String, dynamic> json) {
    return NotificationsConfig(
      email: EmailConfig.fromJson(json['email']),
    );
  }
}

class EmailConfig {
  final bool enabled;
  final String smtpServer;
  final int smtpPort;
  final bool useTls;
  final String senderEmail;
  final String senderPassword;
  final String senderName;
  final String recipientEmail;

  EmailConfig({
    required this.enabled,
    required this.smtpServer,
    required this.smtpPort,
    required this.useTls,
    required this.senderEmail,
    required this.senderPassword,
    required this.senderName,
    required this.recipientEmail,
  });

  factory EmailConfig.fromJson(Map<String, dynamic> json) {
    return EmailConfig(
      enabled: json['enabled'] as bool,
      smtpServer: json['smtp_server'] as String,
      smtpPort: json['smtp_port'] as int,
      useTls: json['use_tls'] as bool,
      senderEmail: json['sender_email'] as String,
      senderPassword: json['sender_password'] as String,
      senderName: json['sender_name'] as String,
      recipientEmail: json['recipient_email'] as String,
    );
  }
}
