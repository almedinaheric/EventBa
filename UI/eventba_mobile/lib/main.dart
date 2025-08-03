import 'package:eventba_mobile/providers/event_image_provider.dart';
import 'package:eventba_mobile/providers/notification_provider.dart';
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/providers/category_provider.dart';
import 'package:eventba_mobile/screens/event_questions_screen.dart';
import 'package:eventba_mobile/screens/home_screen.dart';
import 'package:eventba_mobile/screens/splash_screen.dart';
import 'package:eventba_mobile/screens/ticket_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => EventImageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EventBa',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B7CF6)),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Poppins'),
      home: const SplashScreen(),
    );
  }
}
