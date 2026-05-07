import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesync/models/app_filter_item.dart';
import 'package:onesync/providers/app_filter_provider.dart';
import 'app_icon.dart';

class AppFilterPreviewSection extends StatelessWidget {
  final VoidCallback onViewAll;

  const AppFilterPreviewSection({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppFilterProvider>(context);

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<AppFilterItem> apps = provider.previewApps;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          for (final app in apps)
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: AppIconView(icon: app.icon),
              title: Text(app.name, style: const TextStyle(fontSize: 14)),
              trailing: Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: app.enabled,
                  onChanged: (v) => provider.toggle(app.packageName, v),
                ),
              ),
            ),
          const Divider(height: 0, indent: 13, endIndent: 13),
          ListTile(
            title: const Text("View all apps"),
            trailing: const Icon(Icons.chevron_right),
            onTap: onViewAll,
          ),
        ],
      ),
    );
  }
}

class AppFilterFullSheet extends StatelessWidget {
  const AppFilterFullSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppFilterProvider>(context);
    
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 48),
          children: provider.groupedPackageNames.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Divider(height: 0, indent: 15, endIndent: 15, color: Colors.black26),
                ...entry.value.map((appPackageName) {
                  var app = provider.appMap[appPackageName]!;

                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: AppIconView(icon: app.icon),
                    title: Text(app.name, style: const TextStyle(fontSize: 14)),
                    trailing: Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: app.enabled,
                        onChanged: (v) => provider.toggle(app.packageName, v),
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
