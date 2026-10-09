import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

enum CustomButtonType { primary, secondary, outlined, danger }

/// Production-ready standardized button supporting loading states, icons, and variants
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CustomButtonType type;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = CustomButtonType.primary,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (type) {
      case CustomButtonType.primary:
        backgroundColor = isEnabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5);
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case CustomButtonType.secondary:
        backgroundColor = isEnabled ? AppColors.secondary : AppColors.secondary.withValues(alpha: 0.5);
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case CustomButtonType.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? AppColors.primary : AppColors.textMutedLight;
        borderSide = BorderSide(
          color: isEnabled ? AppColors.primary : AppColors.borderLight,
          width: 1.5,
        );
        break;
      case CustomButtonType.danger:
        backgroundColor = isEnabled ? AppColors.emergency : AppColors.emergency.withValues(alpha: 0.5);
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor,
          disabledForegroundColor: foregroundColor,
          elevation: 0,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 18, color: foregroundColor),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(suffixIcon, size: 18, color: foregroundColor),
                  ],
                ],
              ),
      ),
    );
  }
}
