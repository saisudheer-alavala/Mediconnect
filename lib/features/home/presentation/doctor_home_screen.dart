import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/presentation/auth_controller.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  bool _isAcceptingConsultations = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final doctorProfile = user?.doctorProfile;
    final doctorName = doctorProfile?.fullName ?? user?.displayName ?? 'Doctor';
    final specialization = doctorProfile?.specializationName ?? 'General Physician';
    final clinicName = doctorProfile?.clinicName ?? 'Private Practice';
    final isVerified = doctorProfile?.isVerified ?? false;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(doctorName, specialization, clinicName, isVerified),
              const SizedBox(height: 20),

              // Verification notice if unverified
              if (!isVerified) ...[
                _buildVerificationNotice(),
                const SizedBox(height: 20),
              ],

              // Availability toggle banner
              _buildAvailabilityToggleCard(),
              const SizedBox(height: 20),

              // Metrics Row
              _buildMetricsRow(),
              const SizedBox(height: 24),

              // Next Patient Card
              SectionHeader(
                title: 'Next Patient in Queue',
                actionText: 'View Queue',
                onAction: () => context.go('/doctor/appointments'),
              ),
              const SizedBox(height: 8),
              _buildNextPatientCard(),
              const SizedBox(height: 24),

              // Quick Actions
              const SectionHeader(title: 'Practice Management'),
              const SizedBox(height: 8),
              _buildPracticeQuickActions(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String specialty, String clinic, bool isVerified) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name.startsWith('Dr.') ? name : 'Dr. $name',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isVerified)
                    const Icon(
                      Icons.verified_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$specialty • $clinic',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          child: const Icon(
            Icons.medical_services_rounded,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your profile is currently awaiting credential verification by the clinical administration. Patient booking slots will be published once verified.',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF92400E),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isAcceptingConsultations ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _isAcceptingConsultations ? 'Accepting Patients' : 'Paused / Off Duty',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
              ),
            ],
          ),
          Switch(
            value: _isAcceptingConsultations,
            activeThumbColor: AppColors.secondary,
            onChanged: (val) {
              setState(() => _isAcceptingConsultations = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile('8', "Today's Consultations", AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile('3', 'Pending Requests', AppColors.warning),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile('5', 'Completed Today', AppColors.success),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPatientCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '11:00 AM — Today (In 20 mins)',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
              Chip(
                label: const Text('Slot 4/12'),
                backgroundColor: AppColors.primaryLight,
                labelStyle: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Michael Chang (Male, 42y)',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chief Complaint: Follow-up on hypertension & routine prescription renewal.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Begin Consultation',
            prefixIcon: Icons.play_arrow_rounded,
            height: 44,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Starting consultation with Michael Chang...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeQuickActions() {
    final actions = [
      {
        'title': 'Weekly Schedule',
        'icon': Icons.schedule_rounded,
        'route': '/doctor/schedule',
      },
      {
        'title': 'All Appointments',
        'icon': Icons.calendar_month_rounded,
        'route': '/doctor/appointments',
      },
      {
        'title': 'Doctor Profile',
        'icon': Icons.badge_outlined,
        'route': '/doctor/profile',
      },
    ];

    return Row(
      children: actions.map((act) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => context.go(act['route'] as String),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Icon(act['icon'] as IconData, color: AppColors.secondary, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      act['title'] as String,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
