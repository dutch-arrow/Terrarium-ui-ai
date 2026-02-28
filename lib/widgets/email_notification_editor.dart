import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/terrarium_config.dart';
import '../services/websocket_service_base.dart';
import '../l10n/app_localizations.dart';

class EmailNotificationEditor extends StatelessWidget {
  final EmailConfig config;

  const EmailNotificationEditor({
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
                  'Email Notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    if (config.enabled)
                      TextButton.icon(
                        onPressed: () => _testEmail(context),
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('Test'),
                      ),
                    TextButton.icon(
                      onPressed: () => _editConfig(context),
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text(l10n.edit),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  config.enabled ? Icons.mail : Icons.mail_outline,
                  size: 20,
                  color: config.enabled ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  config.enabled ? 'Notifications Enabled' : 'Notifications Disabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: config.enabled ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (config.enabled) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Server', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${config.smtpServer}:${config.smtpPort}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('From', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          config.senderEmail,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('To', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          config.recipientEmail,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _testEmail(BuildContext context) async {
    final wsService = context.read<WebSocketServiceBase>();
    try {
      await wsService.testEmail();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test email sent! Check your inbox.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send test email: $e')),
        );
      }
    }
  }

  void _editConfig(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EmailNotificationDialog(config: config),
    );
  }
}

class _EmailNotificationDialog extends StatefulWidget {
  final EmailConfig config;

  const _EmailNotificationDialog({required this.config});

  @override
  State<_EmailNotificationDialog> createState() => _EmailNotificationDialogState();
}

class _EmailNotificationDialogState extends State<_EmailNotificationDialog> {
  late bool _enabled;
  late TextEditingController _smtpServerController;
  late TextEditingController _smtpPortController;
  late bool _useTls;
  late TextEditingController _senderEmailController;
  late TextEditingController _senderPasswordController;
  late TextEditingController _senderNameController;
  late TextEditingController _recipientEmailController;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.config.enabled;
    _smtpServerController = TextEditingController(text: widget.config.smtpServer);
    _smtpPortController = TextEditingController(text: widget.config.smtpPort.toString());
    _useTls = widget.config.useTls;
    _senderEmailController = TextEditingController(text: widget.config.senderEmail);
    _senderPasswordController = TextEditingController(text: widget.config.senderPassword);
    _senderNameController = TextEditingController(text: widget.config.senderName);
    _recipientEmailController = TextEditingController(text: widget.config.recipientEmail);
  }

  @override
  void dispose() {
    _smtpServerController.dispose();
    _smtpPortController.dispose();
    _senderEmailController.dispose();
    _senderPasswordController.dispose();
    _senderNameController.dispose();
    _recipientEmailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final wsService = context.read<WebSocketServiceBase>();
    final l10n = AppLocalizations.of(context)!;

    try {
      final config = {
        'enabled': _enabled,
        'smtp_server': _smtpServerController.text.trim(),
        'smtp_port': int.parse(_smtpPortController.text.trim()),
        'use_tls': _useTls,
        'sender_email': _senderEmailController.text.trim(),
        'sender_password': _senderPasswordController.text,
        'sender_name': _senderNameController.text.trim(),
        'recipient_email': _recipientEmailController.text.trim(),
      };

      await wsService.setEmailConfig(config);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email configuration updated')),
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
          title: const Text('Edit Email Configuration'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Master Enable Switch
                  SwitchListTile(
                    title: const Text('Enable Email Notifications'),
                    subtitle: const Text('Send email alerts for alarms'),
                    value: _enabled,
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _enabled = value;
                      });
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // SMTP Settings
                  Text(
                    'SMTP Server Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _smtpServerController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'SMTP Server',
                      hintText: 'smtp.gmail.com',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _smtpPortController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            hintText: '587',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Use TLS'),
                          value: _useTls,
                          onChanged: isLoading ? null : (value) {
                            setState(() {
                              _useTls = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Email Addresses
                  Text(
                    'Email Addresses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _senderEmailController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Sender Email',
                      hintText: 'your-email@gmail.com',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _senderPasswordController,
                    enabled: !isLoading,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Sender Password',
                      hintText: 'App password (not regular password)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _senderNameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Sender Name',
                      hintText: 'Terrarium System',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _recipientEmailController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Recipient Email',
                      hintText: 'your-email@example.com',
                      border: OutlineInputBorder(),
                    ),
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
