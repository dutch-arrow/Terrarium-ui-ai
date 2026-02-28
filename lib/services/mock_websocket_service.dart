import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/event.dart';
import '../models/sensor_reading.dart';
import '../models/terrarium_config.dart';
import '../models/terrarium_status.dart';
import 'websocket_service_base.dart';

/// Mock WebSocket service for UI development without backend connection.
/// Simulates realistic terrarium data and responds to all commands.
class MockWebSocketService extends WebSocketServiceBase {
  bool _isConnected = true; // Start as connected in mock mode
  String? _error;
  bool _hasLoadedUrl = true;

  // Current simulated data
  TerrariumStatus? _currentStatus;
  TerrariumConfig? _currentConfig;
  List<TerrariumEvent>? _currentEvents;
  List<SensorReading>? _currentHistory;

  // Timers for simulated updates
  Timer? _statusTimer;

  // Mock state
  bool _paused = false;
  final Map<String, bool> _deviceStates = {
    'light1': true,
    'light2': true,
    'light3': false,
    'fan1': true,
    'fan2': false,
    'humidifier': false,
    'sprayer': false,
  };

  // Simulated sensor values with realistic variation
  double _insideTemp = 24.5;
  double _insideHumidity = 65.0;
  double _outsideTemp = 22.0;
  double _outsideHumidity = 55.0;

  final Random _random = Random();

