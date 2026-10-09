import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

class MedicalDisclaimerSheet extends StatelessWidget {
  const MedicalDisclaimerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMutedLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Healthcare Boundaries & Legal',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'MediCare Connect Clinical Notice',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.info,
              title: '1. Regimen Coordination Aid Only',
              content:
                  'MediCare Connect is designed exclusively as an informational coordination and medication adherence tracking aid. It facilitates patient-doctor appointment scheduling, regimen logging, and communication.',
            ),
            const SizedBox(height: 14),
            _buildSection(
              icon: Icons.medical_services_outlined,
              iconColor: AppColors.warning,
              title: '2. No Autonomous Diagnostic Authority',
              content:
                  'This platform does not generate autonomous medical diagnoses or alter prescribed treatment regimens without licensed physician authorization. Never ignore or delay professional medical advice based on app notifications.',
            ),
            const SizedBox(height: 14),
            _buildSection(
              icon: Icons.emergency_outlined,
              iconColor: AppColors.error,
              title: '3. Life-Threatening Emergencies',
              content:
                  'MediCare Connect is NOT an emergency dispatch or 911/112 response center. If you or someone you know is experiencing severe chest pain, shortness of breath, sudden weakness, or trauma, immediately dial emergency services (911/112) or proceed to the nearest hospital emergency room.',
            ),
            const SizedBox(height: 14),
            _buildSection(
              icon: Icons.lock_outline_rounded,
              iconColor: AppColors.success,
              title: '4. Privacy & HIPAA Compliance',
              content:
                  'Health records, prescriptions, and emergency profile vaults are encrypted in transit and at rest. Access is strictly constrained by role-based access controls (RBAC) and explicit patient authorization.',
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'I Understand & Acknowledge',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
