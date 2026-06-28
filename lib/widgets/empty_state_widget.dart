import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.shopping_cart_outlined,
    required this.message,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 72,
            color: AppColors.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onActionPressed != null && actionText != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    ));
  }
}
