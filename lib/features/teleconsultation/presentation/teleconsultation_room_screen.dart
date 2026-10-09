import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import 'teleconsultation_controller.dart';

class TeleconsultationRoomScreen extends ConsumerStatefulWidget {
  final String appointmentId;

  const TeleconsultationRoomScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  ConsumerState<TeleconsultationRoomScreen> createState() => _TeleconsultationRoomScreenState();
}

class _TeleconsultationRoomScreenState extends ConsumerState<TeleconsultationRoomScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(teleconsultationControllerProvider.notifier).startCall();
    });
  }

  void _showEndCallConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.call_end_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('End Consultation'),
          ],
        ),
        content: const Text(
          'Are you sure you want to conclude this video consultation session? Digital consultation notes and prescriptions will be saved to your health vault.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Return to Call'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(teleconsultationControllerProvider.notifier).endCall();
              _showPostConsultationSummary();
            },
            child: const Text('Conclude Consultation'),
          ),
        ],
      ),
    );
  }

  void _showPostConsultationSummary() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Consultation Concluded',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Your digital records and doctor advice have been saved securely.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/patient/appointments');
                      }
                    },
                    child: const Text('My Appointments'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.push('/patient/prescriptions');
                    },
                    child: const Text('View Prescriptions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teleconsultationControllerProvider);
    final session = state.session;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote Practitioner Full-Screen Video Canvas
            _buildRemoteParticipantView(session?.doctorName ?? 'Dr. Specialist', session?.doctorSpecialization ?? 'Cardiology'),

            // Local Self Picture-in-Picture (PiP) Window
            Positioned(
              right: 16,
              top: 80,
              child: _buildLocalPipWindow(state),
            ),

            // Top Control Bar Overlay
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildTopOverlay(session?.doctorName ?? 'Doctor', state.formattedElapsedTime),
            ),

            // Bottom In-Call Controls Floating Island
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _buildBottomControls(state),
            ),

            // Clinical Consultation Notes Drawer (if open)
            if (state.isNotesDrawerOpen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 100,
                child: _buildClinicalNotesDrawer(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteParticipantView(String doctorName, String spec) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0F172A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simulated Active Speaker Video Frame
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: Center(
                child: Text(
                  doctorName.split(' ').map((e) => e[0]).take(2).join(),
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              doctorName,
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              spec,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryLight),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Speaking • High Fidelity Audio',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.successLight, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalPipWindow(TeleconsultationState state) {
    return Container(
      key: const Key('local_pip_tile'),
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (state.isVideoOff)
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 24),
                SizedBox(height: 4),
                Text('Video Off', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline_rounded, color: Colors.white70, size: 36),
                const SizedBox(height: 4),
                Text(
                  'You',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: state.isAudioMuted ? AppColors.error : Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isAudioMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay(String doctorName, String elapsedTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Elapsed Duration Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                elapsedTime,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Encryption Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: AppColors.success, size: 12),
              SizedBox(width: 4),
              Text(
                'E2EE 256-Bit',
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(TeleconsultationState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Audio Mute Toggle
          IconButton(
            key: const Key('call_mute_toggle'),
            icon: Icon(
              state.isAudioMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              color: state.isAudioMuted ? AppColors.error : Colors.white,
            ),
            onPressed: () => ref.read(teleconsultationControllerProvider.notifier).toggleAudio(),
          ),

          // Video On/Off Toggle
          IconButton(
            key: const Key('call_video_toggle'),
            icon: Icon(
              state.isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
              color: state.isVideoOff ? AppColors.error : Colors.white,
            ),
            onPressed: () => ref.read(teleconsultationControllerProvider.notifier).toggleVideo(),
          ),

          // Switch Camera
          IconButton(
            key: const Key('call_camera_switch'),
            icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
            onPressed: () => ref.read(teleconsultationControllerProvider.notifier).switchCamera(),
          ),

          // Clinical Notes Drawer
          IconButton(
            key: const Key('call_notes_toggle'),
            icon: Icon(
              Icons.note_alt_outlined,
              color: state.isNotesDrawerOpen ? AppColors.primary : Colors.white,
            ),
            onPressed: () => ref.read(teleconsultationControllerProvider.notifier).toggleNotesDrawer(),
          ),

          // End Call Button
          Container(
            decoration: const BoxDecoration(
              color: AppColors.emergency,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              key: const Key('end_call_button'),
              icon: const Icon(Icons.call_end_rounded, color: Colors.white),
              onPressed: _showEndCallConfirmation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalNotesDrawer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Clinical Notes', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => ref.read(teleconsultationControllerProvider.notifier).toggleNotesDrawer(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Patient Symptoms: Routine consultation, follow-up on medication tolerance and symptom evolution.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Physician notes and digital prescriptions will be recorded and signed after call termination.',
              style: AppTextStyles.labelSmall.copyWith(fontStyle: FontStyle.italic, color: AppColors.textSecondaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
