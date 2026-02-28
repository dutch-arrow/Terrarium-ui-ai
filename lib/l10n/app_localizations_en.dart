// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Terrarium Control';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get config => 'Config';

  @override
  String get configuration => 'Configuration';

  @override
  String get edit => 'Edit';

  @override
  String get error => 'Error';

  @override
  String get info => 'Info';

  @override
  String get loading => 'Loading...';

  @override
  String get off => 'OFF';

  @override
  String get offPrefix => 'OFF';

  @override
  String get on => 'ON';

  @override
  String get onPrefix => 'ON';

  @override
  String get refresh => 'Refresh';

  @override
  String get reset => 'Reset';

  @override
  String get save => 'Save';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get clickConnectionIconToConnect =>
      'Click the connection icon to connect';

  @override
  String get connect => 'Connect';

  @override
  String get connected => 'Connected';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get notConnected => 'Not connected';

  @override
  String get notConnectedToTerrarium => 'Not connected to terrarium';

  @override
  String get reconnecting => 'Reconnecting...';

  @override
  String get terrariumDashboard => 'Terrarium Dashboard';

  @override
  String get dashboard => 'Dashboard';

  @override
  String lastUpdate(Object time) {
    return 'Last update: $time';
  }

  @override
  String get loadingStatus => 'Loading status...';

  @override
  String get appSettings => 'App Settings';

  @override
  String get darkTheme => 'Dark';

  @override
  String get dutch => 'Dutch';

  @override
  String get english => 'English';

  @override
  String get language => 'Language';

  @override
  String get lightTheme => 'Light';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get settings => 'Settings';

  @override
  String get systemTheme => 'System';

  @override
  String get theme => 'Theme';

  @override
  String get autonomousControlActive => 'Autonomous control active';

  @override
  String get autonomousControlDisabled => 'Autonomous control disabled';

  @override
  String get controlLoopPaused => 'Control Loop: PAUSED';

  @override
  String get controlLoopRunning => 'Control Loop: RUNNING';

  @override
  String get deviceStatus => 'Device Status';

  @override
  String get manualControlDescription =>
      'Manually toggle entities on/off for testing. Note: Autonomous control will resume on the next control cycle.';

  @override
  String get manualEntityControl => 'Manual Entity Control';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get controlLoop => 'Control Loop';

  @override
  String get paused => 'Paused';

  @override
  String get running => 'Running';

  @override
  String editScheduleTitle(Object name) {
    return 'Edit $name Schedule';
  }

  @override
  String get heatLight => 'Heat Light';

  @override
  String get light1 => 'Light 1';

  @override
  String get light2 => 'Light 2';

  @override
  String get light3 => 'Light 3';

  @override
  String get lightEntities => 'Light Entities';

  @override
  String get lights => 'Lights';

  @override
  String get lightSchedules => 'Light Schedules';

  @override
  String get mainLight => 'Main Light';

  @override
  String get offTime => 'Off Time';

  @override
  String get onTime => 'On Time';

  @override
  String get schedule => 'Schedule';

  @override
  String get scheduleUpdated => 'Schedule updated';

  @override
  String get timeFormatHelper => 'Format: HH:MM (24-hour)';

  @override
  String get uvLight => 'UV Light';

  @override
  String get editHumidityThresholds => 'Edit Humidity Thresholds';

  @override
  String failedToUpdate(Object error) {
    return 'Failed to update: $error';
  }

  @override
  String gapHysteresis(Object value) {
    return 'Gap: $value% (hysteresis)';
  }

  @override
  String get humidifier => 'Humidifier';

  @override
  String get humidity => 'Humidity';

  @override
  String get humidityControl => 'Humidity Control';

  @override
  String get humidityThresholds => 'Humidity Thresholds';

  @override
  String get maxHumidity => 'Max Humidity';

  @override
  String get maximumTurnOff => 'Maximum (Turn OFF)';

  @override
  String maximumValue(Object value) {
    return 'Maximum: $value%';
  }

  @override
  String get minHumidity => 'Min Humidity';

  @override
  String get minimumTurnOn => 'Minimum (Turn ON)';

  @override
  String minimumValue(Object value) {
    return 'Minimum: $value%';
  }

  @override
  String get minMustBeLessThanMax => 'Minimum must be less than maximum';

  @override
  String get thresholdsUpdated => 'Thresholds updated';

  @override
  String durationSeconds(Object value) {
    return 'Duration: $value seconds';
  }

  @override
  String get editSprayerConfiguration => 'Edit Sprayer Configuration';

  @override
  String get hours => 'hours';

  @override
  String intervalHours(Object value) {
    return 'Interval: $value hours';
  }

  @override
  String get seconds => 'seconds';

  @override
  String get sprayDuration => 'Spray Duration';

  @override
  String get sprayer => 'Sprayer';

  @override
  String get sprayerConfigUpdated => 'Sprayer config updated';

  @override
  String get sprayerConfiguration => 'Sprayer Configuration';

  @override
  String get sprayerSettings => 'Sprayer Settings';

  @override
  String get sprayInterval => 'Spray Interval';

  @override
  String get insideHumidity => 'Inside Humidity';

  @override
  String get insideTemp => 'Inside Temp';

  @override
  String get insideTerrarium => 'Inside Terrarium';

  @override
  String get outside => 'Outside';

  @override
  String get outsideHumidity => 'Outside Humidity';

  @override
  String get outsideTemp => 'Outside Temp';

  @override
  String get readInterval => 'Read Interval';

  @override
  String get sensorSettings => 'Sensor Settings';

  @override
  String get temperature => 'Temperature';

  @override
  String get exhaustFan => 'Exhaust Fan';

  @override
  String get fan1 => 'Fan 1';

  @override
  String get fan2 => 'Fan 2';

  @override
  String get fans => 'Fans';

  @override
  String get intakeFan => 'Intake Fan';

  @override
  String get otherDevices => 'Other Devices';

  @override
  String get otherEntities => 'Other Entities';

  @override
  String get allEntityTestsCompleted => 'All entity tests completed';

  @override
  String get entityTesting => 'Entity Testing';

  @override
  String get entityTestingDescription =>
      'Test individual entities or run comprehensive tests on all entities.';

  @override
  String get testAllEntities => 'Test All Entities';

  @override
  String testCompleted(Object entity) {
    return '$entity test completed';
  }

  @override
  String testFailed(Object error) {
    return 'Test failed: $error';
  }

  @override
  String get testHumidifier => 'Test Humidifier';

  @override
  String get testInfoMessage =>
      'Entity tests verify functionality without permanently disrupting the control system. Original states are restored after testing.';

  @override
  String get testing => 'Testing';

  @override
  String get testingAllEntities => 'Testing all entities...';

  @override
  String testingEntity(Object entity) {
    return 'Testing $entity...';
  }

  @override
  String get testLight1 => 'Test Light 1';

  @override
  String get testLight2 => 'Test Light 2';

  @override
  String get testLight3 => 'Test Light 3';

  @override
  String get testSprayer => 'Test Sprayer';

  @override
  String get history => 'History';

  @override
  String get deviceSwitchingHistory => 'Device Switching History';

  @override
  String get timeInterval => 'Time interval:';

  @override
  String get fiveMinutes => '5m';

  @override
  String get tenMinutes => '10m';

  @override
  String get fifteenMinutes => '15m';

  @override
  String get thirtyMinutes => '30m';

  @override
  String get oneHour => '1h';

  @override
  String get noEventsYet => 'No Events Yet';

  @override
  String get deviceStateChangesWillAppearHere =>
      'Device state changes will appear here';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get time => 'Time';
}
