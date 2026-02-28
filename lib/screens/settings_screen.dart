import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_settings.dart';
import '../services/websocket_service_base.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appSettings,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Language Setting
          _SettingCard(
            title: l10n.language,
            icon: Icons.language,
            child: Consumer<AppSettings>(
              builder: (context, settings, child) {
                return SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'en',
                      label: Text(l10n.english),
                      icon: const Icon(Icons.flag),
                    ),
                    ButtonSegment(
                      value: 'nl',
                      label: Text(l10n.dutch),
                      icon: const Icon(Icons.flag),
                    ),
                  ],
                  selected: {settings.locale.languageCode},
                  onSelectionChanged: (Set<String> selection) {
                    settings.setLocale(Locale(selection.first));
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Theme Setting
          _SettingCard(
            title: l10n.theme,
            icon: Icons.palette,
            child: Consumer<AppSettings>(
              builder: (context, settings, child) {
                return SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.lightTheme),
                      icon: const Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.darkTheme),
                      icon: const Icon(Icons.dark_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.systemTheme),
                      icon: const Icon(Icons.brightness_auto),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (Set<ThemeMode> selection) {
                    settings.setThemeMode(selection.first);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Server URL Setting
          _SettingCard(
            title: l10n.serverUrl,
            icon: Icons.dns,
            child: Consumer<WebSocketServiceBase>(
              builder: (context, wsService, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            wsService.serverUrl,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: l10n.edit,
                          onPressed: () => _editServerUrl(context, wsService),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editServerUrl(BuildContext context, WebSocketServiceBase wsService) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: wsService.serverUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.serverUrl),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.serverUrl,
                  hintText: 'ws://192.168.1.100:8765',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              Text(
                'Format: ws://host:port',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.of(context).pop();
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                await wsService.updateServerUrl(newUrl);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.serverUrl} ${l10n.success.toLowerCase()}'),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              }
              controller.dispose();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
