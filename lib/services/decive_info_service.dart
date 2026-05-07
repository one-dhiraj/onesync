import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:onesync/models/device_info_model.dart';

Future<String?> getFcmToken() async {
  return await FirebaseMessaging.instance.getToken();
}

Future<Map<String, String>> getDeviceDetails() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;

    return {
      "deviceId": android.id,
      "deviceName": "${android.brand} ${android.model}",
    };
  }

  return {"deviceId": "unknown", "deviceName": "unknown"};
}

class DeviceService {
  final _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  Future<void> registerDevice() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final device = await getDeviceDetails();
    final token = await getFcmToken();

    if (token == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(device["deviceId"]);

    await docRef.set({
      "name": device["deviceName"],
      "token": token,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resetConnectionFlags() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final device = await getDeviceDetails();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(device["deviceId"])
        .set({"canSend": false, "canReceive": false}, SetOptions(merge: true));
  }

  Future<void> updateSend(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final device = await getDeviceDetails();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(device["deviceId"])
        .update({"canSend": value, "updatedAt": FieldValue.serverTimestamp()});
  }

  Future<void> updateReceive(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final device = await getDeviceDetails();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(device["deviceId"])
        .update({
          "canReceive": value,
          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateToken(String newToken) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final device = await getDeviceDetails();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(device["deviceId"])
        .update({"token": newToken, "updatedAt": FieldValue.serverTimestamp()});
  }

  void setupDeviceSync() {
    if (_initialized) return;
    _initialized = true;

    // Step 1: Ensure device is registered
    registerDevice();

    // Step 2: Reset session flags (important for your design)
    resetConnectionFlags();

    // Step 3: Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      updateToken(newToken);
    });
  }

  Future<void> deactivateCurrentDevice() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final device = await getDeviceDetails();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(device["deviceId"])
        .update({
          "canSend": false,
          "canReceive": false,
          "updatedAt": FieldValue.serverTimestamp(),
        });
  }
}

Stream<List<DeviceModel>> getUserDevices() {
  final user = FirebaseAuth.instance.currentUser;

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('devices')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return DeviceModel.fromDoc(doc);
        }).toList();
      });
}
