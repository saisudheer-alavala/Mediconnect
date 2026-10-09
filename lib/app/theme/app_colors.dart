import 'package:flutter/material.dart';

/// Design tokens and semantic color palette for MediCare Connect
class AppColors {
  AppColors._();

  // Primary Palette - Medical Teal & Ocean Blue
  static const Color primary = Color(0xFF0284C7); // Sky/Ocean Blue
  static const Color primaryDark = Color(0xFF0369A1);
  static const Color primaryLight = Color(0xFFE0F2FE);

  // Secondary Palette - Healing Sage & Green
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color secondaryDark = Color(0xFF0F766E);
  static const Color secondaryLight = Color(0xFFCCFBF1);

  // Accent & Action
  static const Color accent = Color(0xFF6366F1); // Indigo

  // Emergency & Status Colors
  static const Color emergency = Color(0xFFDC2626); // Crimson Red
  static const Color emergencyLight = Color(0xFFFEE2E2);

  static const Color success = Color(0xFF16A34A); // Forest Green
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFD97706); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFE11D48); // Rose
  static const Color errorLight = Color(0xFFFFE4E6);

  static const Color info = Color(0xFF2563EB); // Blue
  static const Color infoLight = Color(0xFFDBEAFE);

  // Neutral Background & Surface (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color inputBackground = Color(0xFFF1F5F9);

  // Neutral Background & Surface (Dark Mode)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
}
