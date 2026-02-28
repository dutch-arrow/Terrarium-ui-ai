// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Terrarium Besturing';

  @override
  String get apply => 'Toepassen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get config => 'Configuratie';

  @override
  String get configuration => 'Configuratie';

  @override
  String get edit => 'Bewerken';

  @override
  String get error => 'Fout';

  @override
  String get info => 'Info';

  @override
  String get loading => 'Laden...';

  @override
  String get off => 'UIT';

  @override
  String get offPrefix => 'UIT';

  @override
  String get on => 'AAN';

  @override
  String get onPrefix => 'AAN';

  @override
  String get refresh => 'Ververs';

  @override
  String get reset => 'Resetten';

  @override
  String get save => 'Opslaan';

  @override
  String get success => 'Succes';

  @override
  String get warning => 'Waarschuwing';

  @override
  String get clickConnectionIconToConnect =>
      'Klik op het verbindingspictogram om verbinding te maken';

  @override
  String get connect => 'Verbinden';

  @override
  String get connected => 'Verbonden';

  @override
  String get connecting => 'Verbinden...';

  @override
  String get connectionError => 'Verbindingsfout';

  @override
  String get disconnect => 'Verbreken';

  @override
  String get disconnected => 'Niet verbonden';

  @override
  String get notConnected => 'Niet verbonden';

  @override
  String get notConnectedToTerrarium => 'Niet verbonden met terrarium';

  @override
  String get reconnecting => 'Opnieuw verbinden...';

  @override
  String get terrariumDashboard => 'Terrarium Dashboard';

  @override
  String get dashboard => 'Dashboard';

  @override
  String lastUpdate(Object time) {
    return 'Laatste update: $time';
  }

  @override
  String get loadingStatus => 'Status laden...';

  @override
  String get appSettings => 'App Instellingen';

  @override
  String get darkTheme => 'Donker';

  @override
  String get dutch => 'Nederlands';

  @override
  String get english => 'Engels';

  @override
  String get language => 'Taal';

  @override
  String get lightTheme => 'Licht';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get settings => 'Instellingen';

  @override
  String get systemTheme => 'Systeem';

  @override
  String get theme => 'Thema';

  @override
  String get autonomousControlActive => 'Autonome besturing actief';

  @override
  String get autonomousControlDisabled => 'Autonome besturing uitgeschakeld';

  @override
  String get controlLoopPaused => 'Besturingslus: GEPAUZEERD';

  @override
  String get controlLoopRunning => 'Besturingslus: ACTIEF';

  @override
  String get deviceStatus => 'Apparaat Status';

  @override
  String get manualControlDescription =>
      'Schakel apparaten handmatig in/uit voor testen. Let op: Autonome besturing wordt hervat bij de volgende besturingscyclus.';

  @override
  String get manualEntityControl => 'Handmatige Apparaat Besturing';

  @override
  String get pause => 'Pauzeren';

  @override
  String get resume => 'Hervatten';

  @override
  String get controlLoop => 'Regellus';

  @override
  String get paused => 'Gepauzeerd';

  @override
  String get running => 'Actief';

  @override
  String editScheduleTitle(Object name) {
    return '$name Schema Bewerken';
  }

  @override
  String get heatLight => 'Lamp 2';

  @override
  String get light1 => 'Lamp 1';

  @override
  String get light2 => 'Lamp 2';

  @override
  String get light3 => 'UV Lamp';

  @override
  String get lightEntities => 'Lampen';

  @override
  String get lights => 'Lampen';

  @override
  String get lightSchedules => 'Licht Schema\'s';

  @override
  String get mainLight => 'Lamp 1';

  @override
  String get offTime => 'Uit Tijd';

  @override
  String get onTime => 'Aan Tijd';

  @override
  String get schedule => 'Planning';

  @override
  String get scheduleUpdated => 'Schema bijgewerkt';

  @override
  String get timeFormatHelper => 'Formaat: UU:MM (24-uurs)';

  @override
  String get uvLight => 'UV Lamp';

  @override
  String get editHumidityThresholds => 'Luchtvochtigheid Drempels Bewerken';

  @override
  String failedToUpdate(Object error) {
    return 'Bijwerken mislukt: $error';
  }

  @override
  String gapHysteresis(Object value) {
    return 'Verschil: $value% (hysterese)';
  }

  @override
  String get humidifier => 'Luchtbevochtiger';

  @override
  String get humidity => 'Luchtvochtigheid';

  @override
  String get humidityControl => 'Luchtvochtigheid Besturing';

  @override
  String get humidityThresholds => 'Luchtvochtigheid Drempels';

  @override
  String get maxHumidity => 'Max Luchtvochtigheid';

  @override
  String get maximumTurnOff => 'Maximum (Uitschakelen)';

  @override
  String maximumValue(Object value) {
    return 'Maximum: $value%';
  }

  @override
  String get minHumidity => 'Min Luchtvochtigheid';

  @override
  String get minimumTurnOn => 'Minimum (Inschakelen)';

  @override
  String minimumValue(Object value) {
    return 'Minimum: $value%';
  }

  @override
  String get minMustBeLessThanMax => 'Minimum moet kleiner zijn dan maximum';

  @override
  String get thresholdsUpdated => 'Drempels bijgewerkt';

  @override
  String durationSeconds(Object value) {
    return 'Duur: $value seconden';
  }

  @override
  String get editSprayerConfiguration =>
      'Sproei-installatie Configuratie Bewerken';

  @override
  String get hours => 'uur';

  @override
  String intervalHours(Object value) {
    return 'Interval: $value uur';
  }

  @override
  String get seconds => 'seconden';

  @override
  String get sprayDuration => 'Sproeien Duur';

  @override
  String get sprayer => 'Sproei-installatie';

  @override
  String get sprayerConfigUpdated =>
      'Sproei-installatie configuratie bijgewerkt';

  @override
  String get sprayerConfiguration => 'Sproei-installatie Configuratie';

  @override
  String get sprayerSettings => 'Sproei-installatie Instellingen';

  @override
  String get sprayInterval => 'Sproeien Interval';

  @override
  String get insideHumidity => 'Terrarium Luchtvochtigheid';

  @override
  String get insideTemp => 'Terrarium Temperatuur';

  @override
  String get insideTerrarium => 'Terrarium';

  @override
  String get outside => 'Kamer';

  @override
  String get outsideHumidity => 'Kamer Luchtvochtigheid';

  @override
  String get outsideTemp => 'Kamer Temperatuur';

  @override
  String get readInterval => 'Lees Interval';

  @override
  String get sensorSettings => 'Sensor Instellingen';

  @override
  String get temperature => 'Temperatuur';

  @override
  String get exhaustFan => 'Ventilator Uit';

  @override
  String get fan1 => 'Ventilator In';

  @override
  String get fan2 => 'Ventilator Uit';

  @override
  String get fans => 'Ventilatoren';

  @override
  String get intakeFan => 'Ventilator In';

  @override
  String get otherDevices => 'Andere Apparaten';

  @override
  String get otherEntities => 'Andere Apparaten';

  @override
  String get allEntityTestsCompleted => 'Alle apparaattesten voltooid';

  @override
  String get entityTesting => 'Apparaat Testen';

  @override
  String get entityTestingDescription =>
      'Test individuele apparaten of voer uitgebreide tests uit op alle apparaten.';

  @override
  String get testAllEntities => 'Alle Apparaten Testen';

  @override
  String testCompleted(Object entity) {
    return '$entity test voltooid';
  }

  @override
  String testFailed(Object error) {
    return 'Test mislukt: $error';
  }

  @override
  String get testHumidifier => 'Test Luchtbevochtiger';

  @override
  String get testInfoMessage =>
      'apparaattesten controleren de functionaliteit zonder het besturingssysteem permanent te verstoren. Oorspronkelijke statussen worden hersteld na het testen.';

  @override
  String get testing => 'Testen';

  @override
  String get testingAllEntities => 'Alle apparaten testen...';

  @override
  String testingEntity(Object entity) {
    return '$entity testen...';
  }

  @override
  String get testLight1 => 'Test Lamp 1';

  @override
  String get testLight2 => 'Test Lamp 2';

  @override
  String get testLight3 => 'Test UV lamp';

  @override
  String get testSprayer => 'Test Sproei-installatie';

  @override
  String get history => 'Geschiedenis';

  @override
  String get deviceSwitchingHistory => 'Schakelgeschiedenis Apparaten';

  @override
  String get timeInterval => 'Tijdsinterval:';

  @override
  String get fiveMinutes => '5m';

  @override
  String get tenMinutes => '10m';

  @override
  String get fifteenMinutes => '15m';

  @override
  String get thirtyMinutes => '30m';

  @override
  String get oneHour => '1u';

  @override
  String get noEventsYet => 'Nog Geen Gebeurtenissen';

  @override
  String get deviceStateChangesWillAppearHere =>
      'Apparaatstatuswijzigingen worden hier weergegeven';

  @override
  String get noDataAvailable => 'Geen gegevens beschikbaar';

  @override
  String get time => 'Tijd';
}
