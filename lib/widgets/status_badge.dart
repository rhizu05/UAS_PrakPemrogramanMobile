import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = const Color(0xFFFFEDD5); // orange-100
        textColor = const Color(0xFFEA580C); // orange-600
        break;
      case 'processing':
        backgroundColor = const Color(0xFFDBEAFE); // blue-100
        textColor = const Color(0xFF2563EB); // blue-600
        break;
      case 'shipped':
        backgroundColor = const Color(0xFFF3E8FF); // purple-100
        textColor = const Color(0xFF7C3AED); // purple-600
        break;
      case 'delivered':
        backgroundColor = const Color(0xFFD1FAE5); // emerald-100
        textColor = const Color(0xFF10B981); // emerald-600
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFFFEE2E2); // red-100
        textColor = const Color(0xFFDC2626); // red-600
        break;
      default:
        backgroundColor = const Color(0xFFF1F5F9); // slate-100
        textColor = const Color(0xFF475569); // slate-600
    }

    // Capitalize status
    final capitalizedStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1).toLowerCase()
        : status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        capitalizedStatus,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
