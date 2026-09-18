import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = statusColors[status] ?? AppColors.muted;
    final background = statusBackgrounds[status] ?? AppColors.primarySoft;
    final label = labelFor(orderStatusLabels, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
