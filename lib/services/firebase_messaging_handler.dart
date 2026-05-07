import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesync/services/notification_display_service.dart';

void setupFCMListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final data = message.data;
    NotificationDisplayService.showNotification(
      title: data['title'] ?? "OneSync",
      body: data['body'] ?? "",
    );
  });
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
