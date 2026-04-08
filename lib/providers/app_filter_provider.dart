import 'package:flutter/material.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:onesync/models/app_filter_item.dart';

class AppFilterProvider extends ChangeNotifier {
  Map<String, AppFilterItem> appMap = {};
  Map<String, List<String>> groupedPackageNames = {};

  SharedPreferences? _prefs;
  Set<String> enabledPackages = {};

  bool _loading = false;
  bool get loading => _loading;

  List<AppFilterItem> get previewApps {
    final allApps = appMap.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return allApps.take(5).toList();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs!.getStringList("enabled_apps") ?? [];

    enabledPackages = saved.toSet();

    final installed = await FlutterDeviceApps.listApps(
      includeSystem: false,
      onlyLaunchable: true,
      includeIcons: true,
    );

    List<AppFilterItem> apps = [];

    appMap.clear();

    for (final app in installed) {
      var appFilterItem = AppFilterItem(
        name: app.appName!,
        packageName: app.packageName!,
        enabled: false, // default enabled
        icon: app.iconBytes,
      );
      apps.add(appFilterItem);
    }

    prepareGroupedApps(apps);
  }

  Future<void> prepareGroupedApps(List<AppFilterItem> apps) async {
    _loading = true;
    notifyListeners();

    appMap.clear();
    groupedPackageNames.clear();

    for (var app in apps) {
      final isEnabled = enabledPackages.contains(app.packageName);

      final updated = app.copyWith(enabled: isEnabled);

      appMap[app.packageName] = updated;

      final letter = updated.name.isNotEmpty
          ? updated.name[0].toUpperCase()
          : "#";

      groupedPackageNames
          .putIfAbsent(letter, () => [])
          .add(updated.packageName);
    }

    final sortedKeys = groupedPackageNames.keys.toList()..sort();

    groupedPackageNames = {
      for (var key in sortedKeys)
        key: groupedPackageNames[key]!
          ..sort((a, b) => appMap[a]!.name.compareTo(appMap[b]!.name)),
    };

    _loading = false;
    notifyListeners();
  }

  Future<void> toggle(String packageName, bool value) async {
    final app = appMap[packageName];
    if (app == null) return;

    appMap[packageName] = app.copyWith(enabled: value);

    if (value) {
      enabledPackages.add(packageName);
    } else {
      enabledPackages.remove(packageName);
    }

    await _prefs!.setStringList("enabled_apps", enabledPackages.toList());

    notifyListeners();
  }

}