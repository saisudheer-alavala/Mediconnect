import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../medicines/domain/medicine_model.dart';
import '../../medicines/presentation/medicine_controller.dart';
import '../../notifications/presentation/notification_controller.dart';

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final patientName = user?.patientProfile?.fullName ?? user?.displayName ?? 'Patient';
    final medState = ref.watch(medicineControllerProvider);
    final todayDoses = medState.todayDoses;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header: User Greeting & Avatar
              _buildHeader(patientName),
              const SizedBox(height: 20),

              // Emergency SOS Banner
              _buildEmergencyCard(),
              const SizedBox(height: 24),

              // Upcoming Appointment Card
              _buildUpcomingAppointmentCard(),
              const SizedBox(height: 24),

              // Today's Medicines Adherence Checklist
              SectionHeader(
                title: "Today's Medicines",
                actionText: 'Manage All',
                onAction: () => context.go('/patient/medicines'),
              ),
              const SizedBox(height: 8),
              if (todayDoses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Center(
                    child: Text(
                      'No medicines scheduled for today.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                    ),
                  ),
                )
              else
                ...List.generate(
                  todayDoses.length,
                  (index) => _buildMedicineItem(todayDoses[index]),
                ),
              const SizedBox(height: 24),

              // Quick Health Actions Grid
              const SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 8),
              _buildQuickActionsGrid(),
              const SizedBox(height: 24),

              // Mandatory Medical Disclaimer Card
              _buildDisclaimerCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    final unreadCount = ref.watch(notificationControllerProvider).unreadCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $name',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'How are you feeling today?',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: () {
                try {
                  context.push('/notifications');
                } catch (_) {
                  context.go('/notifications');
                }
              },
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.emergency,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyCard() {
    return InkWell(
      onTap: () {
        try {
          context.push('/patient/emergency');
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening Emergency SOS Card...'),
              backgroundColor: AppColors.emergency,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.emergencyLight.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.emergency.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.emergency,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Medical ID',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.emergency,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Quick access to ICE contacts & blood group',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF991B1B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                try {
                  context.push('/patient/emergency');
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening Emergency SOS Card...'),
                      backgroundColor: AppColors.emergency,
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.emergency,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Consultation',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'CONFIRMED',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Sarah Jenkins',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cardiologist • City Heart Hospital',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Today, 10:30 AM',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/patient/appointments'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'View Details',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineItem(TodayDoseItem dose) {
    final isTaken = dose.isTaken;
    final controller = ref.read(medicineControllerProvider.notifier);

    return Container(
      key: ValueKey('${dose.medicineId}_${dose.reminderTime}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isTaken ? AppColors.successLight.withValues(alpha: 0.25) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTaken ? AppColors.success.withValues(alpha: 0.3) : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTaken ? AppColors.successLight : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.medication_rounded,
              size: 20,
              color: isTaken ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dose.medicineName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${dose.dosage} • ${dose.reminderTime} • ${dose.instructions ?? dose.frequency}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              final newStatus = isTaken ? 'PENDING' : 'TAKEN';
              controller.toggleDoseStatus(dose, newStatus);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    newStatus == 'TAKEN'
                        ? '${dose.medicineName} marked as taken'
                        : '${dose.medicineName} marked as pending',
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: newStatus == 'TAKEN' ? AppColors.success : AppColors.warning,
                ),
              );
            },
            icon: Icon(
              isTaken ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isTaken ? AppColors.success : AppColors.textMutedLight,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {
        'title': 'Find Doctors',
        'icon': Icons.search_rounded,
        'color': AppColors.primary,
        'route': '/patient/doctors',
      },
      {
        'title': 'My Medicines',
        'icon': Icons.alarm_rounded,
        'color': AppColors.secondary,
        'route': '/patient/medicines',
      },
      {
        'title': 'Appointments',
        'icon': Icons.calendar_today_rounded,
        'color': AppColors.accent,
        'route': '/patient/appointments',
      },
      {
        'title': 'Health Records',
        'icon': Icons.history_edu_rounded,
        'color': const Color(0xFF0D9488),
        'route': '/patient/health-records',
      },
      {
        'title': 'Prescriptions',
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF7C3AED),
        'route': '/patient/prescriptions',
      },
      {
        'title': 'Emergency ID',
        'icon': Icons.emergency_rounded,
        'color': AppColors.emergency,
        'route': '/patient/emergency',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        final color = action['color'] as Color;

        return InkWell(
          onTap: () {
            try {
              context.push(action['route'] as String);
            } catch (_) {
              context.go(action['route'] as String);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    action['title'] as String,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
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
    );
  }
}
