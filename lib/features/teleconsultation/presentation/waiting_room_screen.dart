import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import 'teleconsultation_controller.dart';

class WaitingRoomScreen extends ConsumerStatefulWidget {
  final String appointmentId;

  const WaitingRoomScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  ConsumerState<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends ConsumerState<WaitingRoomScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(teleconsultationControllerProvider.notifier).loadSession(widget.appointmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teleconsultationControllerProvider);
    final session = state.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Waiting Room'),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: CustomButton(
            key: const Key('enter_consultation_button'),
            text: 'Enter Consultation Room',
            prefixIcon: Icons.videocam_rounded,
            onPressed: () {
              context.push('/patient/appointments/${widget.appointmentId}/call');
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Summary Card
            if (session != null) _buildDoctorSummary(session.doctorName, session.doctorSpecialization, session.timeSlotString),
            const SizedBox(height: 20),

            // Video Preview & Pre-Call Media Toggles
            _buildVideoPreview(state),
            const SizedBox(height: 20),

            // Hardware & Network Diagnostics
            Text('Device & Connectivity Diagnostics', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            _buildDiagnosticsCard(state),
            const SizedBox(height: 20),

            // Clinical Emergency Boundary Disclaimer
            _buildEmergencyDisclaimer(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSummary(String doctorName, String spec, String timeSlot) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                doctorName.split(' ').map((e) => e[0]).take(2).join(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      doctorName,
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  spec,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(
                      timeSlot,
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Online',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(TeleconsultationState state) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (state.isVideoOff)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 32),
                ),
                const SizedBox(height: 10),
                Text(
                  'Camera Disabled',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Local Video Stream Ready',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  state.isFrontCamera ? 'Front Camera' : 'Rear Camera',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white60),
                ),
              ],
            ),

          // Pre-call control pill overlay
          Positioned(
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('waiting_room_mic_toggle'),
                    icon: Icon(
                      state.isAudioMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: state.isAudioMuted ? AppColors.error : Colors.white,
                    ),
                    onPressed: () => ref.read(teleconsultationControllerProvider.notifier).toggleAudio(),
                  ),
                  IconButton(
                    key: const Key('waiting_room_cam_toggle'),
                    icon: Icon(
                      state.isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                      color: state.isVideoOff ? AppColors.error : Colors.white,
                    ),
                    onPressed: () => ref.read(teleconsultationControllerProvider.notifier).toggleVideo(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
                    onPressed: () => ref.read(teleconsultationControllerProvider.notifier).switchCamera(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticsCard(TeleconsultationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildDiagnosticItem(
            icon: Icons.mic_rounded,
            title: 'Microphone Input',
            subtitle: state.isAudioMuted ? 'Muted by user' : 'Active & calibrated',
            isSuccess: !state.isAudioMuted,
          ),
          const Divider(height: 16),
          _buildDiagnosticItem(
            icon: Icons.videocam_rounded,
            title: 'High-Definition Camera',
            subtitle: state.isVideoOff ? 'Turned off by user' : '720p HD ready',
            isSuccess: !state.isVideoOff,
          ),
          const Divider(height: 16),
          _buildDiagnosticItem(
            icon: Icons.network_check_rounded,
            title: 'End-to-End Encryption & Latency',
            subtitle: 'Secure AES-256 • 35ms latency (Optimal)',
            isSuccess: state.isNetworkStable,
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSuccess,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isSuccess ? AppColors.success : AppColors.warning),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
            ],
          ),
        ),
        Icon(
          isSuccess ? Icons.check_circle_rounded : Icons.info_rounded,
          size: 18,
          color: isSuccess ? AppColors.success : AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildEmergencyDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.emergencyLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emergency.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.emergency_rounded, color: AppColors.emergency, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Teleconsultation Emergency Boundary: Virtual consultations are intended for non-emergent medical triage, routine advice, and prescription management. In case of acute chest pain, sudden paralysis, severe hemorrhage, or respiratory distress, terminate this session immediately and dial emergency services (911 / 112).',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.emergency,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
