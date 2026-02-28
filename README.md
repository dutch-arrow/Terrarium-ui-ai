# Terrarium UI

Flutter-based Android tablet interface for the Terrarium Control System.

## Overview

This app provides a beautiful, responsive interface for monitoring and controlling your Raspberry Pi-based terrarium system via WebSocket connection.

## Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Start development server
./dev.sh
# Or: flutter run -d chrome --web-port=8080

# 3. In the browser, connect to your Pi
# Enter: ws://YOUR_PI_IP:8765
# Example: ws://192.168.50.200:8765
```

That's it! The dashboard will show real-time terrarium data.

## Development Modes

The UI supports two modes for development:

### Mock Mode (Default)

Develop and test the UI without a running Raspberry Pi backend. Mock mode simulates:
- Realistic sensor readings with natural variation
- All entity states and controls
- WebSocket command responses
- Entity testing sequences

```bash
# Use mock mode (default)
./dev.sh

# Or explicitly
./dev.sh --mock

# Using Flutter directly
flutter run -d chrome --web-port=8080 --dart-define=USE_MOCK=true
```

**Benefits:**
- No Raspberry Pi required for UI development
- Faster development iteration
- Test edge cases with simulated data
- Work offline or away from hardware

### Real Mode

Connect to actual Raspberry Pi backend:

```bash
# Use real WebSocket connection
./dev.sh --real

# Using Flutter directly
flutter run -d chrome --web-port=8080 --dart-define=USE_MOCK=false
```

The app will prompt you to enter your Pi's WebSocket URL (e.g., `ws://192.168.50.200:8765`).

## Features

### ✅ Implemented

- **Real-time Dashboard**: Monitor temperature, humidity, and device states
  - Inside/outside sensor readings
  - Device status indicators (lights, humidifier, sprayer)
  - Auto-refresh every 5 seconds
  - Connection status indicator

- **Configuration Editor**: Adjust all terrarium settings
  - Light schedules (on/off times for 3 lights)
  - Humidity thresholds (min/max with hysteresis)
  - Sprayer configuration (duration and interval)
  - Live updates sent to Pi immediately

- **Entity Testing**: Test system components
  - Test individual entities (lights, humidifier, sprayer, sensors)
  - Run comprehensive tests on all entities
  - View detailed test results

- **Tablet-Optimized UI**:
  - Navigation rail for easy access
  - Material 3 design with color-coded indicators
  - Responsive layout for landscape tablets
  - Connection management

### 🚧 Coming Soon

- **Historical Data Charts**: View sensor trends over time
- **Event Log Viewer**: Browse device activity history
- **Push Notifications**: Alerts for temperature/humidity thresholds
- **Multiple Terrariums**: Manage multiple systems

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android device or emulator (tablet recommended)
- Raspberry Pi running the Terrarium Control System on your local network

## Setup

### 1. Install Flutter

```bash
# Download Flutter SDK (Linux)
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz
tar xf flutter_linux_3.27.1-stable.tar.xz

# Add to PATH (add to ~/.bashrc for persistence)
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter --version
```

Or follow the official guide: https://docs.flutter.dev/get-started/install

### 2. Install Dependencies

```bash
cd ui
flutter pub get
```

### 3. Run the App

#### For Development (Web - fastest):
```bash
flutter run -d chrome --web-port=8080

# Or use the convenience script
./dev.sh
```

#### On a connected Android device:
```bash
# Check devices
flutter devices

# Run on device
flutter run
```

#### Build APK for tablet installation:
```bash
flutter build apk --release
```

The APK will be in `build/app/outputs/flutter-apk/app-release.apk`

Transfer this APK to your Android tablet and install it.

## Configuration

### WebSocket Connection

On first launch, you'll be prompted to enter your Raspberry Pi's WebSocket URL:

```
ws://YOUR_PI_IP_ADDRESS:8765
```

Example:
```
ws://192.168.50.200:8765
```

**Finding your Pi's IP address:**
```bash
# On the Raspberry Pi, run:
hostname -I
```

The app saves your WebSocket URL, so you only need to configure it once.

### Network Requirements

- Your tablet/device and Raspberry Pi must be on the same network
- Port 8765 must be accessible (check firewall settings if needed)
- For web development, Chrome/Firefox work best
- For production, use the Android APK (no CORS issues)

## Project Structure

### Overview

