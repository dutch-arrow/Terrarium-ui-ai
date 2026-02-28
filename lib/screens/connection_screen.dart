import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service_base.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  late TextEditingController _urlController;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    final wsService = context.read<WebSocketServiceBase>();
    _urlController = TextEditingController(text: wsService.serverUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
    });

    final wsService = context.read<WebSocketServiceBase>();

    try {
      await wsService.connect(url: _urlController.text);

      if (mounted && wsService.isConnected) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect to Terrarium'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the WebSocket URL of your Raspberry Pi:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'WebSocket URL',
                hintText: 'ws://192.168.50.200:8765',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              enabled: !_isConnecting,
            ),
            const SizedBox(height: 16),
            Text(
              'Default port is 8765. Make sure your Pi is running and accessible on your network.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isConnecting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isConnecting ? null : _connect,
          child: _isConnecting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Connect'),
        ),
      ],
    );
  }
}
