import 'package:flutter/material.dart';

class NotificationFilteringTile extends StatelessWidget {
  final VoidCallback onTap;

  const NotificationFilteringTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.filter_alt_outlined),
        title: const Text("Notification Filters"),
        subtitle: const Text(
          "Choose which apps are allowed to sync",
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}