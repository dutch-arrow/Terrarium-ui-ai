import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In nl, this message translates to:
  /// **'Terrarium Besturing'**
  String get appTitle;

  /// No description provided for @apply.
  ///
  /// In nl, this message translates to:
  /// **'Toepassen'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In nl, this message translates to:
  /// **'Annuleren'**
  String get cancel;

  /// No description provided for @config.
  ///
  /// In nl, this message translates to:
  /// **'Configuratie'**
  String get config;

  /// No description provided for @configuration.
  ///
  /// In nl, this message translates to:
  /// **'Configuratie'**
  String get configuration;

  /// No description provided for @edit.
  ///
  /// In nl, this message translates to:
  /// **'Bewerken'**
  String get edit;

  /// No description provided for @error.
  ///
  /// In nl, this message translates to:
  /// **'Fout'**
  String get error;

  /// No description provided for @info.
  ///
  /// In nl, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @loading.
  ///
  /// In nl, this message translates to:
  /// **'Laden...'**
  String get loading;

  /// No description provided for @off.
  ///
  /// In nl, this message translates to:
  /// **'UIT'**
  String get off;

  /// No description provided for @offPrefix.
  ///
  /// In nl, this message translates to:
  /// **'UIT'**
  String get offPrefix;

  /// No description provided for @on.
  ///
  /// In nl, this message translates to:
  /// **'AAN'**
  String get on;

  /// No description provided for @onPrefix.
  ///
  /// In nl, this message translates to:
  /// **'AAN'**
  String get onPrefix;

  /// No description provided for @refresh.
  ///
  /// In nl, this message translates to:
  /// **'Ververs'**
  String get refresh;

  /// No description provided for @reset.
  ///
  /// In nl, this message translates to:
  /// **'Resetten'**
  String get reset;

  /// No description provided for @save.
  ///
  /// In nl, this message translates to:
  /// **'Opslaan'**
  String get save;

  /// No description provided for @success.
  ///
  /// In nl, this message translates to:
  /// **'Succes'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In nl, this message translates to:
  /// **'Waarschuwing'**
  String get warning;

  /// No description provided for @clickConnectionIconToConnect.
  ///
  /// In nl, this message translates to:
  /// **'Klik op het verbindingspictogram om verbinding te maken'**
  String get clickConnectionIconToConnect;

  /// No description provided for @connect.
  ///
  /// In nl, this message translates to:
  /// **'Verbinden'**
  String get connect;

  /// No description provided for @connected.
  ///
  /// In nl, this message translates to:
  /// **'Verbonden'**
  String get connected;

  /// No description provided for @connecting.
  ///
  /// In nl, this message translates to:
  /// **'Verbinden...'**
  String get connecting;

  /// No description provided for @connectionError.
  ///
  /// In nl, this message translates to:
  /// **'Verbindingsfout'**
  String get connectionError;

  /// No description provided for @disconnect.
  ///
  /// In nl, this message translates to:
  /// **'Verbreken'**
  String get disconnect;

  /// No description provided for @disconnected.
  ///
  /// In nl, this message translates to:
  /// **'Niet verbonden'**
  String get disconnected;

  /// No description provided for @notConnected.
  ///
  /// In nl, this message translates to:
  /// **'Niet verbonden'**
  String get notConnected;

  /// No description provided for @notConnectedToTerrarium.
  ///
  /// In nl, this message translates to:
  /// **'Niet verbonden met terrarium'**
  String get notConnectedToTerrarium;

  /// No description provided for @reconnecting.
  ///
  /// In nl, this message translates to:
  /// **'Opnieuw verbinden...'**
  String get reconnecting;

  /// No description provided for @terrariumDashboard.
  ///
  /// In nl, this message translates to:
  /// **'Terrarium Dashboard'**
  String get terrariumDashboard;

  /// No description provided for @dashboard.
  ///
  /// In nl, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @lastUpdate.
  ///
  /// In nl, this message translates to:
  /// **'Laatste update: {time}'**
  String lastUpdate(Object time);

  /// No description provided for @loadingStatus.
  ///
  /// In nl, this message translates to:
  /// **'Status laden...'**
  String get loadingStatus;

  /// No description provided for @appSettings.
  ///
  /// In nl, this message translates to:
  /// **'App Instellingen'**
  String get appSettings;

  /// No description provided for @darkTheme.
  ///
  /// In nl, this message translates to:
  /// **'Donker'**
  String get darkTheme;

  /// No description provided for @dutch.
  ///
  /// In nl, this message translates to:
  /// **'Nederlands'**
  String get dutch;

  /// No description provided for @english.
  ///
  /// In nl, this message translates to:
  /// **'Engels'**
  String get english;

  /// No description provided for @language.
  ///
  /// In nl, this message translates to:
  /// **'Taal'**
  String get language;

  /// No description provided for @lightTheme.
  ///
  /// In nl, this message translates to:
  /// **'Licht'**
  String get lightTheme;

  /// No description provided for @serverUrl.
  ///
  /// In nl, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @settings.
  ///
  /// In nl, this message translates to:
  /// **'Instellingen'**
  String get settings;

  /// No description provided for @systemTheme.
  ///
  /// In nl, this message translates to:
  /// **'Systeem'**
  String get systemTheme;

  /// No description provided for @theme.
  ///
  /// In nl, this message translates to:
  /// **'Thema'**
  String get theme;

  /// No description provided for @autonomousControlActive.
  ///
  /// In nl, this message translates to:
  /// **'Autonome besturing actief'**
  String get autonomousControlActive;

  /// No description provided for @autonomousControlDisabled.
  ///
  /// In nl, this message translates to:
  /// **'Autonome besturing uitgeschakeld'**
  String get autonomousControlDisabled;

  /// No description provided for @controlLoopPaused.
  ///
  /// In nl, this message translates to:
  /// **'Besturingslus: GEPAUZEERD'**
  String get controlLoopPaused;

  /// No description provided for @controlLoopRunning.
  ///
  /// In nl, this message translates to:
  /// **'Besturingslus: ACTIEF'**
  String get controlLoopRunning;

  /// No description provided for @deviceStatus.
  ///
  /// In nl, this message translates to:
  /// **'Apparaat Status'**
  String get deviceStatus;

  /// No description provided for @manualControlDescription.
  ///
  /// In nl, this message translates to:
  /// **'Schakel apparaten handmatig in/uit voor testen. Let op: Autonome besturing wordt hervat bij de volgende besturingscyclus.'**
  String get manualControlDescription;

  /// No description provided for @manualEntityControl.
  ///
  /// In nl, this message translates to:
  /// **'Handmatige Apparaat Besturing'**
  String get manualEntityControl;

  /// No description provided for @pause.
  ///
  /// In nl, this message translates to:
  /// **'Pauzeren'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In nl, this message translates to:
  /// **'Hervatten'**
  String get resume;

  /// No description provided for @controlLoop.
  ///
  /// In nl, this message translates to:
  /// **'Regellus'**
  String get controlLoop;

  /// No description provided for @paused.
  ///
  /// In nl, this message translates to:
  /// **'Gepauzeerd'**
  String get paused;

  /// No description provided for @running.
  ///
  /// In nl, this message translates to:
  /// **'Actief'**
  String get running;

  /// No description provided for @editScheduleTitle.
  ///
  /// In nl, this message translates to:
  /// **'{name} Schema Bewerken'**
  String editScheduleTitle(Object name);

  /// No description provided for @heatLight.
  ///
  /// In nl, this message translates to:
  /// **'Lamp 2'**
  String get heatLight;

  /// No description provided for @light1.
  ///
  /// In nl, this message translates to:
  /// **'Lamp 1'**
  String get light1;

  /// No description provided for @light2.
  ///
  /// In nl, this message translates to:
  /// **'Lamp 2'**
  String get light2;

  /// No description provided for @light3.
  ///
  /// In nl, this message translates to:
  /// **'UV Lamp'**
  String get light3;

  /// No description provided for @lightEntities.
  ///
  /// In nl, this message translates to:
  /// **'Lampen'**
  String get lightEntities;

  /// No description provided for @lights.
  ///
  /// In nl, this message translates to:
  /// **'Lampen'**
  String get lights;

  /// No description provided for @lightSchedules.
  ///
  /// In nl, this message translates to:
  /// **'Licht Schema\'s'**
  String get lightSchedules;

  /// No description provided for @mainLight.
  ///
  /// In nl, this message translates to:
  /// **'Lamp 1'**
  String get mainLight;

  /// No description provided for @offTime.
  ///
  /// In nl, this message translates to:
  /// **'Uit Tijd'**
  String get offTime;

  /// No description provided for @onTime.
  ///
  /// In nl, this message translates to:
  /// **'Aan Tijd'**
  String get onTime;

  /// No description provided for @schedule.
  ///
  /// In nl, this message translates to:
  /// **'Planning'**
  String get schedule;

  /// No description provided for @scheduleUpdated.
  ///
  /// In nl, this message translates to:
  /// **'Schema bijgewerkt'**
  String get scheduleUpdated;

  /// No description provided for @timeFormatHelper.
  ///
  /// In nl, this message translates to:
  /// **'Formaat: UU:MM (24-uurs)'**
  String get timeFormatHelper;

  /// No description provided for @uvLight.
  ///
  /// In nl, this message translates to:
  /// **'UV Lamp'**
  String get uvLight;

  /// No description provided for @editHumidityThresholds.
  ///
  /// In nl, this message translates to:
  /// **'Luchtvochtigheid Drempels Bewerken'**
  String get editHumidityThresholds;

  /// No description provided for @failedToUpdate.
  ///
  /// In nl, this message translates to:
  /// **'Bijwerken mislukt: {error}'**
  String failedToUpdate(Object error);

  /// No description provided for @gapHysteresis.
  ///
  /// In nl, this message translates to:
  /// **'Verschil: {value}% (hysterese)'**
  String gapHysteresis(Object value);

  /// No description provided for @humidifier.
  ///
  /// In nl, this message translates to:
  /// **'Luchtbevochtiger'**
  String get humidifier;

  /// No description provided for @humidity.
  ///
  /// In nl, this message translates to:
  /// **'Luchtvochtigheid'**
  String get humidity;

  /// No description provided for @humidityControl.
  ///
  /// In nl, this message translates to:
  /// **'Luchtvochtigheid Besturing'**
  String get humidityControl;

  /// No description provided for @humidityThresholds.
  ///
  /// In nl, this message translates to:
  /// **'Luchtvochtigheid Drempels'**
  String get humidityThresholds;

  /// No description provided for @maxHumidity.
  ///
  /// In nl, this message translates to:
  /// **'Max Luchtvochtigheid'**
  String get maxHumidity;

  /// No description provided for @maximumTurnOff.
  ///
  /// In nl, this message translates to:
  /// **'Maximum (Uitschakelen)'**
  String get maximumTurnOff;

  /// No description provided for @maximumValue.
  ///
  /// In nl, this message translates to:
  /// **'Maximum: {value}%'**
  String maximumValue(Object value);

  /// No description provided for @minHumidity.
  ///
  /// In nl, this message translates to:
  /// **'Min Luchtvochtigheid'**
  String get minHumidity;

  /// No description provided for @minimumTurnOn.
  ///
  /// In nl, this message translates to:
  /// **'Minimum (Inschakelen)'**
  String get minimumTurnOn;

  /// No description provided for @minimumValue.
  ///
  /// In nl, this message translates to:
  /// **'Minimum: {value}%'**
  String minimumValue(Object value);

  /// No description provided for @minMustBeLessThanMax.
  ///
  /// In nl, this message translates to:
  /// **'Minimum moet kleiner zijn dan maximum'**
  String get minMustBeLessThanMax;

  /// No description provided for @thresholdsUpdated.
  ///
  /// In nl, this message translates to:
  /// **'Drempels bijgewerkt'**
  String get thresholdsUpdated;

  /// No description provided for @durationSeconds.
  ///
  /// In nl, this message translates to:
  /// **'Duur: {value} seconden'**
  String durationSeconds(Object value);

  /// No description provided for @editSprayerConfiguration.
  ///
  /// In nl, this message translates to:
  /// **'Sproei-installatie Configuratie Bewerken'**
  String get editSprayerConfiguration;

  /// No description provided for @hours.
  ///
  /// In nl, this message translates to:
  /// **'uur'**
  String get hours;

  /// No description provided for @intervalHours.
  ///
  /// In nl, this message translates to:
  /// **'Interval: {value} uur'**
  String intervalHours(Object value);

  /// No description provided for @seconds.
  ///
  /// In nl, this message translates to:
  /// **'seconden'**
  String get seconds;

  /// No description provided for @sprayDuration.
  ///
  /// In nl, this message translates to:
  /// **'Sproeien Duur'**
  String get sprayDuration;

  /// No description provided for @sprayer.
  ///
  /// In nl, this message translates to:
  /// **'Sproei-installatie'**
  String get sprayer;

  /// No description provided for @sprayerConfigUpdated.
  ///
  /// In nl, this message translates to:
  /// **'Sproei-installatie configuratie bijgewerkt'**
  String get sprayerConfigUpdated;

  /// No description provided for @sprayerConfiguration.
  ///
  /// In nl, this message translates to:
  /// **'Sproei-installatie Configuratie'**
  String get sprayerConfiguration;

  /// No description provided for @sprayerSettings.
  ///
  /// In nl, this message translates to:
  /// **'Sproei-installatie Instellingen'**
  String get sprayerSettings;

  /// No description provided for @sprayInterval.
  ///
  /// In nl, this message translates to:
  /// **'Sproeien Interval'**
  String get sprayInterval;

  /// No description provided for @insideHumidity.
  ///
  /// In nl, this message translates to:
  /// **'Terrarium Luchtvochtigheid'**
  String get insideHumidity;

  /// No description provided for @insideTemp.
  ///
  /// In nl, this message translates to:
  /// **'Terrarium Temperatuur'**
  String get insideTemp;

  /// No description provided for @insideTerrarium.
  ///
  /// In nl, this message translates to:
  /// **'Terrarium'**
  String get insideTerrarium;

  /// No description provided for @outside.
  ///
  /// In nl, this message translates to:
  /// **'Kamer'**
  String get outside;

  /// No description provided for @outsideHumidity.
  ///
  /// In nl, this message translates to:
  /// **'Kamer Luchtvochtigheid'**
  String get outsideHumidity;

  /// No description provided for @outsideTemp.
  ///
  /// In nl, this message translates to:
  /// **'Kamer Temperatuur'**
  String get outsideTemp;

  /// No description provided for @readInterval.
  ///
  /// In nl, this message translates to:
  /// **'Lees Interval'**
  String get readInterval;

  /// No description provided for @sensorSettings.
  ///
  /// In nl, this message translates to:
  /// **'Sensor Instellingen'**
  String get sensorSettings;

  /// No description provided for @temperature.
  ///
  /// In nl, this message translates to:
  /// **'Temperatuur'**
  String get temperature;

  /// No description provided for @exhaustFan.
  ///
  /// In nl, this message translates to:
  /// **'Ventilator Uit'**
  String get exhaustFan;

  /// No description provided for @fan1.
  ///
  /// In nl, this message translates to:
  /// **'Ventilator In'**
  String get fan1;

  /// No description provided for @fan2.
  ///
  /// In nl, this message translates to:
  /// **'Ventilator Uit'**
  String get fan2;

  /// No description provided for @fans.
  ///
  /// In nl, this message translates to:
  /// **'Ventilatoren'**
  String get fans;

  /// No description provided for @intakeFan.
  ///
  /// In nl, this message translates to:
  /// **'Ventilator In'**
  String get intakeFan;

  /// No description provided for @otherDevices.
  ///
  /// In nl, this message translates to:
  /// **'Andere Apparaten'**
  String get otherDevices;

  /// No description provided for @otherEntities.
  ///
  /// In nl, this message translates to:
  /// **'Andere Apparaten'**
  String get otherEntities;

  /// No description provided for @allEntityTestsCompleted.
  ///
  /// In nl, this message translates to:
  /// **'Alle apparaattesten voltooid'**
  String get allEntityTestsCompleted;

  /// No description provided for @entityTesting.
  ///
  /// In nl, this message translates to:
  /// **'Apparaat Testen'**
  String get entityTesting;

  /// No description provided for @entityTestingDescription.
  ///
  /// In nl, this message translates to:
  /// **'Test individuele apparaten of voer uitgebreide tests uit op alle apparaten.'**
  String get entityTestingDescription;

  /// No description provided for @testAllEntities.
  ///
  /// In nl, this message translates to:
  /// **'Alle Apparaten Testen'**
  String get testAllEntities;

  /// No description provided for @testCompleted.
  ///
  /// In nl, this message translates to:
  /// **'{entity} test voltooid'**
  String testCompleted(Object entity);

  /// No description provided for @testFailed.
  ///
  /// In nl, this message translates to:
  /// **'Test mislukt: {error}'**
  String testFailed(Object error);

  /// No description provided for @testHumidifier.
  ///
  /// In nl, this message translates to:
  /// **'Test Luchtbevochtiger'**
  String get testHumidifier;

  /// No description provided for @testInfoMessage.
  ///
  /// In nl, this message translates to:
  /// **'apparaattesten controleren de functionaliteit zonder het besturingssysteem permanent te verstoren. Oorspronkelijke statussen worden hersteld na het testen.'**
  String get testInfoMessage;

  /// No description provided for @testing.
  ///
  /// In nl, this message translates to:
  /// **'Testen'**
  String get testing;

  /// No description provided for @testingAllEntities.
  ///
  /// In nl, this message translates to:
  /// **'Alle apparaten testen...'**
  String get testingAllEntities;

  /// No description provided for @testingEntity.
  ///
  /// In nl, this message translates to:
  /// **'{entity} testen...'**
  String testingEntity(Object entity);

  /// No description provided for @testLight1.
  ///
  /// In nl, this message translates to:
  /// **'Test Lamp 1'**
  String get testLight1;

  /// No description provided for @testLight2.
  ///
  /// In nl, this message translates to:
  /// **'Test Lamp 2'**
  String get testLight2;

  /// No description provided for @testLight3.
  ///
  /// In nl, this message translates to:
  /// **'Test UV lamp'**
  String get testLight3;

  /// No description provided for @testSprayer.
  ///
  /// In nl, this message translates to:
  /// **'Test Sproei-installatie'**
  String get testSprayer;

  /// No description provided for @history.
  ///
  /// In nl, this message translates to:
  /// **'Geschiedenis'**
  String get history;

  /// No description provided for @deviceSwitchingHistory.
  ///
  /// In nl, this message translates to:
  /// **'Schakelgeschiedenis Apparaten'**
  String get deviceSwitchingHistory;

  /// No description provided for @timeInterval.
  ///
  /// In nl, this message translates to:
  /// **'Tijdsinterval:'**
  String get timeInterval;

  /// No description provided for @fiveMinutes.
  ///
  /// In nl, this message translates to:
  /// **'5m'**
  String get fiveMinutes;

  /// No description provided for @tenMinutes.
  ///
  /// In nl, this message translates to:
  /// **'10m'**
  String get tenMinutes;

  /// No description provided for @fifteenMinutes.
  ///
  /// In nl, this message translates to:
  /// **'15m'**
  String get fifteenMinutes;

  /// No description provided for @thirtyMinutes.
  ///
  /// In nl, this message translates to:
  /// **'30m'**
  String get thirtyMinutes;

  /// No description provided for @oneHour.
  ///
  /// In nl, this message translates to:
  /// **'1u'**
  String get oneHour;

  /// No description provided for @noEventsYet.
  ///
  /// In nl, this message translates to:
  /// **'Nog Geen Gebeurtenissen'**
  String get noEventsYet;

  /// No description provided for @deviceStateChangesWillAppearHere.
  ///
  /// In nl, this message translates to:
  /// **'Apparaatstatuswijzigingen worden hier weergegeven'**
  String get deviceStateChangesWillAppearHere;

  /// No description provided for @noDataAvailable.
  ///
  /// In nl, this message translates to:
  /// **'Geen gegevens beschikbaar'**
  String get noDataAvailable;

  /// No description provided for @time.
  ///
  /// In nl, this message translates to:
  /// **'Tijd'**
  String get time;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
