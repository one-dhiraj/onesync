import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationSender {
  final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<void> sendNotification({
    required String app,
    required String title,
    required String text,
  }) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();

      print("ONESYNC: ${Firebase.app().options.projectId}");
      print("ONESYNC: ${Firebase.app().options.apiKey}");

      print("ONESYNC: CALLING FUNCTION FOR $text");
      final callable = functions.httpsCallable('sendNotificationToDevices');
      print("ONESYNC: $callable");
      final result = await callable.call({
        "app": app,
        "title": title,
        "text": text,
        "senderToken": token,
      });

      print("ONESYNC: $result");
    } catch (e) {
      print("ONESYNC: Error occured $e");
    }
  }
}
