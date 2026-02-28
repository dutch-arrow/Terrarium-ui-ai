# Terrarium UI - WebSocket API Reference

## Table of Contents

1. [Overview](#overview)
2. [Connection](#connection)
3. [Message Format](#message-format)
4. [Timezone Handling](#timezone-handling)
5. [Commands](#commands)
   - [Status & Monitoring](#status--monitoring)
     - [get_status](#get_status)
     - [ping](#ping)
   - [Configuration](#configuration)
     - [get_config](#get_config)
     - [set_light_schedule](#set_light_schedule)
     - [set_humidity_thresholds](#set_humidity_thresholds)
     - [set_sprayer_config](#set_sprayer_config)
     - [set_sensor_interval](#set_sensor_interval)
     - [set_config](#set_config)
   - [Device Control](#device-control)
     - [set_entity_state](#set_entity_state)
     - [toggle_entity](#toggle_entity)
     - [pause_control_loop](#pause_control_loop)
     - [resume_control_loop](#resume_control_loop)
   - [Historical Data](#historical-data)
     - [get_history](#get_history)
     - [get_events](#get_events)
   - [Testing Commands](#testing-commands)
     - [test_light_entity](#test_light_entity)
     - [test_humidifier_entity](#test_humidifier_entity)
     - [test_sprayer_entity](#test_sprayer_entity)
     - [test_all_entities](#test_all_entities)
     - [test_email](#test_email)
     - [get_alarm_status](#get_alarm_status)
   - [Utility Commands](#utility-commands)
     - [help](#help)
6. [Error Handling](#error-handling)
7. [Flutter Integration](#flutter-integration)
8. [Common Patterns](#common-patterns)

---

## Overview

The Terrarium Control System uses WebSocket for real-time bidirectional communication between the Flutter UI and the TCU (Terrarium Control Unit) backend.

### Connection Details

- **Protocol**: WebSocket (RFC 6455)
- **Message Format**: JSON
- **Default Port**: 8765
- **Default URL**: `ws://[TCU_IP]:8765`
- **Encoding**: UTF-8

### Key Features

- Real-time sensor data updates
- Immediate device state feedback
- Historical data retrieval
- Configuration management
- Manual device control
- Automatic timezone conversion (UTC ↔ Local)

---

## Connection

### Establishing Connection

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

// Connect to TCU
final channel = WebSocketChannel.connect(
  Uri.parse('ws://192.168.1.100:8765'),
);

// Listen for messages
channel.stream.listen((message) {
  final response = jsonDecode(message);
  print('Received: ${response['data']}');
});

// Send command
channel.sink.add(jsonEncode({
  'command': 'get_status',
  'params': {},
}));
```

### Connection States

| State | Description |
|-------|-------------|
| `connecting` | Establishing WebSocket connection |
| `connected` | Successfully connected, ready to send commands |
| `disconnected` | Connection closed or failed |
| `reconnecting` | Attempting to reconnect after disconnect |

---

## Message Format

### Request Structure

All requests must follow this JSON format:

```json
{
  "command": "command_name",
  "params": {
    "param1": "value1",
    "param2": "value2"
  },
  "id": "optional-request-id"
}
```

**Request Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | Command name to execute |
| `params` | object | Yes | Command parameters (empty `{}` if none) |
| `id` | string/number | No | Optional identifier for request correlation |

### Response Structure

All responses follow this JSON format:

```json
{
  "status": "success",
  "data": {
    "...": "command-specific data"
  },
  "error": null,
  "id": "optional-request-id"
}
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `status` | string | `"success"` or `"error"` |
| `data` | object/null | Command result (null on error) |
| `error` | string/null | Error message (null on success) |
| `id` | string/number | Request ID if provided |

### Success Response Example

```json
{
  "status": "success",
  "data": {
    "timestamp": "2026-02-24T10:30:00Z",
    "sensors": {
      "inside": {"temperature": 25.5, "humidity": 65.0},
      "outside": {"temperature": 20.0, "humidity": 55.0}
    }
  },
  "error": null
}
```

### Error Response Example

```json
{
  "status": "error",
  "data": null,
  "error": "Unknown command: invalid_command",
  "id": "req-123"
}
```

---

## Timezone Handling

**Critical:** The TCU backend operates entirely in **UTC** timezone. The Flutter UI automatically converts times to/from the device's **local timezone**.

### Conversion Rules

1. **Timestamps from TCU** (events, sensor readings, status):
   - Format: ISO 8601 with `Z` suffix (e.g., `2026-02-24T08:49:31Z`)
   - Automatically converted to local time by `DateTime.parse().toLocal()`
   - Displayed in local timezone in the UI

2. **Schedule times TO TCU** (setting light schedules):
   - UI sends local time (e.g., `"08:00"` = 8 AM local)
   - TCU converts to UTC before storing
   - TCU compares current UTC time against UTC schedules

3. **Schedule times FROM TCU** (reading configuration):
   - TCU returns UTC times
   - UI should display as-is or convert for display

### Timezone Examples

**Example 1: Device in UTC+2 timezone**

```
UI displays:     10:00 (local time)
TCU stores:      08:00 (UTC)
Log file shows:  [2026-02-24T08:00:00Z]
UI History:      10:00 (converted to local)
```

**Example 2: Setting a schedule**

```dart
// User sets: Light on at 8:00 AM (local time)
await wsService.setLightSchedule('light1', '08:00', '20:00');

// Sent to TCU: {"on_time": "08:00", "off_time": "20:00"} (local)
// TCU converts and stores: "06:00", "18:00" (UTC if device is UTC+2)
// TCU operates: Turns light on at 06:00 UTC = 08:00 local
```

### Flutter Timezone Handling

```dart
// Parse UTC timestamp from TCU
final utcTimestamp = "2026-02-24T08:49:31Z";
final dateTime = DateTime.parse(utcTimestamp).toLocal();

// Display in UI
Text(DateFormat('HH:mm').format(dateTime)) // Shows: "10:49" (if UTC+2)

// Sensor readings and events automatically convert in model
factory TerrariumEvent.fromJson(Map<String, dynamic> json) {
  return TerrariumEvent(
    timestamp: DateTime.parse(json['timestamp']).toLocal(), // Automatic conversion
    message: json['message'],
  );
}
```

---

## Commands

## Status & Monitoring

### get_status

Get current system status including sensor readings and device states.

#### Request

```json
{
  "command": "get_status",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "timestamp": "2026-02-24T10:30:00Z",
    "paused": false,
    "sensors": {
      "inside": {
        "temperature": 25.5,
        "humidity": 65.0
      },
      "outside": {
        "temperature": 20.0,
        "humidity": 55.0
      }
    },
    "devices": {
      "light1": {
        "state": true,
        "reason": "schedule"
      },
      "light2": {
        "state": true,
        "reason": "schedule"
      },
      "light3": {
        "state": false,
        "reason": "schedule"
      },
      "humidifier": {
        "state": true,
        "reason": "regulation:humidity"
      },
      "sprayer": {
        "state": false,
        "reason": "schedule"
      },
      "fan1": {
        "state": true,
        "reason": "schedule"
      },
      "fan2": {
        "state": true,
        "reason": "schedule"
      }
    }
  },
  "error": null
}
```

#### Response Data Fields

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string (ISO 8601) | Status capture time (UTC with `Z`) |
| `paused` | boolean | Whether control loop is paused |
| `sensors` | object | Sensor readings from inside and outside |
| `devices` | object | Current state and reason for all devices |

**Device State Object:**

| Field | Type | Description |
|-------|------|-------------|
| `state` | boolean | Device state: `true` = ON, `false` = OFF |
| `reason` | string | Control reason (see reasons below) |

**Control Reasons:**

| Reason | Description |
|--------|-------------|
| `schedule` | Device controlled by time schedule |
| `regulation:humidity` | Humidifier controlled by humidity thresholds |
| `regulation:temperature` | Fan controlled by temperature |
| `regulation:interval` | Sprayer controlled by interval timer |
| `manual` | Manually controlled by user |

#### Flutter Usage

```dart
final wsService = context.read<WebSocketServiceBase>();
await wsService.getStatus();

// Access from provider
final status = wsService.currentStatus;
print('Inside temp: ${status.inside.temperature}°C');
print('Light1 state: ${status.devices.light1}');
```

#### Use Cases

- Dashboard real-time display
- Monitoring current conditions
- Checking device states
- Displaying control reasons

---

### ping

Test server connectivity and measure latency.

#### Request

```json
{
  "command": "ping",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "pong": true,
    "message": "Server is alive"
  },
  "error": null
}
```

#### Flutter Usage

```dart
await wsService.ping();
// Check if still connected
```

---

## Configuration

### get_config

Retrieve full system configuration including schedules, thresholds, and settings.

#### Request

```json
{
  "command": "get_config",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "lights": {
      "light1": {
        "name": "Main Light",
        "schedule": {
          "on_time": "06:00",
          "off_time": "18:00"
        }
      },
      "light2": {
        "name": "Heat Light",
        "schedule": {
          "on_time": "05:00",
          "off_time": "19:00"
        }
      },
      "light3": {
        "name": "UV Light",
        "schedule": {
          "on_time": "07:00",
          "off_time": "17:00"
        }
      }
    },
    "humidifier": {
      "name": "Humidifier",
      "min_humidity": 60.0,
      "max_humidity": 80.0
    },
    "sprayer": {
      "name": "Misting System",
      "spray_duration_seconds": 5,
      "spray_interval_hours": 2
    },
    "fans": {
      "fan1": {
        "name": "Intake Fan",
        "schedule": {
          "on_time": "06:00",
          "off_time": "18:00"
        }
      },
      "fan2": {
        "name": "Exhaust Fan",
        "schedule": {
          "on_time": "06:00",
          "off_time": "18:00"
        }
      }
    },
    "sensors": {
      "read_interval_seconds": 60
    },
    "temperature": {
      "min_temp": 22.0,
      "max_temp": 28.0
    },
    "alarms": {
      "enabled": true,
      "temperature_alarm_enabled": true,
      "humidity_alarm_enabled": true,
      "cooldown_minutes": 30
    },
    "email": {
      "enabled": true,
      "recipient": "user@example.com"
    }
  },
  "error": null
}
```

#### Important Notes

⚠️ **Schedule times in config are in UTC!**

The times shown in the configuration response are **UTC times**. The UI should:
- Display them as-is if showing UTC times
- Convert to local time for user display
- Send local times when updating (TCU converts to UTC)

#### Flutter Usage

```dart
await wsService.getConfig();
final config = wsService.currentConfig;

// Access schedule (times are UTC)
print('Light1 on: ${config.lights.light1.schedule.onTime}'); // "06:00" UTC
```

---

### set_light_schedule

Update light on/off schedule times.

#### Request

```json
{
  "command": "set_light_schedule",
  "params": {
    "light": "light1",
    "on_time": "08:00",
    "off_time": "20:00"
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `light` | string | Yes | Light ID: `"light1"`, `"light2"`, or `"light3"` |
| `on_time` | string | Yes | Turn-on time in `HH:MM` format (local time) |
| `off_time` | string | Yes | Turn-off time in `HH:MM` format (local time) |

#### Response

```json
{
  "status": "success",
  "data": {
    "light": "light1",
    "schedule": {
      "on_time": "06:00",
      "off_time": "18:00"
    }
  },
  "error": null
}
```

**Note:** Response times are in **UTC** (converted from local time by TCU).

#### Flutter Usage

```dart
// User sets schedule in local time
await wsService.setLightSchedule('light1', '08:00', '20:00');

// Refresh config to get updated values
await wsService.getConfig();
```

#### Timezone Example

```
Device timezone: UTC+2
User input:      08:00 - 20:00 (local)
TCU receives:    08:00 - 20:00 (local)
TCU converts:    06:00 - 18:00 (UTC)
TCU stores:      06:00 - 18:00 (UTC)
TCU response:    06:00 - 18:00 (UTC)
Light operates:  06:00-18:00 UTC = 08:00-20:00 local ✓
```

---

### set_humidity_thresholds

Update humidifier control thresholds.

#### Request

```json
{
  "command": "set_humidity_thresholds",
  "params": {
    "min_humidity": 60.0,
    "max_humidity": 80.0
  }
}
```

**Parameters:**

| Parameter | Type | Required | Range | Description |
|-----------|------|----------|-------|-------------|
| `min_humidity` | number | Yes | 0-100 | Minimum humidity (%) - turns humidifier ON |
| `max_humidity` | number | Yes | 0-100 | Maximum humidity (%) - turns humidifier OFF |

#### Response

```json
{
  "status": "success",
  "data": {
    "min_humidity": 60.0,
    "max_humidity": 80.0
  },
  "error": null
}
```

#### Flutter Usage

```dart
await wsService.setHumidityThresholds(60.0, 80.0);
```

---

### set_sprayer_config

Update sprayer duration and interval settings.

#### Request

```json
{
  "command": "set_sprayer_config",
  "params": {
    "spray_duration_seconds": 5,
    "spray_interval_hours": 2
  }
}
```

**Parameters:**

| Parameter | Type | Required | Range | Description |
|-----------|------|----------|-------|-------------|
| `spray_duration_seconds` | number | Yes | 1-60 | How long to spray (seconds) |
| `spray_interval_hours` | number | Yes | 0.5-24 | Time between sprays (hours) |

#### Response

```json
{
  "status": "success",
  "data": {
    "spray_duration_seconds": 5,
    "spray_interval_hours": 2
  },
  "error": null
}
```

#### Flutter Usage

```dart
await wsService.setSprayerConfig(5.0, 2.0);
```

---

### set_sensor_interval

Update how often sensors are read.

#### Request

```json
{
  "command": "set_sensor_interval",
  "params": {
    "read_interval_seconds": 60
  }
}
```

**Parameters:**

| Parameter | Type | Required | Range | Description |
|-----------|------|----------|-------|-------------|
| `read_interval_seconds` | number (int) | Yes | 10-300 | Sensor read interval (seconds) |

#### Response

```json
{
  "status": "success",
  "data": {
    "read_interval_seconds": 60
  },
  "error": null
}
```

#### Flutter Usage

```dart
await wsService.setSensorInterval(60);
```

---

### set_config

Update general configuration settings.

#### Request

```json
{
  "command": "set_config",
  "params": {
    "config": {
      "temperature": {
        "min_temp": 22.0,
        "max_temp": 28.0
      }
    }
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `config` | object | Yes | Configuration section(s) to update |

**Config Sections:**

- `temperature` - Temperature control settings
- `alarms` - Alarm configuration
- `email` - Email notification settings
- `display` - LCD display settings

#### Response

```json
{
  "status": "success",
  "data": {
    "updated": true,
    "config": {
      "...": "full updated config"
    }
  },
  "error": null
}
```

#### Flutter Usage

```dart
await wsService.setConfig('temperature', {
  'min_temp': 22.0,
  'max_temp': 28.0,
});
```

---

## Device Control

### set_entity_state

Manually control a device (turn ON or OFF).

#### Request

```json
{
  "command": "set_entity_state",
  "params": {
    "entity": "light1",
    "state": true
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entity` | string | Yes | Entity ID (see valid entities below) |
| `state` | boolean | Yes | Desired state: `true` = ON, `false` = OFF |

**Valid Entities:**

- `light1`, `light2`, `light3` - Lights
- `fan1`, `fan2` - Fans
- `humidifier` - Humidifier
- `sprayer` - Misting system

#### Response

```json
{
  "status": "success",
  "data": {
    "entity": "light1",
    "state": true,
    "display_name": "Main Light",
    "message": "Main Light turned ON (manual control)"
  },
  "error": null
}
```

#### Important Notes

⚠️ **Manual control is temporary!**

- Sets device state immediately
- Control reason changes to `"manual"`
- Autonomous control **resumes on next cycle** (usually within 60 seconds)
- To prevent autonomous control, use `pause_control_loop` first

#### Flutter Usage

```dart
// Turn light on manually
await wsService.setEntityState('light1', true);

// Status updates automatically via WebSocket
```

---

### toggle_entity

Toggle device state (ON → OFF or OFF → ON).

#### Request

```json
{
  "command": "toggle_entity",
  "params": {
    "entity": "light1"
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entity` | string | Yes | Entity ID (light1-3, fan1-2, humidifier, sprayer) |

#### Response

```json
{
  "status": "success",
  "data": {
    "entity": "light1",
    "state": false,
    "display_name": "Main Light",
    "message": "Main Light toggled to OFF"
  },
  "error": null
}
```

#### Flutter Usage

```dart
await wsService.toggleEntity('light1');
```

---

### pause_control_loop

Pause autonomous control (enable manual control mode).

#### Request

```json
{
  "command": "pause_control_loop",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "paused": true,
    "message": "Control loop paused - manual control mode enabled"
  },
  "error": null
}
```

#### Effect

- Sensors continue to be read
- No automatic device control
- Manual control commands take full effect
- Device states remain as they are

#### Flutter Usage

```dart
await wsService.pauseControlLoop();
// Now manual control won't be overridden
```

---

### resume_control_loop

Resume autonomous control.

#### Request

```json
{
  "command": "resume_control_loop",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "paused": false,
    "message": "Control loop resumed - autonomous control enabled"
  },
  "error": null
}
```

#### Flutter Usage

```dart
await wsService.resumeControlLoop();
// Autonomous control resumes on next cycle
```

---

## Historical Data

### get_history

Retrieve historical sensor readings from CSV file.

#### Request

```json
{
  "command": "get_history",
  "params": {
    "limit": 100
  }
}
```

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | number (int) | No | 100 | Maximum number of readings to return |

#### Response

```json
{
  "status": "success",
  "data": {
    "count": 100,
    "readings": [
      {
        "timestamp": "2026-02-24T10:30:00Z",
        "inside_temp": "25.50",
        "inside_humidity": "65.0",
        "outside_temp": "20.00",
        "outside_humidity": "55.0"
      },
      {
        "timestamp": "2026-02-24T10:25:00Z",
        "inside_temp": "25.45",
        "inside_humidity": "64.5",
        "outside_temp": "19.95",
        "outside_humidity": "55.5"
      }
    ]
  },
  "error": null
}
```

#### Response Data Fields

| Field | Type | Description |
|-------|------|-------------|
| `count` | number | Number of readings returned |
| `readings` | array | Array of sensor reading objects (most recent first) |

**Reading Object:**

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string | Reading time (UTC with `Z` suffix) |
| `inside_temp` | string | Inside temperature (°C) |
| `inside_humidity` | string | Inside humidity (%) |
| `outside_temp` | string | Outside temperature (°C) |
| `outside_humidity` | string | Outside humidity (%) |

#### Flutter Usage

```dart
await wsService.getHistory(limit: 500);

// Access from provider
final history = wsService.currentHistory; // List<SensorReading>

// Timestamps are automatically converted to local time
for (final reading in history) {
  print('${reading.timestamp.toLocal()}: ${reading.insideTemp}°C');
}
```

---

### get_events

Retrieve device event log entries.

#### Request

```json
{
  "command": "get_events",
  "params": {
    "limit": 50
  }
}
```

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | number (int) | No | 50 | Maximum number of events to return |

#### Response

```json
{
  "status": "success",
  "data": {
    "count": 50,
    "events": [
      {
        "timestamp": "2026-02-24T10:30:00Z",
        "message": "light1: ON (schedule (scheduled on))",
        "device": "light1",
        "state": true,
        "reason": "schedule",
        "type": "device_state_change"
      },
      {
        "timestamp": "2026-02-24T10:00:00Z",
        "message": "humidifier: OFF (regulation (humidity > 80%))",
        "device": "humidifier",
        "state": false,
        "reason": "regulation:humidity",
        "type": "device_state_change"
      },
      {
        "timestamp": "2026-02-24T09:45:00Z",
        "message": "Control loop resumed (autonomous mode)",
        "type": "system_event"
      }
    ]
  },
  "error": null
}
```

#### Response Data Fields

| Field | Type | Description |
|-------|------|-------------|
| `count` | number | Number of events returned |
| `events` | array | Array of event objects (most recent first) |

**Event Object:**

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string | Event time (UTC with `Z` suffix) |
| `message` | string | Human-readable event message |
| `device` | string (optional) | Device ID for device events |
| `state` | boolean (optional) | Device state for state changes |
| `reason` | string (optional) | Control reason for state changes |
| `type` | string | Event type: `"device_state_change"` or `"system_event"` |

#### Flutter Usage

```dart
await wsService.getEvents(limit: 100);

// Access from provider
final events = wsService.currentEvents; // List<TerrariumEvent>

// Timestamps are automatically converted to local time
for (final event in events) {
  print('${event.timestamp.toLocal()}: ${event.message}');
}
```

#### Use Cases

- History screen timeline
- Event log display
- Debugging device behavior
- Understanding control decisions

---

## Testing Commands

### test_light_entity

Run diagnostic test on a light entity.

#### Request

```json
{
  "command": "test_light_entity",
  "params": {
    "light": "light1"
  }
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "light": "light1",
    "success": true,
    "tests": {
      "turn_on": true,
      "turn_off": true,
      "state_tracking": true,
      "schedule_logic": true
    },
    "original_state": false,
    "control_reason": "schedule",
    "restored": true
  },
  "error": null
}
```

#### Flutter Usage

```dart
await wsService.testLightEntity('light1');
// Check response for test results
```

---

### test_humidifier_entity

Run diagnostic test on humidifier.

#### Request

```json
{
  "command": "test_humidifier_entity",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "entity": "humidifier",
    "success": true,
    "tests": {
      "turn_on": true,
      "turn_off": true,
      "state_tracking": true,
      "threshold_logic_low": true,
      "threshold_logic_high": true,
      "hysteresis": true
    },
    "original_state": true,
    "restored": true
  },
  "error": null
}
```

---

### test_sprayer_entity

Run diagnostic test on sprayer.

#### Request

```json
{
  "command": "test_sprayer_entity",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "entity": "sprayer",
    "success": true,
    "tests": {
      "turn_on": true,
      "turn_off": true,
      "state_tracking": true,
      "interval_logic": true,
      "mark_sprayed": true
    },
    "original_state": false,
    "restored": true
  },
  "error": null
}
```

---

### test_all_entities

Run comprehensive tests on all entities.

#### Request

```json
{
  "command": "test_all_entities",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "success": true,
    "light_tests": [...],
    "humidifier_test": {...},
    "sprayer_test": {...},
    "sensor_tests": [...],
    "display_test": {...},
    "summary": {
      "passed": 15,
      "failed": 0,
      "skipped": 0
    }
  },
  "error": null
}
```

---

### test_email

Send test email notification.

#### Request

```json
{
  "command": "test_email",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "success": true,
    "message": "Test email sent successfully. Check your inbox."
  },
  "error": null
}
```

---

### get_alarm_status

Get alarm system status and cooldown information.

#### Request

```json
{
  "command": "get_alarm_status",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "success": true,
    "alarm_status": {
      "enabled": true,
      "email_enabled": true,
      "cooldown_minutes": 30,
      "cooldown_active": [],
      "thresholds": {
        "min_temp": 22.0,
        "max_temp": 28.0,
        "min_humidity": 60.0,
        "max_humidity": 80.0
      }
    }
  },
  "error": null
}
```

---

## Utility Commands

### help

List all available commands with descriptions.

#### Request

```json
{
  "command": "help",
  "params": {}
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "commands": [
      {
        "name": "get_status",
        "description": "Get current terrarium status"
      },
      {
        "name": "get_config",
        "description": "Get terrarium configuration"
      }
    ]
  },
  "error": null
}
```

---

## Error Handling

### Error Response Structure

When a command fails, the response follows this format:

```json
{
  "status": "error",
  "data": null,
  "error": "Error message describing what went wrong",
  "id": "optional-request-id"
}
```

### Common Error Scenarios

#### 1. Unknown Command

```json
{
  "status": "error",
  "data": null,
  "error": "Unknown command: invalid_command"
}
```

**Cause:** Command name not recognized by TCU.

**Solution:** Check command spelling and available commands.

---

#### 2. Missing Parameters

```json
{
  "status": "error",
  "data": null,
  "error": "Missing required parameter: entity"
}
```

**Cause:** Required parameter not provided in request.

**Solution:** Include all required parameters with correct names.

---

#### 3. Invalid Parameter Value

```json
{
  "status": "error",
  "data": null,
  "error": "Unknown light: light4"
}
```

**Cause:** Parameter value not valid (e.g., non-existent entity).

**Solution:** Use valid entity IDs (light1-3, fan1-2, humidifier, sprayer).

---

#### 4. Invalid Time Format

```json
{
  "status": "error",
  "data": null,
  "error": "Invalid time format '25:00': must be HH:MM (00:00-23:59)"
}
```

**Cause:** Time string not in valid format or out of range.

**Solution:** Use `HH:MM` format with valid hours (00-23) and minutes (00-59).

---

#### 5. Connection Error

**Not a TCU error** - handled by Flutter WebSocket layer.

```dart
try {
  await wsService.sendCommand('get_status', {});
} catch (e) {
  // Handle connection error
  print('Connection error: $e');
}
```

**Causes:**
- TCU not running
- Network disconnected
- Firewall blocking port
- Incorrect IP address

---

### Flutter Error Handling Pattern

```dart
try {
  await wsService.setLightSchedule('light1', '08:00', '20:00');

  // Success - show confirmation
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Schedule updated successfully')),
  );

} on WebSocketException catch (e) {
  // WebSocket connection error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Connection error: ${e.message}'),
      backgroundColor: Colors.red,
    ),
  );

} catch (e) {
  // Other errors (TCU errors, parsing errors, etc.)
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## Flutter Integration

### Service Architecture

The UI uses `WebSocketService` class for all WebSocket communication:

```dart
abstract class WebSocketServiceBase extends ChangeNotifier {
  // Connection management
  Future<void> connect(String url);
  Future<void> disconnect();
  bool get isConnected;

  // Data accessors
  TerrariumStatus? get currentStatus;
  TerrariumConfig? get currentConfig;
  List<TerrariumEvent>? get currentEvents;
  List<SensorReading>? get currentHistory;

  // Commands
  Future<void> getStatus();
  Future<void> getConfig();
  Future<void> setLightSchedule(String light, String onTime, String offTime);
  // ... more commands
}
```

### Using WebSocketService

#### 1. Access Service from Widget

```dart
// In build method
final wsService = context.watch<WebSocketServiceBase>();

// Check connection status
if (!wsService.isConnected) {
  return Text('Not connected');
}

// Access current data
final status = wsService.currentStatus;
```

#### 2. Send Commands

```dart
// Get service (doesn't trigger rebuild)
final wsService = context.read<WebSocketServiceBase>();

// Send command
try {
  await wsService.setLightSchedule('light1', '08:00', '20:00');
} catch (e) {
  // Handle error
}

// Data updates automatically via notifyListeners()
```

#### 3. Periodic Updates

```dart
// Timer for periodic status updates
Timer.periodic(Duration(seconds: 5), (_) {
  if (wsService.isConnected) {
    wsService.getStatus();
  }
});
```

### Provider Integration

```dart
// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<WebSocketServiceBase>(
      create: (_) => WebSocketService(),
    ),
  ],
  child: MyApp(),
)

// In any widget
Consumer<WebSocketServiceBase>(
  builder: (context, wsService, child) {
    if (!wsService.isConnected) {
      return ConnectionScreen();
    }

    return DashboardScreen(status: wsService.currentStatus);
  },
)
```

---

## Common Patterns

### Pattern 1: Connect and Monitor

```dart
// Connect to TCU
await wsService.connect('ws://192.168.1.100:8765');

// Start monitoring
Timer.periodic(Duration(seconds: 5), (_) {
  wsService.getStatus();
});

// React to updates
Consumer<WebSocketServiceBase>(
  builder: (context, service, _) {
    final temp = service.currentStatus?.inside.temperature;
    return Text('${temp?.toStringAsFixed(1)}°C');
  },
)
```

### Pattern 2: Update Configuration

```dart
// Get current config
await wsService.getConfig();

// Update setting
await wsService.setLightSchedule('light1', '08:00', '20:00');

// Refresh to see changes
await wsService.getConfig();

// UI updates automatically
```

### Pattern 3: Manual Device Control

```dart
// Option A: Set specific state
ElevatedButton(
  onPressed: () async {
    await wsService.setEntityState('light1', true);
  },
  child: Text('Turn ON'),
)

// Option B: Toggle state
IconButton(
  onPressed: () async {
    await wsService.toggleEntity('light1');
  },
  icon: Icon(Icons.lightbulb),
)
```

### Pattern 4: Load Historical Data

```dart
// Load data when screen opens
@override
void initState() {
  super.initState();
  _loadHistory();
}

Future<void> _loadHistory() async {
  final wsService = context.read<WebSocketServiceBase>();

  // Load both history and events
  await Future.wait([
    wsService.getHistory(limit: 500),
    wsService.getEvents(limit: 100),
  ]);

  // Access data
  final history = wsService.currentHistory;
  final events = wsService.currentEvents;

  // Build timeline...
}
```

### Pattern 5: Error Handling with User Feedback

```dart
Future<void> _saveSchedule() async {
  final wsService = context.read<WebSocketServiceBase>();

  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    // Send command
    await wsService.setLightSchedule(
      _lightId,
      _onTimeController.text,
      _offTimeController.text,
    );

    // Close loading
    Navigator.pop(context);

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule saved!')),
    );

  } catch (e) {
    // Close loading
    Navigator.pop(context);

    // Show error
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to save schedule: $e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

## Summary

### Quick Reference

**Connection:**
- URL: `ws://[TCU_IP]:8765`
- Format: JSON
- All timestamps: UTC with `Z` suffix
- Schedule times: Local time → TCU converts to UTC

**Most Used Commands:**
- `get_status` - Real-time monitoring
- `get_config` - Read configuration
- `set_light_schedule` - Update schedules
- `set_entity_state` - Manual control
- `get_history` / `get_events` - Historical data

**Key Patterns:**
- Use Provider for state management
- Handle errors with try/catch
- Show user feedback for all actions
- Automatic timezone conversion in models
- Periodic status polling for real-time updates

---

**Last Updated:** 2026-02-27
**TCU Version:** 1.0
**API Version:** 1.0
