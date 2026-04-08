import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesync/services/firebase_messaging_handler.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';

import 'package:provider/provider.dart';
import 'providers/app_filter_provider.dart';

import 'package:onesync/services/notification_display_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final provider = AppFilterProvider();
  await provider.init();

  await NotificationDisplayService.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  setupFCMListeners();
  
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const OneSyncApp(),
    ),
  );
}

class OneSyncApp extends StatelessWidget {
  const OneSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: "OneSync", home: AuthGate());
  }
}