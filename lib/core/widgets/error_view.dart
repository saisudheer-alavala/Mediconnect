import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'custom_button.dart';

/// User-friendly error view with optional retry action
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: retryText,
                onPressed: onRetry,
                prefixIcon: Icons.refresh_rounded,
                width: 180,
                height: 44,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
