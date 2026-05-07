import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const DashboardTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 260;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: resolvedColor.withOpacity(0.08),
              border: Border.all(color: resolvedColor.withOpacity(0.35)),
            ),
            child: isCompact
                ? _buildCompact(resolvedColor)
                : _buildExpanded(resolvedColor),
          ),
        );
      },
    );
  }

  Widget _buildCompact(Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 30, color: c),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildExpanded(Color c) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 30, color: c),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: c,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: const TextStyle(fontSize: 13)),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
