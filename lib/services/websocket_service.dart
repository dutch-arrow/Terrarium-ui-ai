import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/event.dart';
import '../models/sensor_reading.dart';
import '../models/terrarium_config.dart';
import '../models/terrarium_status.dart';
import 'websocket_service_base.dart';

class WebSocketService extends WebSocketServiceBase {
  static const String _serverUrlKey = 'websocket_server_url';

  WebSocketChannel? _channel;
  String _serverUrl = 'ws://192.168.50.200:8765'; // Default, can be changed
  bool _isConnected = false;
  String? _error;
  bool _hasLoadedUrl = false;
  bool _isLoading = false;

  // Current data
  TerrariumStatus? _currentStatus;
  TerrariumConfig? _currentConfig;
  List<TerrariumEvent>? _currentEvents;
  List<SensorReading>? _currentHistory;

  // Timers for periodic updates
  Timer? _statusTimer;
  Timer? _pingTimer;

  // Getters
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
  String get serverUrl => _serverUrl;
  @override
  bool get hasLoadedUrl => _hasLoadedUrl;
  @override
  bool get isLoading => _isLoading;

  // Load saved URL from storage
  @override
  Future<void> loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_serverUrlKey);
    if (savedUrl != null) {
      _serverUrl = savedUrl;
      if (kDebugMode) {
        print('Loaded saved URL: $_serverUrl');
      }
    }
    _hasLoadedUrl = true;
    notifyListeners();
  }

  // Save URL to storage
  Future<void> _saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
    if (kDebugMode) {
      print('Saved URL to storage: $url');
    }
  }

  // Clear saved URL from storage
  @override
  Future<void> clearSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverUrlKey);
    _serverUrl = 'ws://192.168.50.200:8765'; // Reset to default
    if (kDebugMode) {
      print('Cleared saved URL');
    }
    notifyListeners();
  }

  // Update server URL and save to storage
  @override
  Future<void> updateServerUrl(String url) async {
    _serverUrl = url;
    await _saveUrl(url);
    if (kDebugMode) {
      print('Updated server URL: $url');
    }
    notifyListeners();
  }

  // Connect to WebSocket server
  @override
  Future<void> connect({String? url}) async {
    if (url != null) {
      _serverUrl = url;
    }

    try {
      if (kDebugMode) {
        print('Connecting to $_serverUrl...');
      }

      // Create a completer to track actual connection success
      final connectionCompleter = Completer<void>();
      var connectionVerified = false;

      _channel = WebSocketChannel.connect(
        Uri.parse(_serverUrl),
        // Add a connection timeout
      );

      if (kDebugMode) {
        print('WebSocket channel created, listening for messages...');
      }

      // Listen to messages
      _channel!.stream.listen(
        (message) {
          // First message received means connection is established
          if (!connectionVerified) {
            connectionVerified = true;
            if (!connectionCompleter.isCompleted) {
              connectionCompleter.complete();
            }
          }
          _handleMessage(message);
        },
        onError: (error) {
          if (kDebugMode) {
            print('WebSocket stream error: $error');
          }
          if (!connectionCompleter.isCompleted) {
            connectionCompleter.completeError(error);
          }
          _handleError('Connection error: $error');
        },
        onDone: () {
          if (kDebugMode) {
            print('WebSocket stream closed');
          }
          if (!connectionCompleter.isCompleted) {
            connectionCompleter.completeError('Connection closed before establishing');
          }
          _handleDisconnect();
        },
        cancelOnError: false, // Don't cancel on error, keep trying
      );

      // Send a ping to verify connection
      final request = {
        'command': 'ping',
        'params': {},
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };
      _channel!.sink.add(jsonEncode(request));

      // Wait for first message or error with timeout
      await connectionCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout - server did not respond');
        },
      );

      // Set connected state only after verification
      _isConnected = true;
      _error = null;

      // Save URL to storage for next session
      await _saveUrl(_serverUrl);

      notifyListeners();

      if (kDebugMode) {
        print('Connection established, sending initial requests...');
      }

      // Initial data fetch (don't await, let them complete in background)
      getStatus().catchError((e) {
        if (kDebugMode) {
          print('Initial getStatus failed: $e');
        }
      });

      getConfig().catchError((e) {
        if (kDebugMode) {
          print('Initial getConfig failed: $e');
        }
      });

      // Automatic status updates disabled - use manual refresh button instead
      // _statusTimer = Timer.periodic(
      //   const Duration(seconds: 5),
      //   (_) {
      //     if (_isConnected) {
      //       getStatus().catchError((e) {
      //         if (kDebugMode) {
      //           print('Periodic getStatus failed: $e');
      //         }
      //       });
      //     }
      //   },
      // );

      // Start ping heartbeat (every 30 seconds)
      _pingTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) {
          if (_isConnected) {
            ping().catchError((e) {
              if (kDebugMode) {
                print('Ping failed: $e');
              }
            });
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Connection exception: $e');
      }
      _handleError('Failed to connect: $e');
      rethrow; // Re-throw so caller knows connection failed
    }
  }

  // Disconnect from WebSocket
  @override
  Future<void> disconnect({bool clearCache = false}) async {
    _statusTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _currentStatus = null;
    _currentConfig = null;

    // Clear cached URL if requested
    if (clearCache) {
      await clearSavedUrl();
    }

    notifyListeners();
  }

  // Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      if (kDebugMode) {
        print('Received message: ${message.toString().substring(0, message.toString().length > 200 ? 200 : message.toString().length)}...');
      }

      final data = jsonDecode(message);

      if (data['status'] == 'error') {
        // Extract error message from error object
        if (data['error'] is Map) {
          final errorObj = data['error'] as Map;
          _error = errorObj['message'] as String? ?? 'Unknown error';
        } else {
          _error = data['error']?.toString() ?? 'Unknown error';
        }
        if (kDebugMode) {
          print('Server error: $_error');
        }
        notifyListeners();
        return;
      }

      // Clear error on successful response
      _error = null;

      // Handle different response types based on command
      // Note: We'd need to track request IDs to properly match responses
      // For simplicity, we'll update based on data structure

      if (data['data'] != null) {
        final responseData = data['data'];

        // Check if it's a status response
        if (responseData['sensors'] != null && responseData['devices'] != null) {
          if (kDebugMode) {
            print('Updating status from server');
          }
          _currentStatus = TerrariumStatus.fromJson(responseData);
        }

        // Check if it's a config response
        if (responseData['hardware'] != null && responseData['control'] != null) {
          if (kDebugMode) {
            print('Updating config from server');
          }
          _currentConfig = TerrariumConfig.fromJson(responseData);
        }

        // Check if it's an events response
        if (responseData['events'] != null && responseData['events'] is List) {
          if (kDebugMode) {
            print('Updating events from server');
          }
          _currentEvents = (responseData['events'] as List)
              .map((e) => TerrariumEvent.fromJson(e))
              .toList();
        }

        // Check if it's a history response
        if (responseData['readings'] != null && responseData['readings'] is List) {
          if (kDebugMode) {
            print('Updating history from server');
          }
          _currentHistory = (responseData['readings'] as List)
              .map((e) => SensorReading.fromJson(e))
              .toList();
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Message parsing error: $e');
      }
      _handleError('Failed to parse message: $e', disconnect: false);
    }
  }

  // Handle errors
  void _handleError(String error, {bool disconnect = true}) {
    _error = error;
    if (disconnect) {
      _isConnected = false;
      _statusTimer?.cancel();
      _pingTimer?.cancel();
    }
    notifyListeners();
  }

  // Handle disconnection
  void _handleDisconnect() {
    _isConnected = false;
    _statusTimer?.cancel();
    _pingTimer?.cancel();
    notifyListeners();
  }

  // Send command to server
  Future<Map<String, dynamic>> _sendCommand(String command, Map<String, dynamic> params) async {
    if (!_isConnected || _channel == null) {
      throw Exception('Not connected to server');
    }

    final request = {
      'command': command,
      'params': params,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    _channel!.sink.add(jsonEncode(request));

    // Note: In a production app, you'd want to implement proper request/response matching
    // using the 'id' field and return Futures that complete when the matching response arrives
    // For simplicity, we're just sending commands and letting the stream handler update state

    return {};
  }

  // Wrapper for commands with loading state
  Future<T> _withLoading<T>(Future<T> Function() command) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await command();
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // API Commands

  @override
  Future<void> ping() async {
    await _sendCommand('ping', {});
  }

  @override
  Future<void> getStatus() async {
    await _sendCommand('get_status', {});
  }

  @override
  Future<void> getConfig() async {
    await _sendCommand('get_config', {});
  }

  @override
  Future<void> setLightSchedule(String light, String onTime, String offTime) async {
    await _withLoading(() async {
      await _sendCommand('set_light_schedule', {
        'light': light,
        'on_time': onTime,
        'off_time': offTime,
      });
      // Refresh config after update
      await getConfig();
    });
  }

  @override
  Future<void> setHumidityThresholds(double minHumidity, double maxHumidity) async {
    await _withLoading(() async {
      await _sendCommand('set_humidity_thresholds', {
        'min_humidity': minHumidity,
        'max_humidity': maxHumidity,
      });
      // Refresh config after update
      await getConfig();
    });
  }

  @override
  Future<void> setSprayerConfig(double durationSeconds, double intervalHours) async {
    await _withLoading(() async {
      await _sendCommand('set_sprayer_config', {
        'spray_duration_seconds': durationSeconds,
        'spray_interval_hours': intervalHours,
      });
      // Refresh config after update
      await getConfig();
    });
  }

  @override
  Future<void> setSensorInterval(int intervalSeconds) async {
    await _withLoading(() async {
      await _sendCommand('set_sensor_interval', {
        'read_interval_seconds': intervalSeconds,
      });
      // Refresh config after update
      await getConfig();
    });
  }

  @override
  Future<void> getHistory({int limit = 100}) async {
    await _sendCommand('get_history', {'limit': limit});
  }

  @override
  Future<void> getEvents({int limit = 50}) async {
    await _sendCommand('get_events', {'limit': limit});
  }

  @override
  Future<void> testLightEntity(String light) async {
    await _sendCommand('test_light_entity', {'light': light});
  }

  @override
  Future<void> testHumidifierEntity() async {
    await _sendCommand('test_humidifier_entity', {});
  }

  @override
  Future<void> testSprayerEntity() async {
    await _sendCommand('test_sprayer_entity', {});
  }

  @override
  Future<void> testAllEntities() async {
    await _sendCommand('test_all_entities', {});
  }

  // Manual entity control
  @override
  Future<void> setEntityState(String entity, bool state) async {
    await _withLoading(() async {
      await _sendCommand('set_entity_state', {
        'entity': entity,
        'state': state,
      });
      // Status will update automatically via WebSocket
      await getStatus();
    });
  }

  @override
  Future<void> toggleEntity(String entity) async {
    await _withLoading(() async {
      await _sendCommand('toggle_entity', {'entity': entity});
      // Status will update automatically via WebSocket
      await getStatus();
    });
  }

  // Control loop management
  @override
  Future<void> pauseControlLoop() async {
    await _withLoading(() async {
      await _sendCommand('pause_control_loop', {});
      // Refresh status to get updated paused state
      await getStatus();
    });
  }

  @override
  Future<void> resumeControlLoop() async {
    await _withLoading(() async {
      await _sendCommand('resume_control_loop', {});
      // Refresh status to get updated paused state
      await getStatus();
    });
  }

  @override
  Future<void> setConfig(String section, Map<String, dynamic> config) async {
    await _withLoading(() async {
      await _sendCommand('set_config', {
        'config': {section: config},
      });
      // Refresh config after update
      await getConfig();
    });
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
    await _sendCommand('test_email', {});
  }

  @override
  Future<void> getAlarmStatus() async {
    await _sendCommand('get_alarm_status', {});
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
