import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/database_helper.dart';
import 'providers/school_provider.dart';
import 'services/notification_service.dart';
import 'services/image_service.dart';
import 'services/whatsapp_service.dart';
import 'views/app_shell.dart';

Future<void> main() async {
  // Catch build/rendering errors and show them instead of a blank white
  // screen, so failures are always visible during development.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Text(
              'Something went wrong while building the UI:\n\n'
              '${details.exceptionAsString()}',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  };

  // runZonedGuarded catches ANY uncaught error - including ones thrown
  // during the async setup below, before runApp() is ever reached - and
  // shows a visible error screen instead of leaving a blank white screen.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('FlutterError: ${details.exceptionAsString()}');
      }
    };

    DatabaseHelper? database;
    Object? startupError;
    StackTrace? startupStack;

    try {
      database = DatabaseHelper();
      // Only the database is essential; if it fails the app truly can't
      // work, so we surface that clearly.
      await database.database;
    } catch (e, st) {
      startupError = e;
      startupStack = st;
    }

    // Notifications are a "nice to have" - never let a failure here
    // (missing platform setup, permission issues, etc.) block the app
    // from launching.
    try {
      await NotificationService.instance.initialize();
    } catch (e, st) {
      debugPrint('NotificationService init failed (continuing): $e\n$st');
    }

    if (startupError != null || database == null) {
      runApp(
        StartupErrorApp(error: startupError, stackTrace: startupStack),
      );
      return;
    }

    final provider = SchoolProvider(
      database: database,
      imageService: ImageService(),
      whatsappService: WhatsAppService(),
    );

    try {
      await provider.initialize();
    } catch (e, st) {
      runApp(StartupErrorApp(error: e, stackTrace: st));
      return;
    }

    runApp(
      ChangeNotifierProvider<SchoolProvider>.value(
        value: provider,
        child: const SchoolManagerApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
  });
}

/// Shown instead of a blank white screen if startup fails, so the
/// underlying error is always visible and debuggable.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, this.error, this.stackTrace});

  final Object? error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'App failed to start',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('$error', style: const TextStyle(color: Colors.red)),
                  if (stackTrace != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '$stackTrace',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SchoolManagerApp extends StatelessWidget {
  const SchoolManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3157D5);
    return MaterialApp(
      title: 'School Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFFE5E9F2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}
