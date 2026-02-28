import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/terrarium_config.dart';
import '../services/websocket_service_base.dart';
import '../l10n/app_localizations.dart';

class AlarmConfigEditor extends StatelessWidget {
  final AlarmConfig config;

  const AlarmConfigEditor({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alarm Configuration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () => _editConfig(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(l10n.edit),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  config.enabled ? Icons.notifications_active : Icons.notifications_off,
                  size: 20,
                  color: config.enabled ? Colors.orange : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  config.enabled ? 'Alarms Enabled' : 'Alarms Disabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: config.enabled ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Temperature', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${config.temperature.lowAlarm.toStringAsFixed(1)}°C - ${config.temperature.highAlarm.toStringAsFixed(1)}°C',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Humidity', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${config.humidity.lowAlarm.toStringAsFixed(0)}% - ${config.humidity.highAlarm.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cooldown', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${config.cooldownMinutes} min',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editConfig(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AlarmConfigDialog(config: config),
    );
  }
}

class _AlarmConfigDialog extends StatefulWidget {
  final AlarmConfig config;

  const _AlarmConfigDialog({required this.config});

  @override
  State<_AlarmConfigDialog> createState() => _AlarmConfigDialogState();
}

class _AlarmConfigDialogState extends State<_AlarmConfigDialog> {
  late bool _enabled;
  late double _tempHighAlarm;
  late double _tempLowAlarm;
  late double _humidityHighAlarm;
  late double _humidityLowAlarm;
  late bool _sensorFailureAlarm;
  late int _cooldownMinutes;

  @override
  void initState() {
    super.initState();
    _enabled = widget.config.enabled;
    _tempHighAlarm = widget.config.temperature.highAlarm;
    _tempLowAlarm = widget.config.temperature.lowAlarm;
    _humidityHighAlarm = widget.config.humidity.highAlarm;
    _humidityLowAlarm = widget.config.humidity.lowAlarm;
    _sensorFailureAlarm = widget.config.sensorFailureAlarm;
    _cooldownMinutes = widget.config.cooldownMinutes;
  }

  Future<void> _save() async {
    final wsService = context.read<WebSocketServiceBase>();
    final l10n = AppLocalizations.of(context)!;

    try {
      final config = {
        'enabled': _enabled,
        'temperature': {
          'high_alarm': _tempHighAlarm,
          'low_alarm': _tempLowAlarm,
        },
        'humidity': {
          'high_alarm': _humidityHighAlarm,
          'low_alarm': _humidityLowAlarm,
        },
        'sensor_failure_alarm': _sensorFailureAlarm,
        'cooldown_minutes': _cooldownMinutes,
      };

      await wsService.setAlarmConfig(config);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alarm configuration updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToUpdate(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<WebSocketServiceBase>(
      builder: (context, wsService, child) {
        final isLoading = wsService.isLoading;

        return AlertDialog(
          title: const Text('Edit Alarm Configuration'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Master Enable Switch
                  SwitchListTile(
                    title: const Text('Enable Alarms'),
                    subtitle: const Text('Turn alarm monitoring on/off'),
                    value: _enabled,
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _enabled = value;
                      });
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Temperature Alarms
                  Text(
                    'Temperature Alarms',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('High Alarm: ${_tempHighAlarm.toStringAsFixed(1)}°C'),
                  Slider(
                    value: _tempHighAlarm,
                    min: 25,
                    max: 40,
                    divisions: 30,
                    label: '${_tempHighAlarm.toStringAsFixed(1)}°C',
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _tempHighAlarm = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Low Alarm: ${_tempLowAlarm.toStringAsFixed(1)}°C'),
                  Slider(
                    value: _tempLowAlarm,
                    min: 10,
                    max: 22,
                    divisions: 24,
                    label: '${_tempLowAlarm.toStringAsFixed(1)}°C',
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _tempLowAlarm = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Humidity Alarms
                  Text(
                    'Humidity Alarms',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('High Alarm: ${_humidityHighAlarm.toStringAsFixed(0)}%'),
                  Slider(
                    value: _humidityHighAlarm,
                    min: 70,
                    max: 100,
                    divisions: 30,
                    label: '${_humidityHighAlarm.toStringAsFixed(0)}%',
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _humidityHighAlarm = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Low Alarm: ${_humidityLowAlarm.toStringAsFixed(0)}%'),
                  Slider(
                    value: _humidityLowAlarm,
                    min: 20,
                    max: 60,
                    divisions: 40,
                    label: '${_humidityLowAlarm.toStringAsFixed(0)}%',
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _humidityLowAlarm = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Other Settings
                  Text(
                    'Other Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Sensor Failure Alarm'),
                    subtitle: const Text('Alert when sensors fail to read'),
                    value: _sensorFailureAlarm,
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _sensorFailureAlarm = value ?? true;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Cooldown Period: $_cooldownMinutes minutes'),
                  Slider(
                    value: _cooldownMinutes.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 22,
                    label: '$_cooldownMinutes min',
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _cooldownMinutes = value.toInt();
                      });
                    },
                  ),

                  if (isLoading) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: isLoading ? null : _save,
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}
