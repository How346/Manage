import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/database_helper.dart';
import 'providers/school_provider.dart';
import 'services/notification_service.dart';
import 'services/image_service.dart';
import 'services/whatsapp_service.dart';
import 'views/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = DatabaseHelper();
  await database.database;
  await NotificationService.instance.initialize();

  final provider = SchoolProvider(
    database: database,
    imageService: ImageService(),
    whatsappService: WhatsAppService(),
  );
  await provider.initialize();

  runApp(
    ChangeNotifierProvider<SchoolProvider>.value(
      value: provider,
      child: const SchoolManagerApp(),
    ),
  );
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
