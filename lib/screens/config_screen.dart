import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service_base.dart';
import '../widgets/light_schedule_editor.dart';
import '../widgets/humidity_threshold_editor.dart';
import '../widgets/sprayer_config_editor.dart';
import '../widgets/sensor_config_editor.dart';
import '../widgets/temperature_control_editor.dart';
import '../widgets/alarm_config_editor.dart';
import '../widgets/email_notification_editor.dart';
import '../l10n/app_localizations.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<WebSocketServiceBase>(
      builder: (context, wsService, child) {
        if (!wsService.isConnected) {
          return Center(
            child: Text(l10n.notConnected),
          );
        }

        final config = wsService.currentConfig;
        if (config == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                l10n.configuration,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Light Schedules
              Text(
                l10n.lightSchedules,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: config.control.lights.entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: LightScheduleEditor(
                        lightId: entry.key,
                        lightConfig: entry.value,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Humidity Control and Sprayer Configuration
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.humidityControl,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          HumidityThresholdEditor(
                            config: config.control.humidifier,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.sprayerConfiguration,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SprayerConfigEditor(
                            config: config.control.sprayer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sensor Settings
              Text(
                l10n.sensorSettings,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SensorConfigEditor(
                config: config.control.sensors,
              ),

              const SizedBox(height: 24),

              // Temperature Control
              Text(
                'Temperature Control',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TemperatureControlEditor(
                config: config.control.temperature,
              ),

              const SizedBox(height: 24),

              // Alarms and Notifications
              Text(
                'Alarms & Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AlarmConfigEditor(
                        config: config.control.alarms,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: EmailNotificationEditor(
                        config: config.control.notifications.email,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
            // Loading overlay
            if (wsService.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Saving...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
