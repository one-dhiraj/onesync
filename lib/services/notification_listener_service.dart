import 'dart:async';
import 'package:notification_listener_service/notification_listener_service.dart';

class NotificationService {
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationsStream => _controller.stream;
  Set<String> _lastNotificationSet = {};
  bool _isListening = false;
  StreamSubscription? _pluginSubscription;

  Future<bool> requestPermission() async {
    return await NotificationListenerService.requestPermission();
  }

  Future<bool> isPermissionGranted() async {
    return await NotificationListenerService.isPermissionGranted();
  }

  void startListening() {
    if (_isListening) return;
    _isListening = true;

    _pluginSubscription = NotificationListenerService.notificationsStream
        .listen((event) {
          final title = event.title ?? "";
          final content = event.content ?? "";
          final package = event.packageName ?? "";

          if (title.isEmpty && content.isEmpty) return;

          final key = "$package-$title-$content";

          if (_lastNotificationSet.contains(key)) return;
          _lastNotificationSet.add(key);

          final data = {
            "packageName": package,
            "title": title,
            "text": content,
          };

          _controller.add(data);
        });
  }

  void stopListening() {
    _pluginSubscription?.cancel();
    _pluginSubscription = null;
    _isListening = false;
  }

  void dispose() {
    _controller.close();
  }
}
