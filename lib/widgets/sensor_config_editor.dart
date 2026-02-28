import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/terrarium_config.dart';
import '../services/websocket_service_base.dart';
import '../l10n/app_localizations.dart';

class SensorConfigEditor extends StatelessWidget {
  final SensorConfig config;

  const SensorConfigEditor({
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.readInterval,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${config.readIntervalSeconds} ${l10n.seconds}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _editSensorConfig(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(l10n.edit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editSensorConfig(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SensorConfigEditDialog(
        currentConfig: config,
      ),
    );
  }
}

class _SensorConfigEditDialog extends StatefulWidget {
  final SensorConfig currentConfig;

  const _SensorConfigEditDialog({
    required this.currentConfig,
  });

  @override
  State<_SensorConfigEditDialog> createState() =>
      _SensorConfigEditDialogState();
}

class _SensorConfigEditDialogState extends State<_SensorConfigEditDialog> {
  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController(
      text: widget.currentConfig.readIntervalSeconds.toString(),
    );
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final wsService = context.read<WebSocketServiceBase>();
    final l10n = AppLocalizations.of(context)!;

    try {
      final intervalSeconds = int.parse(_intervalController.text);

      if (intervalSeconds < 1) {
        throw Exception('Interval must be at least 1 second');
      }

      await wsService.setSensorInterval(intervalSeconds);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.sensorSettings} ${l10n.success.toLowerCase()}'),
          ),
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
          title: Text(l10n.sensorSettings),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _intervalController,
                  decoration: InputDecoration(
                    labelText: '${l10n.readInterval} (${l10n.seconds})',
                    hintText: '60',
                    helperText: 'Minimum: 1 second',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !isLoading,
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
              ],
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
