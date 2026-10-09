import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Standard typography system for MediCare Connect
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondaryLight,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );
}
