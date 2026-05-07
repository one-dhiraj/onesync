import 'package:flutter/services.dart';

class BatteryOptimizationService {
  static const MethodChannel _channel =
      MethodChannel('onesync/battery_optimization');

  Future<bool> isIgnoringBatteryOptimizations() async {
    final bool result =
        await _channel.invokeMethod('isIgnoringBatteryOptimizations');
    return result;
  }

  Future<void> requestDisableBatteryOptimization() async {
    await _channel.invokeMethod('requestDisableBatteryOptimization');
  }
}