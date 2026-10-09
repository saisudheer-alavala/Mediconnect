import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/appointment_model.dart';
import 'appointment_controller.dart';

class AppointmentListScreen extends ConsumerStatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  ConsumerState<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends ConsumerState<AppointmentListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appointmentControllerProvider.notifier).loadInitialData();
    });
  }

  void _showCancellationDialog(AppointmentModel appointment, {bool isDoctor = false}) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Cancel Appointment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDoctor
                  ? 'Are you sure you want to cancel the consultation with ${appointment.patientName ?? "the patient"} on ${appointment.formattedDate} at ${appointment.startTime}?'
                  : 'Are you sure you want to cancel your consultation with ${appointment.doctorName} on ${appointment.formattedDate} at ${appointment.startTime}?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: reasonController,
              labelText: 'Cancellation Reason (Optional)',
              hintText: isDoctor ? 'e.g., Emergency surgery, clinic schedule change...' : 'e.g., Schedule conflict, resolved symptoms...',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Appointment'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final reason = reasonController.text.trim();
              final success = await ref
                  .read(appointmentControllerProvider.notifier)
                  .cancelAppointment(appointment.id, reason: reason.isNotEmpty ? reason : null);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Appointment cancelled.' : 'Failed to cancel appointment.',
                    ),
                    backgroundColor: success ? AppColors.warning : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('Complete Consultation'),
          ],
        ),
        content: Text(
          'Mark consultation with ${appointment.patientName ?? "the patient"} on ${appointment.formattedDate} as completed and patient attended?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(appointmentControllerProvider.notifier)
                  .updateAppointmentStatus(appointment.id, 'COMPLETED');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Consultation with ${appointment.patientName ?? "patient"} marked as completed.'
                          : 'Failed to update consultation status.',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Mark Completed'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAppointmentSlot(AppointmentModel appointment) async {
    final success = await ref
        .read(appointmentControllerProvider.notifier)
        .updateAppointmentStatus(appointment.id, 'CONFIRMED');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Appointment with ${appointment.patientName ?? "patient"} confirmed.'
                : 'Failed to confirm appointment.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final isDoctor = user?.role == UserRole.doctor;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isDoctor ? 'Patient Appointments & Queue' : 'My Appointments'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryLight,
            tabs: [
              Tab(text: isDoctor ? 'Queue (${state.upcomingAppointments.length})' : 'Upcoming'),
              Tab(text: isDoctor ? 'Completed Visits' : 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildHealthcareDisclaimerBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAppointmentList(
                    appointments: state.upcomingAppointments,
                    isLoading: state.isLoading,
                    emptyView: EmptyStateView(
                      icon: Icons.calendar_today_rounded,
                      title: isDoctor ? 'No Patients in Queue' : 'No Upcoming Appointments',
                      description: isDoctor
                          ? 'No scheduled consultations found in your appointment queue today.'
                          : 'You have no scheduled consultations. Find a verified doctor to book.',
                      actionText: isDoctor ? 'Manage Schedule' : 'Find Doctor',
                      onAction: () => context.go(isDoctor ? '/doctor/schedule' : '/patient/doctors'),
                    ),
                    isUpcomingTab: true,
                    isDoctor: isDoctor,
                  ),
                  _buildAppointmentList(
                    appointments: state.completedAppointments,
                    isLoading: state.isLoading,
                    emptyView: EmptyStateView(
                      icon: Icons.history_rounded,
                      title: isDoctor ? 'No Completed Patient Visits' : 'No Completed Consultations',
                      description: isDoctor
                          ? 'Past patient consultations and clinical summaries will appear here.'
                          : 'Past consultations and digital medical records will appear here.',
                    ),
                    isUpcomingTab: false,
                    isDoctor: isDoctor,
                  ),
                  _buildAppointmentList(
                    appointments: state.cancelledAppointments,
                    isLoading: state.isLoading,
                    emptyView: const EmptyStateView(
                      icon: Icons.event_busy_rounded,
                      title: 'No Cancelled Consultations',
                      description: 'Cancelled appointments will appear here.',
                    ),
                    isUpcomingTab: false,
                    isDoctor: isDoctor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthcareDisclaimerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.infoLight.withValues(alpha: 0.4),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Informational Tool: MediCare Connect facilitates appointments. In acute emergencies, dial emergency services immediately.',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondaryLight,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList({
    required List<AppointmentModel> appointments,
    required bool isLoading,
    required Widget emptyView,
    required bool isUpcomingTab,
    required bool isDoctor,
  }) {
    if (isLoading && appointments.isEmpty) {
      return const Center(child: LoadingIndicator(message: 'Loading appointments...'));
    }

    if (appointments.isEmpty) {
      return emptyView;
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(appointmentControllerProvider.notifier).loadInitialData(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = appointments[index];
          return _buildAppointmentCard(item, isUpcomingTab: isUpcomingTab, isDoctor: isDoctor);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
    AppointmentModel appointment, {
    required bool isUpcomingTab,
    required bool isDoctor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Patient details if Doctor, or Doctor details if Patient
            if (isDoctor) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                    child: Text(
                      appointment.patientName?.isNotEmpty == true
                          ? appointment.patientName!.split(' ').map((e) => e[0]).take(2).join()
                          : 'P',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                appointment.patientName ?? 'Registered Patient',
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (appointment.patientBloodGroup != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  appointment.patientBloodGroup!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${appointment.patientGender ?? "Patient"}${appointment.patientDob != null ? " • Born ${appointment.patientDob}" : ""}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (appointment.patientPhone != null && appointment.patientPhone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondaryLight),
                              const SizedBox(width: 4),
                              Text(
                                appointment.patientPhone!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusChip(appointment.status),
                ],
              ),
              // Patient Clinical background specifics (allergies & chronic thoughts)
              if ((appointment.patientAllergies != null && appointment.patientAllergies!.isNotEmpty) ||
                  (appointment.patientChronicDiseases != null && appointment.patientChronicDiseases!.isNotEmpty)) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (appointment.patientAllergies != null && appointment.patientAllergies!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Allergies: ${appointment.patientAllergies}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (appointment.patientChronicDiseases != null && appointment.patientChronicDiseases!.isNotEmpty) ...[
                        if (appointment.patientAllergies != null && appointment.patientAllergies!.isNotEmpty)
                          const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.medical_information_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Patient Thoughts & Conditions: ${appointment.patientChronicDiseases}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ] else ...[
              // Patient view: Doctor Name + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        appointment.doctorName.split(' ').map((e) => e[0]).take(2).join(),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appointment.specializationName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appointment.clinicName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(appointment.status),
                ],
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Date & Time Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        appointment.formattedDate,
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      appointment.formattedTimeSlot,
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),

            // Patient Notes (if provided)
            if (appointment.patientNotes != null && appointment.patientNotes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_rounded, size: 14, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isDoctor ? 'Chief Complaint / Notes: ${appointment.patientNotes!}' : 'Note: ${appointment.patientNotes!}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondaryLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Cancellation Reason (if cancelled)
            if (appointment.isCancelled && appointment.cancellationReason != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel_outlined, size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Reason: ${appointment.cancellationReason!}',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action / Controls for Doctor or Patient
            if (isUpcomingTab) ...[
              const SizedBox(height: 14),
              if (isDoctor) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (appointment.isPending)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Confirm Slot'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => _confirmAppointmentSlot(appointment),
                      )
                    else
                      ElevatedButton.icon(
                        icon: const Icon(Icons.done_all_rounded, size: 16),
                        label: const Text('Mark Completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => _showCompletionDialog(appointment),
                      ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.videocam_rounded, size: 16),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            textStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            try {
                              context.push('/patient/appointments/${appointment.id}/call');
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Starting patient video consultation...')),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _showCancellationDialog(appointment, isDoctor: true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            textStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fee: \$${appointment.consultationFee.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          key: Key('cancel_appointment_${appointment.id}'),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            textStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () => _showCancellationDialog(appointment),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          key: Key('join_call_${appointment.id}'),
                          icon: const Icon(Icons.videocam_rounded, size: 16),
                          label: const Text('Join Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            try {
                              context.push('/patient/appointments/${appointment.id}/waiting-room');
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Opening consultation waiting room...'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],

            // Action / View Prescription for completed
            if (appointment.isCompleted) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        isDoctor ? 'Patient Attended & Consulted' : 'Consultation Finished',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    key: Key('view_prescription_${appointment.id}'),
                    icon: const Icon(Icons.receipt_long_rounded, size: 16),
                    label: Text(isDoctor ? 'Prescriptions' : 'View Prescription'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      textStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      try {
                        context.push('/patient/prescriptions');
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening digital prescription...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    String label = status;

    switch (status) {
      case 'CONFIRMED':
        bg = AppColors.successLight;
        fg = AppColors.success;
        label = 'Confirmed';
        break;
      case 'PENDING':
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        label = 'Pending';
        break;
      case 'COMPLETED':
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        label = 'Completed';
        break;
      case 'CANCELLED':
        bg = AppColors.errorLight;
        fg = AppColors.error;
        label = 'Cancelled';
        break;
      default:
        bg = AppColors.inputBackground;
        fg = AppColors.textSecondaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