  // Constructor - initialize mock data and start updates
  MockWebSocketService() {
    if (kDebugMode) {
      print('MockWebSocket: Initializing in mock mode (auto-connected)');
    }

    // Initialize mock config and status immediately
    _currentConfig = _generateMockConfig();
    _updateMockStatus();

    // Start periodic status updates
    _statusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (_isConnected) {
          _updateMockStatus();
        }
      },
    );
  }

  // Getters matching WebSocketService interface
  @override
  bool get isConnected => _isConnected;
  @override
  String? get error => _error;
  @override
  TerrariumStatus? get currentStatus => _currentStatus;
  @override
  TerrariumConfig? get currentConfig => _currentConfig;
  @override
  List<TerrariumEvent>? get currentEvents => _currentEvents;
  @override
  List<SensorReading>? get currentHistory => _currentHistory;
  @override
  String get serverUrl => 'mock://localhost';
  @override
  bool get hasLoadedUrl => _hasLoadedUrl;
  @override
  bool get isLoading => false; // Mock service doesn't track loading state

  @override
  Future<void> loadSavedUrl() async {
    // Mock implementation - nothing to load
    _hasLoadedUrl = true;
    notifyListeners();
  }

  @override
  Future<void> clearSavedUrl() async {
    // Mock implementation - nothing to clear
    notifyListeners();
  }

  @override
  Future<void> updateServerUrl(String url) async {
    // Mock implementation - just notify listeners
    if (kDebugMode) {
      print('MockWebSocket: updateServerUrl($url)');
    }
    notifyListeners();
  }

  @override
  Future<void> connect({String? url}) async {
    if (kDebugMode) {
      print(
          'MockWebSocket: connect() called (already auto-connected in mock mode)');
    }

    // In mock mode, we're always "connected" from initialization
    // Just ensure everything is set up
    if (!_isConnected) {
      _isConnected = true;
      _error = null;

      // Initialize mock config and status if not already done
      _currentConfig ??= _generateMockConfig();
      if (_currentStatus == null) {
        _updateMockStatus();
      }

      // Start periodic updates if not already running
      _statusTimer?.cancel();
      _statusTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) {
          if (_isConnected) {
            _updateMockStatus();
          }
        },
      );

      notifyListeners();
    }
  }

  @override
  Future<void> disconnect({bool clearCache = false}) async {
    _statusTimer?.cancel();
    _isConnected = false;
    _currentStatus = null;
    _currentConfig = null;
    notifyListeners();

    if (kDebugMode) {
      print('MockWebSocket: Disconnected');
    }
  }

  void _updateMockStatus() {
    // Add small random variations to sensor readings for realism
    _insideTemp += _random.nextDouble() * 0.4 - 0.2;
    _insideHumidity += _random.nextDouble() * 2.0 - 1.0;
    _outsideTemp += _random.nextDouble() * 0.3 - 0.15;
    _outsideHumidity += _random.nextDouble() * 1.5 - 0.75;

    // Keep values in realistic ranges
    _insideTemp = _insideTemp.clamp(22.0, 28.0);
    _insideHumidity = _insideHumidity.clamp(60.0, 80.0);
    _outsideTemp = _outsideTemp.clamp(18.0, 25.0);
    _outsideHumidity = _outsideHumidity.clamp(45.0, 65.0);

    _currentStatus = TerrariumStatus(
      timestamp: DateTime.now().toUtc(),
      paused: _paused,
      inside: SensorData(
        temperature: _insideTemp,
        humidity: _insideHumidity,
      ),
      outside: SensorData(
        temperature: _outsideTemp,
        humidity: _outsideHumidity,
      ),
      devices: DeviceStates(
        light1: DeviceState(state: _deviceStates['light1']!, reason: 'schedule'),
        light2: DeviceState(state: _deviceStates['light2']!, reason: 'schedule'),
        light3: DeviceState(state: _deviceStates['light3']!, reason: 'schedule'),
        humidifier: DeviceState(state: _deviceStates['humidifier']!, reason: 'regulation:humidity'),
        sprayer: DeviceState(state: _deviceStates['sprayer']!, reason: 'regulation:interval'),
        fan1: DeviceState(state: _deviceStates['fan1']!, reason: 'schedule'),
        fan2: DeviceState(state: _deviceStates['fan2']!, reason: 'schedule'),
      ),
    );

    notifyListeners();
  }

  TerrariumConfig _generateMockConfig() {
    return TerrariumConfig.fromJson({
      'control': {
        'lights': {
          'light1': {
            'name': 'Main Light',
            'schedule': {
              'on_time': '08:00',
              'off_time': '20:00',
            },
          },
          'light2': {
            'name': 'Secondary Light',
            'schedule': {
              'on_time': '09:00',
              'off_time': '19:00',
            },
          },
          'light3': {
            'name': 'UV Light',
            'schedule': {
              'on_time': '12:00',
              'off_time': '14:00',
            },
          },
        },
        'humidifier': {
          'min_humidity': 60.0,
          'max_humidity': 80.0,
        },
        'sprayer': {
          'spray_duration_seconds': 3.0,
          'spray_interval_hours': 2.0,
        },
        'sensors': {
          'read_interval_seconds': 5,
        },
      },
    });
  }

  // API Commands - all return immediately with simulated success

  @override
  Future<void> ping() async {
    if (kDebugMode) {
      print('MockWebSocket: ping');
    }
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> getStatus() async {
    if (kDebugMode) {
      print('MockWebSocket: getStatus');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    _updateMockStatus();
  }

  @override
  Future<void> getConfig() async {
    if (kDebugMode) {
      print('MockWebSocket: getConfig');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    _currentConfig = _generateMockConfig();
    notifyListeners();
  }

  @override
  Future<void> setLightSchedule(
      String light, String onTime, String offTime) async {
    if (kDebugMode) {
      print('MockWebSocket: setLightSchedule($light, $onTime, $offTime)');
    }
    await Future.delayed(const Duration(milliseconds: 200));

    // Update mock config
    if (_currentConfig != null) {
      // In a real implementation, we'd update the config object
      // For mock, we'll just trigger a refresh
      await getConfig();
    }
  }

  @override
  Future<void> setHumidityThresholds(
      double minHumidity, double maxHumidity) async {
    if (kDebugMode) {
      print('MockWebSocket: setHumidityThresholds($minHumidity, $maxHumidity)');
    }
    await Future.delayed(const Duration(milliseconds: 200));
    await getConfig();
  }

  @override
  Future<void> setSprayerConfig(
      double durationSeconds, double intervalHours) async {
    if (kDebugMode) {
      print(
          'MockWebSocket: setSprayerConfig($durationSeconds, $intervalHours)');
    }
    await Future.delayed(const Duration(milliseconds: 200));
    await getConfig();
  }

  @override
  Future<void> setSensorInterval(int intervalSeconds) async {
    if (kDebugMode) {
      print('MockWebSocket: setSensorInterval($intervalSeconds)');
    }
    await Future.delayed(const Duration(milliseconds: 200));
    await getConfig();
  }

  @override
  Future<void> getHistory({int limit = 100}) async {
    if (kDebugMode) {
      print('MockWebSocket: getHistory(limit: $limit)');
    }
    await Future.delayed(const Duration(milliseconds: 300));
    // Generate mock history data
    _currentHistory = [];
    notifyListeners();
  }

  @override
  Future<void> getEvents({int limit = 50}) async {
    if (kDebugMode) {
      print('MockWebSocket: getEvents(limit: $limit)');
    }
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate mock events
    _currentEvents = _generateMockEvents(limit);
    notifyListeners();
  }

  List<TerrariumEvent> _generateMockEvents(int limit) {
    final events = <TerrariumEvent>[];
    final now = DateTime.now().toUtc();

    // Generate mock device state change events
    final devices = ['light1', 'light2', 'light3', 'humidifier', 'sprayer', 'fan1', 'fan2'];
    final states = [true, false];
    final reasons = [
      'scheduled on',
      'scheduled off',
      'manual',
      'regulation:heating',
      'regulation:cooling',
      'regulation:humidity',
      'regulation:interval',
    ];

    for (int i = 0; i < limit; i++) {
      final device = devices[_random.nextInt(devices.length)];
      final state = states[_random.nextInt(states.length)];
      final reason = reasons[_random.nextInt(reasons.length)];
      final stateStr = state ? 'ON' : 'OFF';

      events.add(TerrariumEvent(
        timestamp: now.subtract(Duration(minutes: i * 5)),
        message: '$device: $stateStr ($reason)',
        device: device,
        state: state,
        reason: reason,
        type: 'device_state_change',
      ));
    }

    return events;
  }

  @override
  Future<void> testLightEntity(String light) async {
    if (kDebugMode) {
      print('MockWebSocket: testLightEntity($light)');
    }
    // Simulate test sequence: off -> on -> off -> restore
    await Future.delayed(const Duration(milliseconds: 500));
    final originalState = _deviceStates[light]!;

    _deviceStates[light] = false;
    _updateMockStatus();
    await Future.delayed(const Duration(seconds: 1));

    _deviceStates[light] = true;
    _updateMockStatus();
    await Future.delayed(const Duration(seconds: 2));

    _deviceStates[light] = false;
    _updateMockStatus();
    await Future.delayed(const Duration(seconds: 1));

    _deviceStates[light] = originalState;
    _updateMockStatus();
  }

  @override
  Future<void> testHumidifierEntity() async {
    if (kDebugMode) {
      print('MockWebSocket: testHumidifierEntity()');
    }
    await Future.delayed(const Duration(milliseconds: 500));
    final originalState = _deviceStates['humidifier']!;

    _deviceStates['humidifier'] = true;
    _updateMockStatus();
    await Future.delayed(const Duration(seconds: 3));

    _deviceStates['humidifier'] = originalState;
    _updateMockStatus();
  }

  @override
  Future<void> testSprayerEntity() async {
    if (kDebugMode) {
      print('MockWebSocket: testSprayerEntity()');
    }
    await Future.delayed(const Duration(milliseconds: 500));
    final originalState = _deviceStates['sprayer']!;

    _deviceStates['sprayer'] = true;
    _updateMockStatus();
    await Future.delayed(const Duration(seconds: 3));

    _deviceStates['sprayer'] = originalState;
    _updateMockStatus();
  }

  @override
  Future<void> testAllEntities() async {
    if (kDebugMode) {
      print('MockWebSocket: testAllEntities()');
    }
    await Future.delayed(const Duration(milliseconds: 500));

    // Test each entity in sequence
    await testLightEntity('light1');
    await testLightEntity('light2');
    await testLightEntity('light3');
    await testHumidifierEntity();
    await testSprayerEntity();
  }

  @override
  Future<void> setEntityState(String entity, bool state) async {
    if (kDebugMode) {
      print('MockWebSocket: setEntityState($entity, $state)');
    }
    await Future.delayed(const Duration(milliseconds: 150));

    _deviceStates[entity] = state;
    _updateMockStatus();
  }

  @override
  Future<void> toggleEntity(String entity) async {
    if (kDebugMode) {
      print('MockWebSocket: toggleEntity($entity)');
    }
    await Future.delayed(const Duration(milliseconds: 150));

    _deviceStates[entity] = !_deviceStates[entity]!;
    _updateMockStatus();
  }

  @override
  Future<void> pauseControlLoop() async {
    if (kDebugMode) {
      print('MockWebSocket: pauseControlLoop()');
    }
    await Future.delayed(const Duration(milliseconds: 150));

    _paused = true;
    _updateMockStatus();
  }

  @override
  Future<void> resumeControlLoop() async {
    if (kDebugMode) {
      print('MockWebSocket: resumeControlLoop()');
    }
    await Future.delayed(const Duration(milliseconds: 150));

    _paused = false;
    _updateMockStatus();
  }

  @override
  Future<void> setConfig(String section, Map<String, dynamic> config) async {
    if (kDebugMode) {
      print('MockWebSocket: setConfig($section, $config)');
    }
    await Future.delayed(const Duration(milliseconds: 150));
    // In mock mode, just pretend it worked
    notifyListeners();
  }

  @override
  Future<void> setTemperatureControl(Map<String, dynamic> config) async {
    await setConfig('temperature', config);
  }

  @override
  Future<void> setAlarmConfig(Map<String, dynamic> config) async {
    await setConfig('alarms', config);
  }

  @override
  Future<void> setEmailConfig(Map<String, dynamic> config) async {
    await setConfig('notifications', {'email': config});
  }

  @override
  Future<void> testEmail() async {
    if (kDebugMode) {
      print('MockWebSocket: testEmail()');
    }
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> getAlarmStatus() async {
    if (kDebugMode) {
      print('MockWebSocket: getAlarmStatus()');
    }
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
