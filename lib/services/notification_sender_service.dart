import 'package:cloud_functions/cloud_functions.dart';
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

      final callable = functions.httpsCallable('sendNotificationToDevices');
      await callable.call({
        "app": app,
        "title": title,
        "text": text,
        "senderToken": token,
      });

    } catch (e) {
      
    }
  }
}
