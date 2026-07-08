import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDanger;
  final bool isOutlined;
  final IconData? icon;
  final double? borderRadius;
  final double? height;
  final double iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDanger = false,
    this.isOutlined = false,
    this.icon,
    this.borderRadius = 14,
    this.height,
    this.iconSize = 20,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        backgroundColor ?? (isDanger ? AppColors.error : AppColors.primary);
    final textColor =
        foregroundColor ?? (isOutlined ? buttonColor : Colors.white);

    final radius = BorderRadius.circular(borderRadius ?? 14);
    final padding = height != null
        ? EdgeInsets.symmetric(vertical: (height! - 24) / 2)
        : const EdgeInsets.symmetric(vertical: 16);

    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, size: iconSize, color: textColor),
          ],
        ],
      );
    }

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: buttonColor,
            side: BorderSide(color: buttonColor, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: radius),
            padding: padding,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: textColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: radius),
              padding: padding,
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return buttonColor.withValues(alpha: 0.5);
                }
                return buttonColor;
              }),
            ),
        child: child,
      ),
    );
  }
}
