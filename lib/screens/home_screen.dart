import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/websocket_service_base.dart';
import 'config_screen.dart';
import 'connection_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    ConfigScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load saved URL and auto-connect if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConnection();
    });
  }

  Future<void> _initializeConnection() async {
    final wsService = context.read<WebSocketServiceBase>();

    // Load saved URL from storage
    await wsService.loadSavedUrl();

    // Check if we have a saved URL and try to connect
    if (wsService.serverUrl.isNotEmpty) {
      try {
        await wsService.connect();
      } catch (e) {
        // If auto-connect fails, show connection dialog
        if (mounted) {
          _showConnectionDialog();
        }
      }
    } else {
      // No saved URL, show connection dialog
      _showConnectionDialog();
    }
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ConnectionScreen(),
    );
  }

  Future<void> _handleDisconnect() async {
    final wsService = context.read<WebSocketServiceBase>();
    await wsService.disconnect(clearCache: true);
    if (mounted) {
      _showConnectionDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final destinations = [
      NavigationRailDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: Text(l10n.dashboard),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.show_chart_outlined),
        selectedIcon: const Icon(Icons.show_chart),
        label: Text(l10n.history),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.tune_outlined),
        selectedIcon: const Icon(Icons.tune),
        label: Text(l10n.config),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: Text(l10n.settings),
      ),
    ];

    return Consumer<WebSocketServiceBase>(
      builder: (context, wsService, child) {
        return Scaffold(
          body: Row(
            children: [
              // Navigation Rail
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                leading: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Connection status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: wsService.isConnected ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        wsService.isConnected ? l10n.connected : l10n.notConnected,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Disconnect button (only show when connected)
                          if (wsService.isConnected)
                            IconButton(
                              icon: const Icon(Icons.logout),
                              tooltip: l10n.disconnect,
                              onPressed: _handleDisconnect,
                            ),
                          // Connection settings button
                          IconButton(
                            icon: const Icon(Icons.settings_ethernet),
                            tooltip: l10n.connect,
                            onPressed: _showConnectionDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                destinations: destinations,
              ),
              const VerticalDivider(thickness: 1, width: 1),
              // Main content
              Expanded(
                child: _screens[_selectedIndex],
              ),
            ],
          ),
        );
      },
    );
  }
}
