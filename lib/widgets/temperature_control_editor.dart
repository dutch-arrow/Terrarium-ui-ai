import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/terrarium_config.dart';
import '../services/websocket_service_base.dart';

class TemperatureControlEditor extends StatelessWidget {
  final TemperatureConfig config;

  const TemperatureControlEditor({
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
                  'Temperature Control',
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Temp'),
                      const SizedBox(height: 4),
                      Text(
                        '${config.targetTemp.toStringAsFixed(1)}°${config.unit}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Low Threshold'),
                      const SizedBox(height: 4),
                      Text(
                        '${config.lowThreshold.toStringAsFixed(1)}°${config.unit}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('High Threshold'),
                      const SizedBox(height: 4),
                      Text(
                        '${config.highThreshold.toStringAsFixed(1)}°${config.unit}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  config.heating.enabled ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: config.heating.enabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text('Heating: ${config.heating.enabled ? "Enabled" : "Disabled"}'),
                const SizedBox(width: 16),
                Icon(
                  config.cooling.enabled ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: config.cooling.enabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text('Cooling: ${config.cooling.enabled ? "Enabled" : "Disabled"}'),
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
      builder: (context) => _TemperatureControlDialog(config: config),
    );
  }
}

class _TemperatureControlDialog extends StatefulWidget {
  final TemperatureConfig config;

  const _TemperatureControlDialog({required this.config});

  @override
  State<_TemperatureControlDialog> createState() => _TemperatureControlDialogState();
}

class _TemperatureControlDialogState extends State<_TemperatureControlDialog> {
  late double _targetTemp;
  late double _lowThreshold;
  late double _highThreshold;
  late bool _heatingEnabled;
  late bool _coolingEnabled;
  late int _step1Duration;
  late int _step2Duration;
  late int _step3Duration;
  late int _waitInterval;

  @override
  void initState() {
    super.initState();
    _targetTemp = widget.config.targetTemp;
    _lowThreshold = widget.config.lowThreshold;
    _highThreshold = widget.config.highThreshold;
    _heatingEnabled = widget.config.heating.enabled;
    _coolingEnabled = widget.config.cooling.enabled;
    _step1Duration = widget.config.cooling.escalation.step1HumidifierDurationSeconds;
    _step2Duration = widget.config.cooling.escalation.step2HumidifierDurationSeconds;
    _step3Duration = widget.config.cooling.escalation.step3SprayerDurationSeconds;
    _waitInterval = widget.config.cooling.escalation.waitIntervalMinutes;
  }

  Future<void> _save() async {
    final wsService = context.read<WebSocketServiceBase>();
    final l10n = AppLocalizations.of(context)!;

    try {
      // Build the temperature config object
      final config = {
        'target_temp': _targetTemp,
        'low_threshold': _lowThreshold,
        'high_threshold': _highThreshold,
        'unit': 'C',
        'heating': {
          'enabled': _heatingEnabled,
          'method': 'intake_fan',
          'fan_id': 'fan1',
        },
        'cooling': {
          'enabled': _coolingEnabled,
          'escalation': {
            'step1_humidifier_duration_seconds': _step1Duration,
            'step2_humidifier_duration_seconds': _step2Duration,
            'step3_sprayer_duration_seconds': _step3Duration,
            'wait_interval_minutes': _waitInterval,
          },
        },
      };

      await wsService.setTemperatureControl(config);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Temperature control updated')),
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
          title: const Text('Edit Temperature Control'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thresholds Section
                  Text(
                    'Temperature Thresholds',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Target Temperature: ${_targetTemp.toStringAsFixed(1)}°C'),
                  Slider(
                    value: _targetTemp,
                    min: 18,
                    max: 32,
                    divisions: 28,
                    label: '${_targetTemp.toStringAsFixed(1)}°C',
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _targetTemp = value;
                            });
                          },
                  ),
                  const SizedBox(height: 8),
                  Text('Low Threshold: ${_lowThreshold.toStringAsFixed(1)}°C'),
                  Slider(
                    value: _lowThreshold,
                    min: 15,
                    max: 25,
                    divisions: 20,
                    label: '${_lowThreshold.toStringAsFixed(1)}°C',
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _lowThreshold = value;
                            });
                          },
                  ),
                  const SizedBox(height: 8),
                  Text('High Threshold: ${_highThreshold.toStringAsFixed(1)}°C'),
                  Slider(
                    value: _highThreshold,
                    min: 22,
                    max: 35,
                    divisions: 26,
                    label: '${_highThreshold.toStringAsFixed(1)}°C',
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _highThreshold = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Heating/Cooling Toggles
                  CheckboxListTile(
                    title: const Text('Enable Heating'),
                    subtitle: const Text('Use intake fan when temp is too low'),
                    value: _heatingEnabled,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _heatingEnabled = value ?? false;
                            });
                          },
                  ),
                  CheckboxListTile(
                    title: const Text('Enable Cooling'),
                    subtitle: const Text('Use escalating strategy when temp is too high'),
                    value: _coolingEnabled,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _coolingEnabled = value ?? false;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Cooling Escalation
                  if (_coolingEnabled) ...[
                    Text(
                      'Cooling Escalation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Step 1 - Humidifier Duration: ${_step1Duration}s'),
                    Slider(
                      value: _step1Duration.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${_step1Duration}s',
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _step1Duration = value.toInt();
                              });
                            },
                    ),
                    const SizedBox(height: 8),
                    Text('Step 2 - Humidifier Duration: ${_step2Duration}s'),
                    Slider(
                      value: _step2Duration.toDouble(),
                      min: 10,
                      max: 120,
                      divisions: 22,
                      label: '${_step2Duration}s',
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _step2Duration = value.toInt();
                              });
                            },
                    ),
                    const SizedBox(height: 8),
                    Text('Step 3 - Sprayer Duration: ${_step3Duration}s'),
                    Slider(
                      value: _step3Duration.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${_step3Duration}s',
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _step3Duration = value.toInt();
                              });
                            },
                    ),
                    const SizedBox(height: 8),
                    Text('Wait Interval: $_waitInterval minutes'),
                    Slider(
                      value: _waitInterval.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${_waitInterval}min',
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _waitInterval = value.toInt();
                              });
                            },
                    ),
                  ],

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
