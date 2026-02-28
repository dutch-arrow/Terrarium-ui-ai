import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/terrarium_config.dart';
import '../services/websocket_service_base.dart';
import '../l10n/app_localizations.dart';

class LightScheduleEditor extends StatelessWidget {
  final String lightId;
  final LightConfig lightConfig;

  const LightScheduleEditor({
    super.key,
    required this.lightId,
    required this.lightConfig,
  });

  String _getTranslatedLightName(AppLocalizations l10n) {
    switch (lightId) {
      case 'light1':
        return l10n.light1;
      case 'light2':
        return l10n.light2;
      case 'light3':
        return l10n.light3;
      default:
        return lightConfig.name;
    }
  }

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
                  _getTranslatedLightName(l10n),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () => _editSchedule(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(l10n.edit),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.wb_twilight, size: 20),
                const SizedBox(width: 8),
                Text('${l10n.onPrefix}: ${lightConfig.schedule.onTime}'),
                const SizedBox(width: 24),
                const Icon(Icons.nightlight, size: 20),
                const SizedBox(width: 8),
                Text('${l10n.offPrefix}: ${lightConfig.schedule.offTime}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editSchedule(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => _ScheduleEditDialog(
        lightId: lightId,
        lightName: _getTranslatedLightName(l10n),
        currentSchedule: lightConfig.schedule,
      ),
    );
  }
}

class _ScheduleEditDialog extends StatefulWidget {
  final String lightId;
  final String lightName;
  final LightSchedule currentSchedule;

  const _ScheduleEditDialog({
    required this.lightId,
    required this.lightName,
    required this.currentSchedule,
  });

  @override
  State<_ScheduleEditDialog> createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends State<_ScheduleEditDialog> {
  late TextEditingController _onTimeController;
  late TextEditingController _offTimeController;

  @override
  void initState() {
    super.initState();
    _onTimeController = TextEditingController(text: widget.currentSchedule.onTime);
    _offTimeController = TextEditingController(text: widget.currentSchedule.offTime);
  }

  @override
  void dispose() {
    _onTimeController.dispose();
    _offTimeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final wsService = context.read<WebSocketServiceBase>();
    final l10n = AppLocalizations.of(context)!;

    try {
      await wsService.setLightSchedule(
        widget.lightId,
        _onTimeController.text,
        _offTimeController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.scheduleUpdated)),
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
          title: Text(l10n.editScheduleTitle(widget.lightName)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _onTimeController,
                  decoration: InputDecoration(
                    labelText: l10n.onTime,
                    hintText: '08:00',
                    helperText: l10n.timeFormatHelper,
                    border: const OutlineInputBorder(),
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _offTimeController,
                  decoration: InputDecoration(
                    labelText: l10n.offTime,
                    hintText: '20:00',
                    helperText: l10n.timeFormatHelper,
                    border: const OutlineInputBorder(),
                  ),
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
