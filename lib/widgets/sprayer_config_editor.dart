import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/terrarium_config.dart';
import '../services/websocket_service_base.dart';
import '../l10n/app_localizations.dart';

class SprayerConfigEditor extends StatelessWidget {
  final SprayerConfig config;

  const SprayerConfigEditor({
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
                  l10n.sprayerSettings,
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
                      Text(l10n.sprayDuration),
                      const SizedBox(height: 4),
                      Text(
                        '${config.sprayDurationSeconds.toStringAsFixed(0)}s',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.sprayInterval),
                      const SizedBox(height: 4),
                      Text(
                        '${config.sprayIntervalHours.toStringAsFixed(1)}h',
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

  void _editConfig(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SprayerConfigDialog(config: config),
    );
  }
}

class _SprayerConfigDialog extends StatefulWidget {
  final SprayerConfig config;

  const _SprayerConfigDialog({required this.config});

  @override
  State<_SprayerConfigDialog> createState() => _SprayerConfigDialogState();
}

class _SprayerConfigDialogState extends State<_SprayerConfigDialog> {
  late double _duration;
  late double _interval;

  @override
  void initState() {
    super.initState();
    _duration = widget.config.sprayDurationSeconds;
    _interval = widget.config.sprayIntervalHours;
  }

  Future<void> _save() async {
    final wsService = context.read<WebSocketServiceBase>();
    final l10n = AppLocalizations.of(context)!;

    try {
      await wsService.setSprayerConfig(_duration, _interval);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sprayerConfigUpdated)),
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
          title: Text(l10n.editSprayerConfiguration),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.durationSeconds(_duration.toStringAsFixed(0)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _duration,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '${_duration.toStringAsFixed(0)}s',
                  onChanged: isLoading ? null : (value) {
                    setState(() {
                      _duration = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.intervalHours(_interval.toStringAsFixed(1)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _interval,
                  min: 0.5,
                  max: 12,
                  divisions: 23,
                  label: '${_interval.toStringAsFixed(1)}h',
                  onChanged: isLoading ? null : (value) {
                    setState(() {
                      _interval = value;
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