```
terrarium_ui/
├── lib/                         # Your Dart/Flutter code (main application)
│   ├── main.dart                # App entry point
│   ├── models/                  # Data structures (Status, Config, etc.)
│   ├── services/                # Business logic (WebSocket service)
│   ├── screens/                 # UI pages (Dashboard, Settings, etc.)
│   └── widgets/                 # Reusable UI components
├── android/                     # Android platform configuration
├── web/                         # Web platform configuration
├── test/                        # Unit and widget tests
├── build/                       # Generated build outputs (gitignored)
├── .dart_tool/                  # Dart tooling metadata (gitignored)
├── pubspec.yaml                 # Project configuration and dependencies
├── analysis_options.yaml        # Dart linter rules
└── README.md                    # This file
```

### Detailed Structure

#### Core Source Code (`lib/`)

**90% of your work happens here.** This is where all your Dart/Flutter application code lives.

```
lib/
├── main.dart                    # App entry point, sets up providers and theme
├── models/                      # Data models matching API responses
│   ├── terrarium_status.dart   # Status: sensors + devices
│   ├── terrarium_config.dart   # Configuration: schedules, thresholds
│   ├── sensor_reading.dart     # Historical sensor data
│   └── event.dart              # Event log entries
├── services/                    # Business logic layer
│   └── websocket_service.dart  # WebSocket client, API commands, state management
├── screens/                     # Full-screen pages
│   ├── home_screen.dart        # Main navigation with rail
│   ├── connection_screen.dart  # WebSocket connection dialog
│   ├── dashboard_screen.dart   # Real-time monitoring dashboard
│   ├── history_screen.dart     # Charts (placeholder for future)
│   ├── config_screen.dart      # Configuration editor
│   └── testing_screen.dart     # Entity testing interface
└── widgets/                     # Reusable UI components
    ├── light_schedule_editor.dart      # Edit light on/off times
    ├── humidity_threshold_editor.dart  # Edit humidity ranges
    └── sprayer_config_editor.dart      # Edit sprayer settings
```

#### Platform-Specific Folders

**`android/`** - Android platform configuration
- `app/build.gradle` - Build configuration, dependencies
- `app/src/main/AndroidManifest.xml` - App permissions, metadata
- `app/src/main/kotlin/` - Platform-specific Kotlin code
- `app/src/main/res/` - Icons, launch screens, styles
- Gradle wrapper and build scripts
- **Modify when**: Adding Android permissions, changing app name/icon

**`web/`** - Web platform configuration
- `index.html` - HTML entry point for web builds
- `manifest.json` - PWA (Progressive Web App) config
- `icons/` - Web app icons (192px, 512px)
- `favicon.png` - Browser tab icon
- **Modify when**: Changing web app metadata, PWA settings

**`ios/`** - iOS platform (not included)
- Would contain Xcode project files
- Add with: `flutter create . --platforms=ios`

#### Build & Tool Folders (Auto-Generated)

**`build/`** - Compiled outputs ⚠️ Don't commit to git
- `build/app/outputs/flutter-apk/` - Android APK files
- `build/web/` - Web build files
- Temporary compilation artifacts
- **Regenerated** on every build

**`.dart_tool/`** - Dart tooling cache ⚠️ Don't commit to git
- Package resolution cache
- Build system state
- IDE metadata
- **Automatically managed** by Flutter tools

**`.idea/`** - IntelliJ/Android Studio settings
- IDE project configuration
- Run configurations
- Optional (can be gitignored or committed)

#### Test & Development Files

**`test/`** - Unit and widget tests
- `widget_test.dart` - Example test (auto-generated)
- Add your own tests here
- Run with: `flutter test`

**`dev.sh`** - Development convenience script
- Starts Flutter web server on port 8080
- Quick way to launch for development

**`test-websocket.html`** - WebSocket debugging tool
- Simple HTML page to test raw WebSocket connection
- Bypasses Flutter for debugging server issues

#### Configuration Files (Root Level)

**`pubspec.yaml`** - Project manifest (like package.json)
- App name, description, version
- Dependencies (packages from pub.dev)
- Asset declarations (images, fonts, etc.)
- Platform constraints

**`pubspec.lock`** - Dependency lock file (like package-lock.json)
- Exact versions of all dependencies
- Auto-generated, commit to git
- Ensures consistent builds across machines

**`analysis_options.yaml`** - Dart linter configuration
- Code style rules
- Static analysis settings
- Enforces best practices

**`.gitignore`** - Git ignore rules
- Excludes: build/, .dart_tool/, *.iml
- Keeps repository clean

