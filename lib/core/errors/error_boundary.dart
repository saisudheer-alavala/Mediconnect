import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

Widget buildClinicalErrorFallback(FlutterErrorDetails details) {
  return Material(
    color: Colors.white,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.health_and_safety_outlined,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Clinical Screen Display Notice',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A layout rendering exception was safely intercepted. Your stored clinical records, prescriptions, and regimen details remain completely intact.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

void setupGlobalErrorBoundaries() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[Clinical Safety Boundary] Flutter framework error: ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[Clinical Safety Boundary] Asynchronous platform exception intercepted: $error');
    return true;
  };

  ErrorWidget.builder = buildClinicalErrorFallback;
}
