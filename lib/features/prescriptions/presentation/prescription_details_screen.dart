import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../domain/prescription_model.dart';
import 'prescription_controller.dart';

class PrescriptionDetailsScreen extends ConsumerWidget {
  final PrescriptionModel prescription;

  const PrescriptionDetailsScreen({
    super.key,
    required this.prescription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Prescription'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Prescription',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prescription shared or exported as PDF.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
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
            key: const Key('import_to_meditrack_button'),
            text: 'Add to My Medicine Schedule',
            prefixIcon: Icons.sync_rounded,
            onPressed: () async {
              final count = await ref
                  .read(prescriptionControllerProvider.notifier)
                  .importPrescriptionToMediTrack(prescription);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully imported $count medication(s) to MediTrack!',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Letterhead Container
            _buildLetterheadCard(),
            const SizedBox(height: 20),

            // Patient & Consultation Meta
            _buildPatientMetaCard(),
            const SizedBox(height: 20),

            // Clinical Diagnosis
            _buildDiagnosisCard(),
            const SizedBox(height: 24),

            // Prescribed Medications Header
            Row(
              children: [
                const Icon(Icons.medication_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Prescribed Medications (${prescription.totalMedicinesCount})',
                  style: AppTextStyles.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Medications List
            ...prescription.medicines.map((med) => _buildMedicineItem(med)),
            const SizedBox(height: 16),

            // General Instructions / Doctor Notes
            if (prescription.generalInstructions != null &&
                prescription.generalInstructions!.isNotEmpty) ...[
              _buildGeneralInstructionsCard(),
              const SizedBox(height: 20),
            ],

            // Digital Signature & License Verification
            _buildSignatureBlock(),
            const SizedBox(height: 20),

            // Legal & Clinical Boundary Disclaimer
            _buildLegalDisclaimer(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterheadCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prescription.clinicName,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (prescription.clinicAddress != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        prescription.clinicAddress!,
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rx',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prescription.doctorName,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${prescription.qualification} • ${prescription.doctorSpecialization}',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Lic: ${prescription.licenseNumber}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
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

  Widget _buildPatientMetaCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PATIENT', style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 2),
              Text(
                prescription.patientName ?? 'Verified Patient',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('DATE ISSUED', style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 2),
              Text(
                prescription.formattedIssuedDate,
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Clinical Diagnosis', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            prescription.diagnosis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineItem(PrescriptionMedicineModel med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  med.medicineName,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  med.dosage,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: AppColors.secondary),
              const SizedBox(width: 4),
              Text(
                med.frequency,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                '${med.durationDays} days',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
              ),
            ],
          ),
          if (med.instructions != null && med.instructions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Instructions: ${med.instructions!}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneralInstructionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_outlined, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Text('Physician Advice & Precautions', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            prescription.generalInstructions!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureBlock() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text('Digitally Signed & Validated', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'MediCare Connect Clinical Network',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight, fontSize: 10),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              prescription.doctorName,
              style: AppTextStyles.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Clinical Notice: This digital prescription has been authorized by a licensed healthcare professional. Please present this document to a certified pharmacist for dispensing. In case of unexpected adverse reactions or medical emergencies, consult an emergency physician or dial emergency services immediately.',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondaryLight,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
