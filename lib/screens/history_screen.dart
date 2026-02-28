import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/event.dart';
import '../models/sensor_reading.dart';
import '../services/websocket_service_base.dart';

// State machine for History screen
enum HistoryState {
  initial, // Screen created, no data requested yet
  loading, // Fetching data from server
  processing, // Building timeline in isolate
  ready, // Timeline ready to display
  empty, // No events available
  error, // Error occurred
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryState _state = HistoryState.initial;
  int _timeStepMinutes = 10; // Default 10 minutes
  TimelineData? _cachedTimelineData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load events when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transitionToLoading();
    });
  }

  // Event-driven state transitions: each method transitions state and triggers next action
  void _transitionToLoading() {
    setState(() {
      _state = HistoryState.loading;
      _cachedTimelineData = null;
      _errorMessage = null;
    });
    debugPrint('State: loading');

    // After frame renders, trigger data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final wsService = context.read<WebSocketServiceBase>();
    if (!wsService.isConnected) return;

    try {
      // Load both events and sensor history
      await Future.wait([
        wsService.getEvents(limit: 200),
        wsService.getHistory(limit: 200),
      ]);

      // Wait for WebSocket messages to arrive and update the data
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        debugPrint('Widget not mounted after data fetch');
        return;
      }

      final events = wsService.currentEvents ?? [];
      final history = wsService.currentHistory ?? [];
      debugPrint('Data fetched (events: ${events.length}, history: ${history.length})');

      // Check if we have events
      if (events.isEmpty) {
        setState(() {
          _state = HistoryState.empty;
        });
        debugPrint('State: empty');
        return;
      }

      // Transition to processing state
      _transitionToProcessing();
    } catch (e, stackTrace) {
      debugPrint('ERROR in _fetchData: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _state = HistoryState.error;
          _errorMessage = e.toString();
        });
        debugPrint('State: error');
      }
    }
  }

  void _transitionToProcessing() {
    setState(() {
      _state = HistoryState.processing;
    });
    debugPrint('State: processing');

    // After frame renders, trigger timeline building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildTimelineAsync();
    });
  }

  void _loadEvents() {
    _transitionToLoading();
  }

  Future<void> _buildTimelineAsync() async {
    try {
      // Get data from service
      final wsService = context.read<WebSocketServiceBase>();
      final events = wsService.currentEvents ?? [];
      final history = wsService.currentHistory ?? [];

      if (events.isEmpty) {
        // State transition: processing -> empty
        if (mounted) {
          setState(() {
            _state = HistoryState.empty;
          });
          debugPrint('State: empty');
        }
        return;
      }

      // Build timeline in background isolate using compute()
      debugPrint('Building timeline with ${events.length} events and ${history.length} readings');
      final params = _TimelineParams(events, history, _timeStepMinutes);
      final timelineData = await compute(_buildTimelineInIsolate, params);
      debugPrint('Timeline built: ${timelineData.timeSlots.length} slots, ${timelineData.devices.length} devices');

      // State transition: processing -> ready
      if (mounted) {
        setState(() {
          _cachedTimelineData = timelineData;
          _state = HistoryState.ready;
        });
        debugPrint('State: ready');
      } else {
        debugPrint('Widget not mounted, timeline not cached');
      }
    } catch (e, stackTrace) {
      debugPrint('Error building timeline: $e');
      debugPrint('Stack trace: $stackTrace');
      // State transition: processing -> error
      if (mounted) {
        setState(() {
          _state = HistoryState.error;
          _errorMessage = 'Failed to build timeline: $e';
        });
        debugPrint('State: error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<WebSocketServiceBase>(
      builder: (context, wsService, child) {
        // Check connection first
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

        // State machine: render UI based on current state
        switch (_state) {
          case HistoryState.initial:
          case HistoryState.loading:
          case HistoryState.processing:
            // Show loading spinner
            return const Center(child: CircularProgressIndicator());

          case HistoryState.empty:
            // No events available
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noEventsYet,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.deviceStateChangesWillAppearHere,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );

          case HistoryState.error:
            // Error occurred
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading history',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage ?? 'Unknown error',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadEvents,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );

          case HistoryState.ready:
            // Timeline is ready to display
            if (_cachedTimelineData == null) {
              // This shouldn't happen, but handle it gracefully
              debugPrint('WARNING: State is ready but timeline data is null');
              return const Center(child: CircularProgressIndicator());
            }

            final timelineData = _cachedTimelineData!;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.deviceSwitchingHistory,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      IconButton(
                        icon: (_state == HistoryState.loading || _state == HistoryState.processing)
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                        tooltip: l10n.refresh,
                        onPressed:
                            (_state == HistoryState.loading || _state == HistoryState.processing) ? null : _loadEvents,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Time step selector
                  Row(
                    children: [
                      Text(
                        l10n.timeInterval,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: 12),
                      SegmentedButton<int>(
                        segments: [
                          ButtonSegment(value: 5, label: Text(l10n.fiveMinutes)),
                          ButtonSegment(value: 10, label: Text(l10n.tenMinutes)),
                          ButtonSegment(value: 15, label: Text(l10n.fifteenMinutes)),
                          ButtonSegment(value: 30, label: Text(l10n.thirtyMinutes)),
                          ButtonSegment(value: 60, label: Text(l10n.oneHour)),
                        ],
                        selected: {_timeStepMinutes},
                        onSelectionChanged: (Set<int> selected) {
                          setState(() {
                            _timeStepMinutes = selected.first;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Legend
                  const Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _LegendItem(
                        icon: Icons.schedule,
                        label: 'Schedule',
                        color: Colors.green,
                      ),
                      _LegendItem(
                        icon: Icons.thermostat,
                        label: 'Regulation',
                        color: Colors.orange,
                      ),
                      _LegendItem(
                        icon: Icons.touch_app,
                        label: 'Manual',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Switching diagram with horizontal scrolling
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          height: constraints.maxHeight,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: _SwitchingDiagram(
                              timelineData: timelineData,
                              timeStepMinutes: _timeStepMinutes,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}

// Helper class to pass parameters to isolate
class _TimelineParams {
  final List<TerrariumEvent> events;
  final List<SensorReading> history;
  final int timeStepMinutes;

  _TimelineParams(this.events, this.history, this.timeStepMinutes);
}

// Top-level function that can run in an isolate
TimelineData _buildTimelineInIsolate(_TimelineParams params) {
  return _buildTimelineDataStatic(params.events, params.history, params.timeStepMinutes);
}

// Static version of _buildTimelineData that can be called from isolate
TimelineData _buildTimelineDataStatic(List<TerrariumEvent> events, List<SensorReading> history, int timeStepMinutes) {
  // Parse all events
  final parsedEvents = <DeviceEvent>[];
  for (final event in events) {
    final parsed = _parseEventMessageStatic(event);
    if (parsed != null) {
      parsedEvents.add(parsed);
    }
  }

  if (parsedEvents.isEmpty) {
    return TimelineData(timeSlots: [], devices: []);
  }

  // Sort by timestamp (oldest first)
  parsedEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  // Get unique devices and order them according to preferred order
  final deviceSet = parsedEvents.map((e) => e.device).toSet();

  // Define preferred device order
  const preferredOrder = [
    'light1',
    'light2',
    'light3',
    'fan1',
    'fan2',
    'humidifier',
    'sprayer',
  ];

  // Use preferred order for devices that exist, then add any others
  final devices = preferredOrder.where((d) => deviceSet.contains(d)).toList();
  final remainingDevices = deviceSet.where((d) => !preferredOrder.contains(d)).toList();
  remainingDevices.sort(); // Sort any unknown devices alphabetically
  devices.addAll(remainingDevices);

  // Find time range
  final oldestTime = parsedEvents.first.timestamp;
  final newestTime = parsedEvents.last.timestamp;

  // Round to time step boundaries
  final startTime = DateTime(
    oldestTime.year,
    oldestTime.month,
    oldestTime.day,
    oldestTime.hour,
    (oldestTime.minute ~/ timeStepMinutes) * timeStepMinutes,
  );
  final endTime = DateTime(
    newestTime.year,
    newestTime.month,
    newestTime.day,
    newestTime.hour,
    (newestTime.minute ~/ timeStepMinutes) * timeStepMinutes,
  ).add(Duration(minutes: timeStepMinutes));

  // Generate time slots
  final timeSlots = <DateTime>[];
  var currentTime = startTime;
  while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
    timeSlots.add(currentTime);
    currentTime = currentTime.add(Duration(minutes: timeStepMinutes));
  }

  // Build state matrix: for each time slot, determine each device's state and reason
  // Optimized: iterate through events once instead of for each time slot
  final stateMatrix = <DateTime, Map<String, bool?>>{};
  final reasonMatrix = <DateTime, Map<String, String>>{};
  final deviceStates = <String, bool?>{}; // Track current state for each device
  final deviceReasons = <String, String>{}; // Track current reason for each device

  int eventIndex = 0;
  for (final timeSlot in timeSlots) {
    // Apply all events up to and including this time slot
    while (eventIndex < parsedEvents.length &&
        (parsedEvents[eventIndex].timestamp.isBefore(timeSlot) ||
            parsedEvents[eventIndex].timestamp.isAtSameMomentAs(timeSlot))) {
      final event = parsedEvents[eventIndex];
      deviceStates[event.device] = event.state;
      deviceReasons[event.device] = event.reason;
      eventIndex++;
    }

    // Store states and reasons for this time slot
    stateMatrix[timeSlot] = Map.from(deviceStates);
    reasonMatrix[timeSlot] = Map.from(deviceReasons);
  }

  // Build sensor matrix: for each time slot, find closest sensor reading
  // Optimized: sort readings once and iterate efficiently
  final sensorMatrix = <DateTime, SensorReading?>{};
  final sortedReadings = List<SensorReading>.from(history)..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  int readingIndex = 0;
  for (final timeSlot in timeSlots) {
    // Move index forward to find readings around this time slot
    while (readingIndex < sortedReadings.length - 1 && sortedReadings[readingIndex + 1].timestamp.isBefore(timeSlot)) {
      readingIndex++;
    }

    // Check current and next reading to find closest
    SensorReading? closestReading;
    Duration? closestDiff;

    if (readingIndex < sortedReadings.length) {
      final reading = sortedReadings[readingIndex];
      final diff = timeSlot.difference(reading.timestamp).abs();
      if (diff.inMinutes <= timeStepMinutes) {
        closestReading = reading;
        closestDiff = diff;
      }
    }

    // Also check next reading if exists
    if (readingIndex + 1 < sortedReadings.length) {
      final nextReading = sortedReadings[readingIndex + 1];
      final nextDiff = timeSlot.difference(nextReading.timestamp).abs();
      if (nextDiff.inMinutes <= timeStepMinutes && (closestDiff == null || nextDiff < closestDiff)) {
        closestReading = nextReading;
      }
    }

    if (closestReading != null) {
      sensorMatrix[timeSlot] = closestReading;
    }
  }

  // Pre-compute date divider indices
  final reversedTimeSlots = timeSlots.reversed.toList();
  final dateDividerIndices = <int>{};
  DateTime? prevDate;
  for (var i = 0; i < reversedTimeSlots.length; i++) {
    final timeSlot = reversedTimeSlots[i];
    final currentDate = DateTime(timeSlot.year, timeSlot.month, timeSlot.day);
    if (prevDate != null && currentDate != prevDate) {
      dateDividerIndices.add(i);
    }
    prevDate = currentDate;
  }

  return TimelineData(
    timeSlots: reversedTimeSlots, // Most recent first
    devices: devices,
    stateMatrix: stateMatrix,
    reasonMatrix: reasonMatrix,
    sensorMatrix: sensorMatrix,
    dateDividerIndices: dateDividerIndices,
  );
}

// Static helper to parse event messages
DeviceEvent? _parseEventMessageStatic(TerrariumEvent event) {
  // Use parsed fields from backend if available
  if (event.type == 'device_state_change' && event.device != null && event.state != null) {
    return DeviceEvent(
      timestamp: event.timestamp,
      device: event.device!,
      state: event.state!,
      reason: event.reason ?? '',
    );
  }

  // Fallback: parse message string for backward compatibility
  // Expected format: "light1: ON (scheduled)" or "humidifier: OFF (manual control)"
  final match = RegExp(r'^(\w+):\s+(ON|OFF)\s*(?:\((.+)\))?$').firstMatch(event.message);
  if (match == null) return null;

  return DeviceEvent(
    timestamp: event.timestamp,
    device: match.group(1)!,
    state: match.group(2)! == 'ON',
    reason: match.group(3) ?? '',
  );
}

class TimelineData {
  final List<DateTime> timeSlots;
  final List<String> devices;
  final Map<DateTime, Map<String, bool?>> stateMatrix;
  final Map<DateTime, Map<String, String>> reasonMatrix;
  final Map<DateTime, SensorReading?> sensorMatrix;
  final Set<int> dateDividerIndices;

  TimelineData({
    required this.timeSlots,
    required this.devices,
    this.stateMatrix = const {},
    this.reasonMatrix = const {},
    this.sensorMatrix = const {},
    this.dateDividerIndices = const {},
  });
}

class DeviceEvent {
  final DateTime timestamp;
  final String device;
  final bool state;
  final String reason;

  DeviceEvent({
    required this.timestamp,
    required this.device,
    required this.state,
    required this.reason,
  });
}

class _SwitchingDiagram extends StatelessWidget {
  final TimelineData timelineData;
  final int timeStepMinutes;

  const _SwitchingDiagram({
    required this.timelineData,
    required this.timeStepMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (timelineData.timeSlots.isEmpty) {
      return Center(child: Text(l10n.noDataAvailable));
    }

    // Single column width for all columns
    const columnWidth = 60.0;
    const columnMargin = 8.0;

    // Map device keys to display info
    final deviceInfo = {
      'light1': (l10n.mainLight, Icons.lightbulb),
      'light2': (l10n.heatLight, Icons.lightbulb),
      'light3': (l10n.uvLight, Icons.light_mode),
      'humidifier': (l10n.humidifier, Icons.water_drop),
      'sprayer': (l10n.sprayer, Icons.shower),
      'fan1': (l10n.intakeFan, Icons.air),
      'fan2': (l10n.exhaustFan, Icons.air),
    };

    // Build all rows upfront (lazy loading during initial build only)
    final allRows = <Widget>[];

    for (var index = 0; index < timelineData.timeSlots.length; index++) {
      final timeSlot = timelineData.timeSlots[index];
      final currentDate = DateTime(timeSlot.year, timeSlot.month, timeSlot.day);

      // Add date divider if needed
      if (timelineData.dateDividerIndices.contains(index)) {
        allRows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8, left: 16, right: 16),
            child: Row(
              children: [
                const SizedBox(width: columnWidth),
                Container(
                  width: columnWidth,
                  height: 2,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    DateFormat('MMM dd').format(currentDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  width: columnWidth,
                  height: 2,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        );
      }

      // Add timeline row
      allRows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: _TimelineRow(
            timeSlot: timeSlot,
            devices: timelineData.devices,
            deviceStates: timelineData.stateMatrix[timeSlot] ?? {},
            deviceReasons: timelineData.reasonMatrix[timeSlot] ?? {},
            sensorReading: timelineData.sensorMatrix[timeSlot],
            columnWidth: columnWidth,
            columnMargin: columnMargin,
          ),
        ),
      );
    }

    // Calculate total width: time + spacing + sensors + spacing + devices
    final totalColumns = 1 + 4 + timelineData.devices.length; // time + 4 sensors + N devices
    final totalWidth = totalColumns * (columnWidth + columnMargin) + 64; // all columns + 2 spacing gaps (16px each) + padding (32px)

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: ListView(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // Time column header
                      Container(
                        width: columnWidth,
                        margin: const EdgeInsets.only(right: columnMargin),
                        child: Text(
                          l10n.time,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Sensor columns
                      _buildSensorHeader(context, l10n.insideTemp, Icons.thermostat, columnWidth, columnMargin),
                      _buildSensorHeader(context, l10n.insideHumidity, Icons.water_drop, columnWidth, columnMargin),
                      _buildSensorHeader(context, l10n.outsideTemp, Icons.thermostat_outlined, columnWidth, columnMargin),
                      _buildSensorHeader(
                          context, l10n.outsideHumidity, Icons.water_drop_outlined, columnWidth, columnMargin),

                      const SizedBox(width: 16),

                      // Device columns
                      ...timelineData.devices.map((device) {
                        final info = deviceInfo[device] ?? (device, Icons.device_unknown);
                        return Container(
                          width: columnWidth,
                          margin: const EdgeInsets.only(right: columnMargin),
                          child: Column(
                            children: [
                              Icon(
                                info.$2,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                info.$1,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Theme.of(context).colorScheme.outline),
                ),

              // All timeline rows rendered upfront
              ...allRows,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorHeader(
      BuildContext context, String label, IconData icon, double columnWidth, double columnMargin) {
    return Container(
      width: columnWidth,
      margin: EdgeInsets.only(right: columnMargin),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final DateTime timeSlot;
  final List<String> devices;
  final Map<String, bool?> deviceStates;
  final Map<String, String> deviceReasons;
  final SensorReading? sensorReading;
  final double columnWidth;
  final double columnMargin;

  const _TimelineRow({
    required this.timeSlot,
    required this.devices,
    required this.deviceStates,
    required this.deviceReasons,
    this.sensorReading,
    required this.columnWidth,
    required this.columnMargin,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time label
          Container(
            width: columnWidth,
            margin: EdgeInsets.only(right: columnMargin),
            child: Text(
              timeFormat.format(timeSlot),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: 16),

          // Sensor values
          _buildSensorValue(
            context,
            sensorReading != null ? '${sensorReading!.insideTemp.toStringAsFixed(1)}°' : '—',
            columnWidth,
            columnMargin,
          ),
          _buildSensorValue(
            context,
            sensorReading != null ? '${sensorReading!.insideHumidity.toStringAsFixed(0)}%' : '—',
            columnWidth,
            columnMargin,
          ),
          _buildSensorValue(
            context,
            sensorReading != null ? '${sensorReading!.outsideTemp.toStringAsFixed(1)}°' : '—',
            columnWidth,
            columnMargin,
          ),
          _buildSensorValue(
            context,
            sensorReading != null ? '${sensorReading!.outsideHumidity.toStringAsFixed(0)}%' : '—',
            columnWidth,
            columnMargin,
          ),

          const SizedBox(width: 16),

          // Device state indicators
          ...devices.map((device) {
            final state = deviceStates[device];
            final reason = deviceReasons[device] ?? '';

            // Determine color based on reason
            Color? backgroundColor;
            Color? borderColor;
            Color? textColor;
            IconData? reasonIcon;

            if (state != null) {
              if (reason.contains('manual')) {
                // Manual control - blue
                backgroundColor = state ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1);
                borderColor = Colors.blue;
                textColor = Colors.blue.shade700;
                reasonIcon = Icons.touch_app;
              } else if (reason.contains('regulation')) {
                // Regulation control - orange
                backgroundColor = state ? Colors.orange.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.1);
                borderColor = Colors.orange;
                textColor = Colors.orange.shade700;
                reasonIcon = Icons.thermostat;
              } else {
                // Schedule control - green (default)
                backgroundColor = state ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1);
                borderColor = state ? Colors.green : Colors.grey;
                textColor = state ? Colors.green.shade700 : Colors.grey.shade700;
                reasonIcon = Icons.schedule;
              }
            } else {
              backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
              borderColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
              textColor = Theme.of(context).colorScheme.onSurfaceVariant;
            }

            return Tooltip(
              message: state == null ? 'No data' : '${state ? "ON" : "OFF"}${reason.isNotEmpty ? " ($reason)" : ""}',
              child: Container(
                width: columnWidth,
                height: 20,
                margin: EdgeInsets.only(right: columnMargin),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (reasonIcon != null && state != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          reasonIcon,
                          size: 10,
                          color: textColor,
                        ),
                      ),
                    Text(
                      state == null
                          ? '—'
                          : state
                              ? AppLocalizations.of(context)!.on
                              : AppLocalizations.of(context)!.off,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSensorValue(BuildContext context, String value, double columnWidth, double columnMargin) {
    return Container(
      width: columnWidth,
      height: 20,
      margin: EdgeInsets.only(right: columnMargin),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LegendItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
