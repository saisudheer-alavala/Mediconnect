/// Global application-level constants for MediCare Connect
class AppConstants {
  AppConstants._();

  static const String appName = 'MediCare Connect';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Personal Health & Care Companion';

  // Medical Disclaimer
  static const String medicalDisclaimer =
      'MediCare Connect is an informational and health management tool. '
      'It is not a substitute for professional medical advice, diagnosis, or treatment. '
      'In a medical emergency, call emergency services immediately.';

  // Storage Keys
  static const String tokenKey = 'medicare_access_token';
  static const String refreshTokenKey = 'medicare_refresh_token';
  static const String userRoleKey = 'medicare_user_role';
  static const String userIdKey = 'medicare_user_id';
  static const String themePreferenceKey = 'medicare_theme_mode';

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
