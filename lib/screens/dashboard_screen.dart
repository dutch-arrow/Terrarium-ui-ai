import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/terrarium_status.dart';
import '../services/websocket_service_base.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isRefreshing = false;

  // Track optimistic UI updates with timestamps
  final Map<String, (bool, DateTime)> _optimisticStates = {};
  (bool, DateTime)? _optimisticPausedState;

  Future<void> _handleRefresh(WebSocketServiceBase wsService) async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await wsService.getStatus();
      // Wait a bit for the response to come through the WebSocket
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _toggleEntity(String entity, DeviceState currentState, WebSocketServiceBase wsService) {
    // Immediately update UI with timestamp
    setState(() {
      _optimisticStates[entity] = (!currentState.state, DateTime.now());
    });

    // Send command to server
    wsService.toggleEntity(entity);
  }

  void _togglePause(bool currentPausedState, WebSocketServiceBase wsService) {
    // Immediately update UI with timestamp
    setState(() {
      _optimisticPausedState = (!currentPausedState, DateTime.now());
    });

    // Send command to server
    if (currentPausedState) {
      wsService.resumeControlLoop();
    } else {
      wsService.pauseControlLoop();
    }
  }

  bool _getEntityState(String entity, DeviceState serverState) {
    final optimistic = _optimisticStates[entity];
    if (optimistic == null) {
      return serverState.state;
    }

    final (optimisticValue, timestamp) = optimistic;

    // Clear optimistic state if server has caught up or timeout
    if (serverState.state == optimisticValue || DateTime.now().difference(timestamp) > const Duration(seconds: 5)) {
      // Schedule removal for next frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _optimisticStates.remove(entity);
          });
        }
      });
      return serverState.state;
    }

    return optimisticValue;
  }

  bool _getPausedState(bool serverPausedState) {
    final optimistic = _optimisticPausedState;
    if (optimistic == null) {
      return serverPausedState;
    }

    final (optimisticValue, timestamp) = optimistic;

    // Clear optimistic state if server has caught up or timeout
    if (serverPausedState == optimisticValue || DateTime.now().difference(timestamp) > const Duration(seconds: 5)) {
      // Schedule removal for next frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _optimisticPausedState = null;
          });
        }
      });
      return serverPausedState;
    }

    return optimisticValue;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<WebSocketServiceBase>(
      builder: (context, wsService, child) {
        if (!wsService.isConnected) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(l10n.notConnectedToTerrarium),
                const SizedBox(height: 8),
                Text(l10n.clickConnectionIconToConnect),
              ],
            ),
          );
        }

        final status = wsService.currentStatus;
        if (status == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.terrariumDashboard,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Row(
                    children: [
                      Text(
                        l10n.lastUpdate(DateFormat('HH:mm:ss').format(status.timestamp)),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: _isRefreshing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                        tooltip: l10n.refresh,
                        onPressed: _isRefreshing ? null : () => _handleRefresh(wsService),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sensor Cards
              Row(
                children: [
                  Expanded(
                    child: _SensorCard(
                      title: l10n.insideTerrarium,
                      temperature: status.inside.temperature,
                      humidity: status.inside.humidity,
                      icon: Icons.home,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SensorCard(
                      title: l10n.outside,
                      temperature: status.outside.temperature,
                      humidity: status.outside.humidity,
                      icon: Icons.home,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Device Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.deviceStatus,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      Text(
                        l10n.controlLoop,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _togglePause(_getPausedState(status.paused), wsService),
                        style: FilledButton.styleFrom(
                          backgroundColor: _getPausedState(status.paused)
                              ? Colors.red
                              : Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          _getPausedState(status.paused) ? l10n.paused : l10n.running,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DeviceCard(
                      entity: 'light1',
                      name: l10n.mainLight,
                      isOn: _getEntityState('light1', status.devices.light1),
                      reason: status.devices.light1.reason,
                      icon: Icons.lightbulb,
                      onToggle: () => _toggleEntity('light1', status.devices.light1, wsService),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DeviceCard(
                      entity: 'light2',
                      name: l10n.heatLight,
                      isOn: _getEntityState('light2', status.devices.light2),
                      reason: status.devices.light2.reason,
                      icon: Icons.lightbulb,
                      onToggle: () => _toggleEntity('light2', status.devices.light2, wsService),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DeviceCard(
                      entity: 'light3',
                      name: l10n.uvLight,
                      isOn: _getEntityState('light3', status.devices.light3),
                      reason: status.devices.light3.reason,
                      icon: Icons.light_mode,
                      onToggle: () => _toggleEntity('light3', status.devices.light3, wsService),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DeviceCard(
                      entity: 'humidifier',
                      name: l10n.humidifier,
                      isOn: _getEntityState('humidifier', status.devices.humidifier),
                      reason: status.devices.humidifier.reason,
                      icon: Icons.water_drop,
                      onToggle: () => _toggleEntity('humidifier', status.devices.humidifier, wsService),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DeviceCard(
                      entity: 'sprayer',
                      name: l10n.sprayer,
                      isOn: _getEntityState('sprayer', status.devices.sprayer),
                      reason: status.devices.sprayer.reason,
                      icon: Icons.shower,
                      onToggle: () => _toggleEntity('sprayer', status.devices.sprayer, wsService),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DeviceCard(
                      entity: 'fan1',
                      name: l10n.intakeFan,
                      isOn: _getEntityState('fan1', status.devices.fan1),
                      reason: status.devices.fan1.reason,
                      icon: Icons.air,
                      onToggle: () => _toggleEntity('fan1', status.devices.fan1, wsService),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DeviceCard(
                      entity: 'fan2',
                      name: l10n.exhaustFan,
                      isOn: _getEntityState('fan2', status.devices.fan2),
                      reason: status.devices.fan2.reason,
                      icon: Icons.air,
                      onToggle: () => _toggleEntity('fan2', status.devices.fan2, wsService),
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
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
      },
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String title;
  final double temperature;
  final double humidity;
  final IconData icon;

  const _SensorCard({
    required this.title,
    required this.temperature,
    required this.humidity,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.thermostat,
                      size: 48,
                      color: _getTemperatureColor(temperature),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      l10n.temperature,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 48,
                      color: _getHumidityColor(humidity),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${humidity.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      l10n.humidity,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 20) return Colors.blue;
    if (temp < 26) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 40) return Colors.orange;
    if (humidity < 80) return Colors.blue;
    return Colors.purple;
  }
}

class _DeviceCard extends StatelessWidget {
  final String entity;
  final String name;
  final bool isOn;
  final String reason;
  final IconData icon;
  final VoidCallback onToggle;

  const _DeviceCard({
    required this.entity,
    required this.name,
    required this.isOn,
    required this.reason,
    required this.icon,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          isOn ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isOn ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Switch(
              value: isOn,
              onChanged: (_) => onToggle(),
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildReasonBadge(context, reason),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReasonBadge(BuildContext context, String reason) {
    // Determine icon and color based on reason
    IconData icon;
    Color color;
    String label;

    if (reason.contains('manual')) {
      icon = Icons.touch_app;
      color = Colors.blue;
      label = 'Manual';
    } else if (reason.contains('regulation')) {
      icon = Icons.thermostat;
      color = Colors.orange;
      // Extract specific regulation type if present
      if (reason.contains('heating')) {
        label = 'Heating';
      } else if (reason.contains('cooling')) {
        label = 'Cooling';
      } else if (reason.contains('humidity')) {
        label = 'Humidity';
      } else if (reason.contains('interval')) {
        label = 'Interval';
      } else {
        label = 'Regulation';
      }
    } else {
      icon = Icons.schedule;
      color = Colors.green;
      label = 'Schedule';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
