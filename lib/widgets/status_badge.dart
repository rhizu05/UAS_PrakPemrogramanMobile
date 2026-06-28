import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppColors.statusPending;
        break;
      case 'processing':
        backgroundColor = AppColors.statusProcessing;
        break;
      case 'shipped':
        backgroundColor = AppColors.statusShipped;
        break;
      case 'delivered':
        backgroundColor = AppColors.statusDelivered;
        break;
      case 'cancelled':
        backgroundColor = AppColors.statusCancelled;
        break;
      default:
        backgroundColor = AppColors.secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
