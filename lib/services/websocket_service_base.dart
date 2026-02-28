import 'package:flutter/foundation.dart';
import '../models/terrarium_status.dart';
import '../models/terrarium_config.dart';
import '../models/sensor_reading.dart';
import '../models/event.dart';

/// Base class for WebSocket services (real and mock implementations)
abstract class WebSocketServiceBase extends ChangeNotifier {
  // Getters
  bool get isConnected;
  String? get error;
  TerrariumStatus? get currentStatus;
  TerrariumConfig? get currentConfig;
  List<TerrariumEvent>? get currentEvents;
  List<SensorReading>? get currentHistory;
  String get serverUrl;
  bool get hasLoadedUrl;
  bool get isLoading;

  // Connection management
  Future<void> loadSavedUrl();
  Future<void> clearSavedUrl();
  Future<void> updateServerUrl(String url);
  Future<void> connect({String? url});
  Future<void> disconnect({bool clearCache = false});

  // API Commands
  Future<void> ping();
  Future<void> getStatus();
  Future<void> getConfig();
  Future<void> setConfig(String section, Map<String, dynamic> config);
  Future<void> setLightSchedule(String light, String onTime, String offTime);
  Future<void> setHumidityThresholds(double minHumidity, double maxHumidity);
  Future<void> setSprayerConfig(double durationSeconds, double intervalHours);
  Future<void> setSensorInterval(int intervalSeconds);
  Future<void> setTemperatureControl(Map<String, dynamic> config);
  Future<void> setAlarmConfig(Map<String, dynamic> config);
  Future<void> setEmailConfig(Map<String, dynamic> config);
  Future<void> getHistory({int limit = 100});
  Future<void> getEvents({int limit = 50});
  Future<void> testLightEntity(String light);
  Future<void> testHumidifierEntity();
  Future<void> testSprayerEntity();
  Future<void> testAllEntities();
  Future<void> setEntityState(String entity, bool state);
  Future<void> toggleEntity(String entity);
  Future<void> pauseControlLoop();
  Future<void> resumeControlLoop();
  Future<void> testEmail();
  Future<void> getAlarmStatus();
}
