# Terrarium UI - Developer's Guide

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Setup & Installation](#setup--installation)
4. [Project Structure](#project-structure)
5. [Key Components](#key-components)
6. [Development Workflow](#development-workflow)
7. [State Management](#state-management)
8. [Internationalization](#internationalization)
9. [Building & Deployment](#building--deployment)
10. [Testing](#testing)
11. [Troubleshooting](#troubleshooting)
12. [Code Conventions](#code-conventions)

---

## Project Overview

The Terrarium UI is a Flutter-based mobile application designed for Android tablets to control and monitor an autonomous terrarium control system. The app provides real-time monitoring of sensors, device control, historical data visualization, and configuration management.

### Key Features

- **Real-time Monitoring**: Live sensor data and device states via WebSocket
- **Device Control**: Manual control of lights, fans, humidifier, and sprayer
- **Historical Data**: Timeline view of sensor readings and device state changes
- **Configuration**: Edit schedules, thresholds, and system settings
- **Internationalization**: Multi-language support (English, Dutch)
- **Mock Mode**: Development mode with simulated data
- **Timezone Handling**: Automatic UTC to local time conversion

### Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider
- **Communication**: WebSocket (web_socket_channel)
- **Charts**: fl_chart
- **Storage**: shared_preferences
- **Localization**: flutter_intl

---

## Architecture

### Application Architecture

The application follows a clean architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                 │
│  (Screens & Widgets)                            │
├─────────────────────────────────────────────────┤
│              Business Logic Layer               │
│  (Services & State Management)                  │
├─────────────────────────────────────────────────┤
│              Data Layer                         │
│  (Models & WebSocket Communication)             │
└─────────────────────────────────────────────────┘
```

### Communication Flow

```
TCU (Python Backend)
        ↓↑ WebSocket
WebSocketService
        ↓↑ Provider
    Screens & Widgets
        ↓↑ User Interaction
    Android Device
```

### State Management

The app uses **Provider** for state management with two main providers:

1. **WebSocketServiceBase**: Manages WebSocket connection and data
2. **AppSettings**: Manages app-wide settings (theme, language, server URL)

---

## Setup & Installation

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android device or emulator (Android 6.0+)

### Installation Steps

1. **Clone the repository** (if not already done)
   ```bash
   cd /home/tom/Workspaces/Terrarium/ui
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localization files** (if needed)
   ```bash
   flutter pub run intl_utils:generate
   ```

4. **Run the app in mock mode** (default)
   ```bash
   flutter run
   ```

5. **Run with real WebSocket connection**
   ```bash
   flutter run --dart-define=USE_MOCK=false
   ```

### Development Environment Setup

#### VS Code

Install these extensions:
- Flutter
- Dart
- Flutter Intl (for translations)

#### Android Studio

- Install Flutter plugin
- Configure Android SDK
- Create AVD (Android Virtual Device) for testing

---

## Project Structure

```
ui/
├── android/                    # Android-specific configuration
│   ├── app/
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── res/            # App icons and resources
│   └── gradle/                 # Gradle build configuration
├── lib/                        # Main source code
│   ├── l10n/                   # Localization files
│   │   ├── app_en.arb          # English translations
│   │   ├── app_nl.arb          # Dutch translations
│   │   └── app_localizations.dart
│   ├── models/                 # Data models
│   │   ├── event.dart          # Event log entry
│   │   ├── sensor_reading.dart # Sensor data
│   │   ├── terrarium_config.dart
│   │   └── terrarium_status.dart
│   ├── screens/                # Main app screens
│   │   ├── connection_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── config_screen.dart
│   │   ├── history_screen.dart
│   │   ├── home_screen.dart
│   │   └── settings_screen.dart
│   ├── services/               # Business logic services
│   │   ├── app_settings.dart
│   │   ├── mock_websocket_service.dart
│   │   ├── websocket_service.dart
│   │   └── websocket_service_base.dart
│   ├── widgets/                # Reusable UI components
│   │   ├── alarm_config_editor.dart
│   │   ├── email_notification_editor.dart
│   │   ├── humidity_threshold_editor.dart
│   │   ├── light_schedule_editor.dart
│   │   ├── sensor_config_editor.dart
│   │   ├── sprayer_config_editor.dart
│   │   └── temperature_control_editor.dart
│   └── main.dart               # Application entry point
├── test/                       # Unit and widget tests
├── web/                        # Web assets
│   ├── terrarium.png           # App icon source
│   └── icons/                  # PWA icons
├── pubspec.yaml                # Dependencies and configuration
└── DEVELOPERS_GUIDE.md         # This file
```

---

## Key Components

### 1. Services

#### WebSocketService

Manages real-time communication with the TCU backend.

**Key Responsibilities:**
- Establish and maintain WebSocket connection
- Send commands to TCU
- Receive and parse status updates, events, and history
- Handle connection errors and reconnection
- Notify listeners of data changes

**Usage Example:**
```dart
final wsService = context.read<WebSocketServiceBase>();
await wsService.connect(serverUrl);
await wsService.sendCommand('set_entity_state', {
  'entity': 'light1',
  'state': true,
});
```

#### MockWebSocketService

Provides simulated data for development without a real backend.

**Features:**
- Generates realistic sensor readings
- Simulates device state changes
- Creates mock event history
- Updates at regular intervals

#### AppSettings

Manages persistent application settings.

**Stored Settings:**
- Theme mode (light/dark/system)
- Language preference
- Last connected server URL

### 2. Models

#### TerrariumStatus

Represents the current system state.

**Fields:**
- `timestamp`: Time of status snapshot (local time)
- `paused`: Whether control loop is paused
- `inside`: Inside sensor data (temp, humidity)
- `outside`: Outside sensor data (temp, humidity)
- `devices`: Device states and control reasons

#### TerrariumConfig

System configuration including schedules and thresholds.

**Note:** Schedule times in config are **UTC**. The UI automatically converts to/from local time.

#### SensorReading

Historical sensor data point (timestamp + 4 sensor values).

**Timezone:** Timestamps are automatically converted from UTC to local time.

#### TerrariumEvent

Event log entry for device state changes and system events.

**Timezone:** Timestamps are automatically converted from UTC to local time.

### 3. Screens

#### ConnectionScreen

First screen shown when not connected. Allows entering server URL.

**Features:**
- URL validation
- Connection status feedback
- Saved URL history

#### HomeScreen

Main navigation hub with bottom navigation bar.

**Tabs:**
- Dashboard
- Configuration
- History
- Settings

#### DashboardScreen

Real-time system monitoring.

**Components:**
- Live sensor readings with charts
- Device state indicators
- Manual device controls
- System status indicators

#### ConfigScreen

Configuration editor for all system settings.

**Sections:**
- Light schedules (3 lights)
- Humidity thresholds
- Sprayer configuration
- Sensor intervals
- Temperature control
- Alarm settings
- Email notifications

**Important:** All schedule times are displayed in **local time** but stored in **UTC**.

#### HistoryScreen

Timeline view of historical data.

**Features:**
- Event-driven state machine for smooth loading
- Isolate-based timeline computation
- Lazy loading of timeline rows
- Horizontal scrolling for wide data
- Date dividers
- Device state and reason display
- Sensor readings interpolation

**Performance:**
- Pre-computes all timeline data in isolate
- Renders all rows upfront (no lazy loading during scroll)
- Smooth vertical scrolling
- Horizontal scrolling for overflow

#### SettingsScreen

App-level settings and preferences.

**Options:**
- Theme selection (light/dark/system)
- Language selection (English/Dutch)
- Server URL management
- Connection status

### 4. Widgets

Configuration editor widgets for specific settings:

- **LightScheduleEditor**: Edit light on/off times (auto-converts UTC ↔ local)
- **HumidityThresholdEditor**: Set min/max humidity levels
- **SprayerConfigEditor**: Configure spray duration and interval
- **SensorConfigEditor**: Set sensor reading interval
- **TemperatureControlEditor**: Configure temperature thresholds
- **AlarmConfigEditor**: Enable/disable alarms
- **EmailNotificationEditor**: Configure email alerts

---

## Development Workflow

### Running the App

#### Mock Mode (Default)

For development without TCU backend:

```bash
flutter run
```

This uses `MockWebSocketService` with simulated data.

#### Real Connection Mode

To connect to actual TCU:

```bash
flutter run --dart-define=USE_MOCK=false
```

Enter TCU IP address (e.g., `ws://192.168.1.100:8765`) in ConnectionScreen.

### Hot Reload

Flutter supports hot reload for quick iteration:

1. Make code changes
2. Press `r` in terminal or click hot reload button
3. Changes appear instantly (preserves app state)

For structural changes, use hot restart (`R` key).

### Debugging

#### VS Code

1. Set breakpoints in code
2. Press F5 to start debugging
3. Use Debug Console for output

#### Flutter DevTools

Access advanced debugging tools:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Features:
- Widget inspector
- Performance profiler
- Memory profiler
- Network inspector

### Adding New Features

1. **Add translations** to `lib/l10n/app_*.arb`
2. **Generate localization files**:
   ```bash
   flutter pub run intl_utils:generate
   ```
3. **Create/modify widgets** in appropriate directory
4. **Update models** if data structure changes
5. **Test** with both mock and real data
6. **Run linter**:
   ```bash
   flutter analyze
   ```

---

## State Management

### Provider Pattern

The app uses Provider for dependency injection and state management.

#### Setup in main.dart

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<WebSocketServiceBase>(
      create: (_) => useMock ? MockWebSocketService() : WebSocketService(),
    ),
    ChangeNotifierProvider<AppSettings>(
      create: (_) => AppSettings(),
    ),
  ],
  child: MyApp(),
)
```

#### Reading State

```dart
// Read once (doesn't rebuild)
final wsService = context.read<WebSocketServiceBase>();

// Watch for changes (rebuilds on change)
final status = context.watch<WebSocketServiceBase>().currentStatus;

// Select specific field (rebuilds only when that field changes)
final isConnected = context.select<WebSocketServiceBase, bool>(
  (service) => service.isConnected,
);
```

#### Updating State

Services extend `ChangeNotifier` and call `notifyListeners()`:

```dart
class MyService extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // Notifies all listeners
  }
}
```

---

## Internationalization

The app supports multiple languages using Flutter's intl package.

### Supported Languages

- English (`en`)
- Dutch (`nl`)

### Adding Translations

1. Edit ARB files in `lib/l10n/`:
   - `app_en.arb` - English
   - `app_nl.arb` - Dutch

2. Add new key-value pairs:
   ```json
   {
     "myNewString": "Hello World",
     "@myNewString": {
       "description": "Greeting message"
     }
   }
   ```

3. Generate code:
   ```bash
   flutter pub run intl_utils:generate
   ```

4. Use in code:
   ```dart
   final l10n = AppLocalizations.of(context)!;
   Text(l10n.myNewString);
   ```

### Language Selection

Users can change language in Settings screen. Selection is persisted using SharedPreferences.

---

## Building & Deployment

### Android APK (Debug)

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Android APK (Release)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

**Note:** Release builds require signing configuration in `android/app/build.gradle`.

### Android App Bundle

For Google Play Store:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Build Modes

- **Debug**: Includes debugging info, hot reload, larger size
- **Profile**: Optimized for performance profiling
- **Release**: Fully optimized, smallest size, no debugging

### App Icon

The app icon is configured in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  image_path: "web/terrarium.png"
  adaptive_icon_background: "#2E7D32"
  adaptive_icon_foreground: "web/terrarium.png"
```

To regenerate icons after changing `terrarium.png`:

```bash
flutter pub run flutter_launcher_icons
```

### App Name

Configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="Terrarium"
    ...>
```

---

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/my_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

#### Widget Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:terrarium_ui/widgets/my_widget.dart';

void main() {
  testWidgets('MyWidget displays text', (WidgetTester tester) async {
    await tester.pumpWidget(MyWidget(text: 'Hello'));

    expect(find.text('Hello'), findsOneWidget);
  });
}
```

#### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:terrarium_ui/models/sensor_reading.dart';

void main() {
  test('SensorReading parses JSON correctly', () {
    final json = {
      'timestamp': '2026-02-24T08:00:00Z',
      'inside_temp': '25.5',
      'inside_humidity': '65.0',
      'outside_temp': '20.0',
      'outside_humidity': '55.0',
    };

    final reading = SensorReading.fromJson(json);

    expect(reading.insideTemp, 25.5);
    expect(reading.insideHumidity, 65.0);
  });
}
```

---

## Troubleshooting

### Common Issues

#### 1. WebSocket Connection Fails

**Problem:** Cannot connect to TCU backend.

**Solutions:**
- Check TCU is running: `systemctl status tcu`
- Verify network connectivity
- Check firewall rules: TCU port 8765 must be accessible
- Ensure correct IP address (use `ws://IP:8765` format)
- Try from TCU host: `ws://localhost:8765`

#### 2. Timestamps Show Wrong Time

**Problem:** Times in History screen don't match local time.

**Root Cause:** TCU stores all timestamps in UTC. The Flutter app converts to local time.

**Verification:**
- Check TCU logs: timestamps should end with `Z` (UTC indicator)
- Example: `[2026-02-24T08:49:31Z]`
- Flutter automatically converts to local time using `DateTime.parse().toLocal()`

#### 3. Hot Reload Doesn't Work

**Problem:** Changes don't appear after hot reload.

**Solutions:**
- Use hot restart (press `R` instead of `r`)
- For main.dart changes, always restart
- For provider changes, restart app
- Check terminal for errors

#### 4. Build Fails

**Problem:** `flutter build` fails with errors.

**Solutions:**
- Clean build cache: `flutter clean`
- Get dependencies: `flutter pub get`
- Check Dart/Flutter versions: `flutter doctor`
- Update dependencies: `flutter pub upgrade`

#### 5. App Crashes on Startup

**Problem:** App crashes immediately on launch.

**Solutions:**
- Check logs: `flutter logs` or `adb logcat`
- Look for null safety errors
- Verify all required permissions in AndroidManifest.xml
- Check for missing translations

#### 6. Icons Not Updating

**Problem:** App icon doesn't change after updating terrarium.png.

**Solution:**
```bash
flutter pub run flutter_launcher_icons
flutter clean
flutter build apk
```

---

## Code Conventions

### Dart Style Guide

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style):

- Use `camelCase` for identifiers
- Use `UpperCamelCase` for class names
- Use `lowercase_with_underscores` for file names
- Prefer `final` over `var` when variable won't change
- Use trailing commas for better formatting

### Project-Specific Conventions

#### 1. File Organization

- **Models**: Data classes in `lib/models/`
- **Screens**: Full-page widgets in `lib/screens/`
- **Widgets**: Reusable components in `lib/widgets/`
- **Services**: Business logic in `lib/services/`

#### 2. Naming

- **Screens**: `*_screen.dart` (e.g., `dashboard_screen.dart`)
- **Widgets**: `*_widget.dart` or descriptive name (e.g., `light_schedule_editor.dart`)
- **Services**: `*_service.dart`
- **Models**: Singular noun (e.g., `sensor_reading.dart`)

#### 3. Comments

- Use `///` for documentation comments
- Use `//` for implementation comments
- Document all public APIs
- Explain complex logic

Example:
```dart
/// Converts UTC time to local time string.
///
/// Takes a UTC DateTime and returns a formatted string
/// in the device's local timezone.
///
/// Example:
/// ```dart
/// formatLocalTime(DateTime.utc(2026, 2, 24, 8, 0))
/// // Returns: "10:00" (if local is UTC+2)
/// ```
String formatLocalTime(DateTime utcTime) {
  final localTime = utcTime.toLocal();
  return DateFormat('HH:mm').format(localTime);
}
```

#### 4. Error Handling

- Always handle errors in async operations
- Show user-friendly error messages
- Log errors for debugging

```dart
try {
  await wsService.connect(url);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Connection failed: $e')),
  );
  logger.error('WebSocket connection error', error: e);
}
```

#### 5. State Management

- Keep widgets stateless when possible
- Use `const` constructors for immutable widgets
- Minimize rebuilds with `select` or `Consumer`

```dart
// Good: Only rebuilds when isConnected changes
final isConnected = context.select<WebSocketServiceBase, bool>(
  (service) => service.isConnected,
);

// Avoid: Rebuilds on any service change
final service = context.watch<WebSocketServiceBase>();
final isConnected = service.isConnected;
```

#### 6. Timezone Handling

**Critical:** Always be explicit about timezones.

- **TCU Backend**: All timestamps in **UTC**
- **Flutter Models**: Convert to **local time** in `fromJson()`
- **Display**: Use local time
- **API Calls**: Send local time (TCU converts to UTC)

```dart
// Model: Convert UTC to local
factory SensorReading.fromJson(Map<String, dynamic> json) {
  return SensorReading(
    timestamp: DateTime.parse(json['timestamp']).toLocal(), // ← Important!
    ...
  );
}

// Display: Already local time
Text(DateFormat('HH:mm').format(reading.timestamp))
```

### Linting

The project uses `flutter_lints` for code quality:

```bash
# Check for issues
flutter analyze

# Auto-fix some issues
dart fix --apply
```

---

## Additional Resources

### Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)

### Flutter Packages

- [Provider](https://pub.dev/packages/provider) - State management
- [fl_chart](https://pub.dev/packages/fl_chart) - Charts
- [web_socket_channel](https://pub.dev/packages/web_socket_channel) - WebSocket
- [shared_preferences](https://pub.dev/packages/shared_preferences) - Local storage
- [intl](https://pub.dev/packages/intl) - Internationalization

### TCU Backend

See `tcu/README.md` and `tcu/docs/API_REFERENCE.md` for backend documentation.

### WebSocket API

All commands and responses are documented in `tcu/docs/API_REFERENCE.md`.

**Key endpoints:**
- `get_status` - Current system state
- `get_config` - Configuration
- `get_events` - Event log
- `get_history` - Sensor history
- `set_entity_state` - Control devices
- `set_light_schedule` - Update schedules

---

## Contributing

### Before Committing

1. Run linter: `flutter analyze`
2. Run tests: `flutter test`
3. Test on real device
4. Update translations if needed
5. Update this guide if adding features

### Git Workflow

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Commit with descriptive message
5. Push and create pull request

---

## License

See the main project LICENSE file.

---

## Support

For questions or issues:
1. Check this guide
2. Review TCU documentation
3. Check Flutter documentation
4. File an issue on the project repository

---

**Last Updated:** 2026-02-27
**Flutter Version:** 3.x
**Dart Version:** 3.x