**`terrarium_ui.iml`** - IntelliJ module file
- IDE project metadata
- Auto-generated by Android Studio/IntelliJ

### What to Modify vs. What to Ignore

#### Modify Frequently ⭐
- **`lib/`** - All your app code
- **`pubspec.yaml`** - When adding dependencies or assets

#### Modify Occasionally 🔧
- **`android/app/src/main/AndroidManifest.xml`** - Android permissions
- **`test/`** - When writing tests
- **`README.md`** - Documentation updates

#### Never Modify ❌
- **`build/`** - Auto-generated on every build
- **`.dart_tool/`** - Managed by Flutter tools
- **`pubspec.lock`** - Auto-generated (but commit it)

#### Platform Code (Advanced) ⚠️
- **`android/`** - Only if adding native Android features
- **`web/`** - Only if customizing web behavior
- Most apps never need to touch these

### Common Tasks

**Add a new package:**
```bash
# Edit pubspec.yaml, add under dependencies:
#   some_package: ^1.0.0

flutter pub get
```

**Add an image asset:**
```bash
# 1. Put image in: assets/images/my_image.png
# 2. Edit pubspec.yaml:
#   flutter:
#     assets:
#       - assets/images/

flutter pub get
```

**Change app icon:**
```bash
# Replace: android/app/src/main/res/mipmap-*/ic_launcher.png
# Or use: flutter_launcher_icons package
```

**Clean build artifacts:**
```bash
flutter clean
flutter pub get
```

## Development

### Quick Start

```bash
# Web development (fastest for UI iteration)
flutter run -d chrome --web-port=8080

# Or use the convenience script
./dev.sh

# Android device/emulator
flutter run
```

### Hot Reload

Flutter supports hot reload for fast development:

```bash
# While the app is running, press:
# 'r' for hot reload (quick UI updates)
# 'R' for hot restart (full app restart)
# 'q' to quit
```

### Web Development Notes

- Web mode is great for rapid UI development
- No need to deploy to a device for every change
- WebSocket connections work with Chrome (CORS is handled)
- For production, always build the Android APK

### Testing WebSocket Connection

A simple WebSocket test page is included for debugging:

```bash
# Open in browser
open test-websocket.html
```

This bypasses Flutter and tests the raw WebSocket connection to your Pi.

### Debugging

Enable debug mode in Android Studio or VS Code to:
- Set breakpoints
- Inspect variables
- View console output (press F12 in browser for web mode)
- Use Flutter DevTools

## Building for Production

### Release APK

```bash
flutter build apk --release
```

### App Bundle (for Google Play)

```bash
flutter build appbundle --release
```

### Optimizations

The release build automatically includes:
- Code obfuscation
- Dead code elimination
- Asset optimization

## Troubleshooting

### Connection Issues

**Problem**: Cannot connect to Raspberry Pi

**Solutions**:
1. Verify Pi is on the same network
2. Check Pi IP address: `hostname -I` on the Pi
3. Ensure terrarium service is running: `python3 main.py run`
4. Test connection: `nc -zv YOUR_PI_IP 8765`
5. Check firewall settings
6. Use `test-websocket.html` to debug raw WebSocket connection

**Problem**: Connected but no data displayed

**Solution**:
- Make sure your Pi has the updated `terrarium/api/commands.py` with data transformation
- Check browser console (F12) for JavaScript errors
- Verify Pi server logs show successful command execution

### Build Issues

**Problem**: Dependencies not resolving

**Solution**:
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

**Problem**: Android build fails

**Solution**:
```bash
flutter doctor
# Fix any issues reported (Java JDK, Android SDK, etc.)
```

**Problem**: "JAVA_HOME not set" error

**Solution**:
```bash
sudo apt-get install openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

## API Commands

The app uses these WebSocket API commands:

- `get_status` - Real-time sensor readings and device states
- `get_config` - Current configuration
- `set_light_schedule` - Update light on/off times
- `set_humidity_thresholds` - Adjust humidity control
- `set_sprayer_config` - Configure sprayer timing
- `test_*_entity` - Test individual entities
- `test_all_entities` - Comprehensive system test
- `get_history` - Sensor reading history
- `get_events` - Event log

See [../tcu/docs/API_REFERENCE.md](../tcu/docs/API_REFERENCE.md) for full API documentation.

## Contributing

This is part of the Terrarium project. See main project README for contribution guidelines.

## License

Same as main Terrarium project.
# Terrarium-ui-ai
