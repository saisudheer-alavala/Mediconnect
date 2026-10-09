import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_button.dart';

/// Initial entry screen showing brand, version, medical disclaimer, and Get Started navigation
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Medical Logo Icon Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                AppConstants.appName,
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                AppConstants.appTagline,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // Get Started CTA Button
              CustomButton(
                text: 'Get Started',
                suffixIcon: Icons.arrow_forward_rounded,
                onPressed: () => context.go('/login'),
              ),

              const Spacer(),

              // Medical Safety Notice Container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppConstants.medicalDisclaimer,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF92400E),
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'v${AppConstants.appVersion}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
