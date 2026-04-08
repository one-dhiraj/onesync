import 'dart:typed_data';

class AppFilterItem {
  final String name;
  final String packageName;
  final bool enabled;
  final Uint8List? icon;

  AppFilterItem({
    required this.name,
    required this.packageName,
    required this.enabled,
    this.icon,
  });

  AppFilterItem copyWith({
    String? name,
    String? packageName,
    bool? enabled,
    Uint8List? icon,
  }) {
    return AppFilterItem(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      enabled: enabled ?? this.enabled,
      icon: icon ?? this.icon,
    );
  }
}