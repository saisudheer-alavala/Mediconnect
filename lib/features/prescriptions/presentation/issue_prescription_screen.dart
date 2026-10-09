import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'prescription_controller.dart';

class _MedicineFormItem {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController dosageCtrl = TextEditingController();
  final TextEditingController frequencyCtrl = TextEditingController();
  final TextEditingController durationCtrl = TextEditingController(text: '7');
  final TextEditingController instructionsCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    dosageCtrl.dispose();
    frequencyCtrl.dispose();
    durationCtrl.dispose();
    instructionsCtrl.dispose();
  }
}

class IssuePrescriptionScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String? patientName;
  final String? appointmentId;

  const IssuePrescriptionScreen({
    super.key,
    required this.patientId,
    this.patientName,
    this.appointmentId,
  });

  @override
  ConsumerState<IssuePrescriptionScreen> createState() => _IssuePrescriptionScreenState();
}

class _IssuePrescriptionScreenState extends ConsumerState<IssuePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _generalInstructionsController = TextEditingController();
  final List<_MedicineFormItem> _medicines = [];

  @override
  void initState() {
    super.initState();
    // Add default initial medicine row
    _addMedicineRow();
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _generalInstructionsController.dispose();
    for (final m in _medicines) {
      m.dispose();
    }
    super.dispose();
  }

  void _addMedicineRow() {
    setState(() {
      _medicines.add(_MedicineFormItem());
    });
  }

  void _removeMedicineRow(int index) {
    if (_medicines.length > 1) {
      setState(() {
        final removed = _medicines.removeAt(index);
        removed.dispose();
      });
    }
  }

  Future<void> _submitPrescription() async {
    if (!_formKey.currentState!.validate()) return;

    final medicinePayloads = _medicines.map((m) {
      return {
        'medicineName': m.nameCtrl.text.trim(),
        'dosage': m.dosageCtrl.text.trim(),
        'frequency': m.frequencyCtrl.text.trim(),
        'durationDays': int.tryParse(m.durationCtrl.text.trim()) ?? 7,
        if (m.instructionsCtrl.text.trim().isNotEmpty) 'instructions': m.instructionsCtrl.text.trim(),
      };
    }).toList();

    final payload = {
      'patientId': widget.patientId,
      if (widget.appointmentId != null) 'appointmentId': widget.appointmentId,
      'diagnosis': _diagnosisController.text.trim(),
      if (_generalInstructionsController.text.trim().isNotEmpty)
        'generalInstructions': _generalInstructionsController.text.trim(),
      'medicines': medicinePayloads,
    };

    final success = await ref
        .read(prescriptionControllerProvider.notifier)
        .issuePrescription(payload);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription issued successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      final error = ref.read(prescriptionControllerProvider).errorMessage ?? 'Failed to issue prescription';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prescriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Digital Prescription'),
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
            key: const Key('submit_prescription_button'),
            text: 'Sign & Issue Prescription',
            prefixIcon: Icons.check_circle_outline_rounded,
            isLoading: state.isIssuing,
            onPressed: _submitPrescription,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Banner
              _buildPatientHeader(),
              const SizedBox(height: 20),

              // Clinical Diagnosis
              CustomTextField(
                key: const Key('prescription_diagnosis_input'),
                controller: _diagnosisController,
                labelText: 'Clinical Diagnosis *',
                hintText: 'e.g., Acute Pharyngitis, Hypertension Stage 1',
                prefixIcon: Icons.assignment_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Diagnosis is required';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Medicines List Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Prescribed Medications', style: AppTextStyles.titleMedium),
                  TextButton.icon(
                    key: const Key('add_medicine_row_button'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Drug'),
                    onPressed: _addMedicineRow,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...List.generate(_medicines.length, (index) {
                return _buildMedicineFormCard(index);
              }),
              const SizedBox(height: 20),

              // General Instructions
              CustomTextField(
                key: const Key('prescription_instructions_input'),
                controller: _generalInstructionsController,
                labelText: 'General Advice & Precautions (Optional)',
                hintText: 'Dietary advice, rest guidelines, red-flag symptoms...',
                maxLines: 3,
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 24),

              // Regulatory & Clinical Notice
              _buildClinicalNotice(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Consultation Patient', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
                Text(
                  widget.patientName ?? 'Verified Patient',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineFormCard(int index) {
    final item = _medicines[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medication #${index + 1}',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
              if (_medicines.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  onPressed: () => _removeMedicineRow(index),
                ),
            ],
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: item.nameCtrl,
            labelText: 'Drug Name *',
            hintText: 'e.g., Amoxicillin',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: item.dosageCtrl,
                  labelText: 'Dosage *',
                  hintText: 'e.g., 500mg',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: item.durationCtrl,
                  labelText: 'Days *',
                  hintText: 'e.g., 7',
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || int.tryParse(v) == null) ? 'Invalid' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: item.frequencyCtrl,
            labelText: 'Frequency *',
            hintText: 'e.g., Twice daily after meals',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: item.instructionsCtrl,
            labelText: 'Special Instructions',
            hintText: 'e.g., Take with full glass of water',
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalNotice() {
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
          const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Practitioner Notice: As a licensed healthcare provider, please review contraindications and clinical dosing guidelines before issuing this digital prescription.',
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
}
