/// Centralized API endpoint routes and network configurations
class ApiEndpoints {
  ApiEndpoints._();

  // Configurable at build time via --dart-define=API_BASE_URL=https://...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Auth
  static const String login = '/auth/login';
  static const String registerPatient = '/auth/register/patient';
  static const String registerDoctor = '/auth/register/doctor';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Profile & User Management
  static const String currentUser = '/profile/me';
  static const String userProfile = '/profile/me';
  static const String updatePatientProfile = '/profile/patient';
  static const String updateDoctorProfile = '/profile/doctor';
  static const String changePassword = '/profile/change-password';
  static const String deactivateAccount = '/profile/deactivate';

  // Doctors & Directory
  static const String doctors = '/doctors';
  static const String specializations = '/doctors/specializations';
  static String doctorDetails(String id) => '/doctors/$id';
  static String doctorSlots(String id) => '/doctors/$id/available-slots';

  // Appointments
  static const String appointments = '/appointments';
  static String appointmentDetails(String id) => '/appointments/$id';
  static String updateAppointmentStatus(String id) => '/appointments/$id/status';

  // Medicines
  static const String medicines = '/medicines';
  static const String todayMedicines = '/medicines/today';
  static const String medicineAdherence = '/medicines/adherence';
  static String medicineDetails(String id) => '/medicines/$id';
  static String logMedicineDose(String id) => '/medicines/$id/log';

  // Health Records
  static const String healthRecords = '/health-records';
  static String healthRecordDetails(String id) => '/health-records/$id';

  // Prescriptions
  static const String prescriptions = '/prescriptions';
  static String prescriptionDetails(String id) => '/prescriptions/$id';
  static String prescriptionByAppointment(String appointmentId) => '/prescriptions/appointment/$appointmentId';

  // Emergency & SOS Health Vault
  static const String emergencyProfile = '/emergency/profile';
  static const String emergencyContacts = '/emergency/contacts';
  static String emergencyContactDetails(String id) => '/emergency/contacts/$id';

  // Notifications & Adherence Reminders
  static const String notifications = '/notifications';
  static const String unreadNotificationsCount = '/notifications/unread-count';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static String deleteNotification(String id) => '/notifications/$id';

  // Doctor Ratings & Reviews
  static String doctorReviews(String doctorId) => '/doctors/$doctorId/reviews';
  static String doctorRatingSummary(String doctorId) => '/doctors/$doctorId/rating-summary';
  static String submitDoctorReview(String doctorId) => '/doctors/$doctorId/reviews';

  // Doctor Schedule & Working Hours
  static const String doctorSchedule = '/doctors/me/schedule';
}
