import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/app_settings.dart';
import 'services/mock_websocket_service.dart';
import 'services/websocket_service.dart';
import 'services/websocket_service_base.dart';

/// Main entry point with support for mock mode
///
/// Usage:
///   flutter run                    # Use mock mode (default)
///   flutter run --dart-define=USE_MOCK=false  # Use real WebSocket
void main() {
  // Check for mock mode flag (defaults to true)
  const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

  runApp(const TerrariumApp(useMock: useMock));
}

class TerrariumApp extends StatelessWidget {
  final bool useMock;

  const TerrariumApp({super.key, required this.useMock});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WebSocketServiceBase>(
          create: (_) => useMock ? MockWebSocketService() : WebSocketService(),
        ),
        ChangeNotifierProvider<AppSettings>(
          create: (_) => AppSettings(),
        ),
      ],
      child: Consumer<AppSettings>(
        builder: (context, appSettings, child) {
          return MaterialApp(
            title: 'Terrarium Control',
            debugShowCheckedModeBanner: false,
            locale: appSettings.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('nl'), // Dutch
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            themeMode: appSettings.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
