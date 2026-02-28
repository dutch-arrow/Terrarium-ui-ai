import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/terrarium_config.dart';
import '../services/websocket_service_base.dart';
import '../l10n/app_localizations.dart';

class HumidityThresholdEditor extends StatelessWidget {
  final HumidifierConfig config;

  const HumidityThresholdEditor({
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
                  l10n.humidityThresholds,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () => _editThresholds(context),
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
                      Text(l10n.minimumTurnOn),
                      const SizedBox(height: 4),
                      Text(
                        '${config.minHumidity.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.maximumTurnOff),
                      const SizedBox(height: 4),
                      Text(
                        '${config.maxHumidity.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.headlineSmall,
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

  void _editThresholds(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ThresholdEditDialog(config: config),
    );
  }
}

class _ThresholdEditDialog extends StatefulWidget {
  final HumidifierConfig config;

  const _ThresholdEditDialog({required this.config});

  @override
  State<_ThresholdEditDialog> createState() => _ThresholdEditDialogState();
}

class _ThresholdEditDialogState extends State<_ThresholdEditDialog> {
  late double _minHumidity;
  late double _maxHumidity;

  @override
  void initState() {
    super.initState();
    _minHumidity = widget.config.minHumidity;
    _maxHumidity = widget.config.maxHumidity;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;

    if (_minHumidity >= _maxHumidity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.minMustBeLessThanMax)),
      );
      return;
    }

    final wsService = context.read<WebSocketServiceBase>();

    try {
      await wsService.setHumidityThresholds(_minHumidity, _maxHumidity);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.thresholdsUpdated)),
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
          title: Text(l10n.editHumidityThresholds),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.minimumValue(_minHumidity.toStringAsFixed(0)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _minHumidity,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${_minHumidity.toStringAsFixed(0)}%',
                  onChanged: isLoading ? null : (value) {
                    setState(() {
                      _minHumidity = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.maximumValue(_maxHumidity.toStringAsFixed(0)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _maxHumidity,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${_maxHumidity.toStringAsFixed(0)}%',
                  onChanged: isLoading ? null : (value) {
                    setState(() {
                      _maxHumidity = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.gapHysteresis((_maxHumidity - _minHumidity).toStringAsFixed(0)),
                  style: Theme.of(context).textTheme.bodySmall,
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
