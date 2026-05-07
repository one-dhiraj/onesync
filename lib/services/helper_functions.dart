import 'package:flutter/material.dart';
import 'package:onesync/services/battery_optimization_service.dart';

void showSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

final batteryService = BatteryOptimizationService();

Future<bool> isIgnoringBatteryOptimization() async {
  return await batteryService.isIgnoringBatteryOptimizations();
}
void requestBatteryOptimization(BuildContext context) async {
  await batteryService.requestDisableBatteryOptimization();
}
