import 'dart:async';

import 'package:flutter/material.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:onesync/providers/app_filter_provider.dart';

import 'package:onesync/services/decive_info_service.dart';
import 'package:onesync/services/notification_display_service.dart';
import 'package:onesync/services/notification_listener_service.dart';
import 'package:onesync/services/notification_sender_service.dart';
import 'package:onesync/services/helper_functions.dart';

import 'package:onesync/widgets/section_header.dart';
import 'package:onesync/widgets/dashboard_tile.dart';
import 'package:onesync/widgets/app_filter_section.dart';

import 'package:onesync/models/app_filter_item.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DeviceService().setupDeviceSync();
    checkBatteryOptimization();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (!_sendEnabled && _openedNotificationSettings) {
        checkNotificationPermission();
        _openedNotificationSettings = false;
      }

      if (_openedBatterySettings) {
        checkBatteryOptimization();
        _openedBatterySettings = false;
      }
    }
  }

  Future<void> checkNotificationPermission() async {
    await Future.delayed(const Duration(milliseconds: 500));

    bool granted = await notificationService.isPermissionGranted();

    if (!mounted) return;

    if (granted) {
      startNotificationListener();
      setState(() {
        _sendEnabled = true;
      });
      _deviceService.updateSend(true);
    } else {
      showSnackBar(
        "Notification access not granted. Sync will remain disabled.",
        context,
      );
    }
  }

  // state
  bool _sendEnabled = false;
  bool _receiveEnabled = false;
  bool _openedNotificationSettings = false;
  bool _openedBatterySettings = false;
  bool _ignoringBatteryOptimization = false;
  List<AppFilterItem> appFilters = [];

  final _deviceService = DeviceService();
  final notificationService = NotificationService();
  StreamSubscription? _notificationSubscription;

  void checkBatteryOptimization() async {
    bool ignoring = await batteryService.isIgnoringBatteryOptimizations();

    setState(() {
      _ignoringBatteryOptimization = ignoring;
    });
  }

  void toggleNotificationSync() async {
    if (_sendEnabled) {
      await disableNotificationSync();
    } else {
      await enableNotificationSync();
    }
  }

  void toggleReceive() async {
    if (_sendEnabled) {
      showSnackBar("Disable 'Send Notifications' first", context);
      return;
    }

    if (!_receiveEnabled) {
      bool permission = await checkNotificationDisplayPermission();
      
      if (!mounted) return;
      if (!permission) {
        showSnackBar("Please enable notifications to receive updates", context);
        return;
      }
    }

    _deviceService.updateReceive(!_receiveEnabled);
    setState(() {
      _receiveEnabled = !_receiveEnabled;
    });
  }

  Future<void> disableNotificationSync() async {
    _notificationSubscription?.cancel();
    notificationService.stopListening();

    await _deviceService.resetReceiveForAllDevices();
    setState(() {
      _sendEnabled = false;
    });
    _deviceService.updateSend(false);
  }

  Future<void> enableNotificationSync() async {
    if (_receiveEnabled) {
      showSnackBar("Disable 'Receive Notifications' first", context);
      return;
    }

    bool granted = await notificationService.isPermissionGranted();

    if (!mounted) return;
    if (!granted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Notification Access Required"),
          content: const Text(
            "To sync notifications across devices, OneSync needs notification access.\n\n"
            "You will be taken to the system settings. Please enable OneSync and come back.",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Open Settings"),
              onPressed: () async {
                _openedNotificationSettings = true;
                Navigator.pop(context);

                // Open Android notification access settings safely
                final intent = AndroidIntent(
                  action:
                      'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS',
                  flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
                );
                await intent.launch();
              },
            ),
          ],
        ),
      );

      return;
    }

    // If already granted, start listener immediately
    startNotificationListener();
    setState(() {
      _sendEnabled = true;
    });
    _deviceService.updateSend(true);
  }

  void startNotificationListener() {
    _notificationSubscription?.cancel();
    notificationService.startListening();

    _notificationSubscription = notificationService.notificationsStream.listen((
      data,
    ) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (!mounted) return;

      final appFilterProvider = context.read<AppFilterProvider>();
      if (!appFilterProvider.enabledPackages.contains(data["packageName"]) ||
          data["packageName"] == "com.analog.onesync")
        return;

      if (data["packageName"] == "com.analog.onesync") return;

      final app = appFilterProvider.appMap[data["packageName"]];
      final appName = app?.name ?? data["packageName"];
      
      final sender = NotificationSender();
      await sender.sendNotification(
        app: appName,
        title: data["title"] ?? "",
        text: data["text"] ?? "",
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void openFullSheet() async {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => const AppFilterFullSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text("One Sync"),
            const SizedBox(height: 2),
            Text("${user?.email}", style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await DeviceService().deactivateCurrentDevice();
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: DashboardTile(
                  icon: _sendEnabled
                      ? Icons.hearing_rounded
                      : Icons.hearing_disabled_rounded,
                  title: _sendEnabled ? "Sync Active" : "Sync Disabled",
                  subtitle: _sendEnabled
                      ? "Sending device notifications"
                      : "Tap to send notifications",
                  color: _sendEnabled ? Colors.lightGreen : Colors.blueGrey,
                  onTap: toggleNotificationSync,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardTile(
                  icon: _receiveEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  title: _receiveEnabled ? "Receiving" : "Receive",
                  subtitle: _receiveEnabled
                      ? "Receiving notifications"
                      : "Tap to receive notifications",
                  color: _receiveEnabled ? Colors.purple : Colors.blueGrey,
                  onTap: toggleReceive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const SectionHeader("FILTER APPS"),
          AppFilterPreviewSection(onViewAll: openFullSheet),

          const SizedBox(height: 20),
          const SectionHeader("OPTIMIZATION"),
          DashboardTile(
            icon: _ignoringBatteryOptimization
                ? Icons.battery_full_outlined
                : Icons.battery_alert_outlined,
            title: "Battery Restrictions",
            subtitle: _ignoringBatteryOptimization
                ? "Restrictions are already disabled"
                : "Disable restrictions for reliable syncing",
            color: _ignoringBatteryOptimization ? Colors.green : Colors.purple,
            onTap: () async {
              if (_ignoringBatteryOptimization) {
                showSnackBar(
                  "Battery Restrictions are already disabled",
                  context,
                );
              } else {
                _openedBatterySettings = true;
                await batteryService.requestDisableBatteryOptimization();
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
