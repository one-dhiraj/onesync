import 'dart:typed_data';
import 'package:flutter/material.dart';

class AppIconView extends StatelessWidget {
  final Uint8List? icon;
  final double size;

  const AppIconView({
    super.key,
    required this.icon,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          icon!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    // default android-style placeholder icon
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.android,
        size: size * 0.75,
        color: Colors.grey.shade600,
      ),
    );
  }
}