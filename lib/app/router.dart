import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/appointments/presentation/appointment_list_screen.dart';
import '../features/appointments/presentation/book_appointment_screen.dart';
import '../features/auth/presentation/doctor_register_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/patient_register_screen.dart';
import '../features/doctors/domain/doctor_model.dart';
import '../features/doctors/presentation/doctor_details_screen.dart';
import '../features/schedule/presentation/doctor_schedule_screen.dart';
import '../features/doctors/presentation/doctor_search_screen.dart';
import '../features/home/presentation/doctor_home_screen.dart';
import '../features/home/presentation/doctor_main_layout.dart';
import '../features/home/presentation/patient_home_screen.dart';
import '../features/home/presentation/patient_main_layout.dart';
import '../features/home/presentation/splash_screen.dart';
import '../features/medicines/presentation/add_edit_medicine_screen.dart';
import '../features/medicines/presentation/medicine_list_screen.dart';
import '../features/prescriptions/domain/prescription_model.dart';
import '../features/prescriptions/presentation/prescription_controller.dart';
import '../features/prescriptions/presentation/prescription_details_screen.dart';
import '../features/prescriptions/presentation/prescription_list_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/teleconsultation/presentation/teleconsultation_room_screen.dart';
import '../features/teleconsultation/presentation/waiting_room_screen.dart';
import '../features/emergency/presentation/emergency_vault_screen.dart';
import '../features/health_records/presentation/health_record_timeline_screen.dart';
import '../features/health_records/presentation/add_edit_health_record_screen.dart';
import '../features/notifications/presentation/notification_center_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider for application-wide declarative routing with GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash & Auth routes
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register-patient',
        name: 'register-patient',
        builder: (context, state) => const PatientRegisterScreen(),
      ),
      GoRoute(
        path: '/register-doctor',
        name: 'register-doctor',
        builder: (context, state) => const DoctorRegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ----------------------------------------------------
      // PATIENT SHELL ROUTES (5 Bottom Navigation Tabs)
      // ----------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PatientMainLayout(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient',
                name: 'patient-home',
                builder: (context, state) => const PatientHomeScreen(),
              ),
            ],
          ),
          // Branch 1: Doctors Directory
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/doctors',
                name: 'patient-doctors',
                builder: (context, state) => const DoctorSearchScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'patient-doctor-details',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final doc = state.extra as DoctorModel?;
                      if (doc != null) {
                        return DoctorDetailsScreen(doctor: doc);
                      }
                      return const DoctorSearchScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Appointments
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/appointments',
                name: 'patient-appointments',
                builder: (context, state) => const AppointmentListScreen(),
                routes: [
                  GoRoute(
                    path: 'book',
                    name: 'patient-book-appointment',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final doc = state.extra as DoctorModel?;
                      if (doc != null) {
                        return BookAppointmentScreen(doctor: doc);
                      }
                      return const AppointmentListScreen();
                    },
                  ),
                  GoRoute(
                    path: ':id/waiting-room',
                    name: 'patient-waiting-room',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? 'appt-1';
                      return WaitingRoomScreen(appointmentId: id);
                    },
                  ),
                  GoRoute(
                    path: ':id/call',
                    name: 'patient-teleconsultation-call',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? 'appt-1';
                      return TeleconsultationRoomScreen(appointmentId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Medicines
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/medicines',
                name: 'patient-medicines',
                builder: (context, state) => const MedicineListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'patient-add-medicine',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const AddEditMedicineScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/profile',
                name: 'patient-profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Patient Digital Prescriptions
      GoRoute(
        path: '/patient/prescriptions',
        name: 'patient-prescriptions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrescriptionListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'patient-prescription-details',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final rx = state.extra as PrescriptionModel?;
              if (rx != null) {
                return PrescriptionDetailsScreen(prescription: rx);
              }
              final rxId = state.pathParameters['id'] ?? '';
              return Consumer(
                builder: (context, ref, _) {
                  final list = ref.watch(prescriptionControllerProvider).prescriptions;
                  final match = list.where((p) => p.id == rxId).firstOrNull ?? list.first;
                  return PrescriptionDetailsScreen(prescription: match);
                },
              );
            },
          ),
        ],
      ),

      // Patient Emergency & SOS Health Vault
      GoRoute(
        path: '/patient/emergency',
        name: 'patient-emergency',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EmergencyVaultScreen(),
      ),

      // Patient Health Records & Medical Timeline
      GoRoute(
        path: '/patient/health-records',
        name: 'patient-health-records',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthRecordTimelineScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'patient-add-health-record',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AddEditHealthRecordScreen(),
          ),
        ],
      ),

      // In-App Notifications Center
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationCenterScreen(),
      ),

      // ----------------------------------------------------
      // DOCTOR SHELL ROUTES (4 Bottom Navigation Tabs)
      // ----------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DoctorMainLayout(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Doctor Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor',
                name: 'doctor-home',
                builder: (context, state) => const DoctorHomeScreen(),
              ),
            ],
          ),
          // Branch 1: Doctor Appointments
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/appointments',
                name: 'doctor-appointments',
                builder: (context, state) => const AppointmentListScreen(),
              ),
            ],
          ),
          // Branch 2: Doctor Schedule
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/schedule',
                name: 'doctor-schedule',
                builder: (context, state) => const DoctorScheduleScreen(),
              ),
            ],
          ),
          // Branch 3: Doctor Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/profile',
                name: 'doctor-profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
