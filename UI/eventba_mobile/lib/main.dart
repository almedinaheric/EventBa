import 'package:eventba_mobile/providers/event_image_provider.dart';
import 'package:eventba_mobile/providers/event_review_provider.dart';
import 'package:eventba_mobile/providers/notification_provider.dart';
import 'package:eventba_mobile/providers/ticket_provider.dart';
import 'package:eventba_mobile/providers/ticket_purchase_provider.dart';
import 'package:eventba_mobile/providers/payment_provider.dart';
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/providers/category_provider.dart';
import 'package:eventba_mobile/providers/user_question_provider.dart';
import 'package:eventba_mobile/screens/splash_screen.dart';
import 'package:eventba_mobile/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with publishable key from config
  Stripe.publishableKey = AppConfig.stripePublishableKey;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => EventImageProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => TicketPurchaseProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => EventReviewProvider()),
        ChangeNotifierProvider(create: (_) => UserQuestionProvider()),
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
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
