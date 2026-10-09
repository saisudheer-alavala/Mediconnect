import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Standardized loading spinner with optional message
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 36,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
