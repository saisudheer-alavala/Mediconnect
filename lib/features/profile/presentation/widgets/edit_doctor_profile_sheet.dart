import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/domain/user_model.dart';
import '../profile_controller.dart';

class EditDoctorProfileSheet extends ConsumerStatefulWidget {
  final UserModel user;

  const EditDoctorProfileSheet({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditDoctorProfileSheet> createState() => _EditDoctorProfileSheetState();
}

class _EditDoctorProfileSheetState extends ConsumerState<EditDoctorProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _experienceController;
  late final TextEditingController _clinicNameController;
  late final TextEditingController _clinicAddressController;
  late final TextEditingController _feeController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final profile = widget.user.doctorProfile;
    _nameController = TextEditingController(text: profile?.fullName ?? widget.user.displayName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _qualificationController = TextEditingController(text: profile?.qualification ?? '');
    _experienceController = TextEditingController(
      text: profile?.experienceYears != null ? '${profile!.experienceYears}' : '',
    );
    _clinicNameController = TextEditingController(text: profile?.clinicName ?? '');
    _clinicAddressController = TextEditingController(text: profile?.clinicAddress ?? '');
    _feeController = TextEditingController(
      text: profile?.consultationFee != null ? profile!.consultationFee!.toStringAsFixed(0) : '75',
    );
    _bioController = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _feeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final expYears = int.tryParse(_experienceController.text.trim()) ?? 0;
    final fee = double.tryParse(_feeController.text.trim()) ?? 0.0;

    final success = await ref.read(profileControllerProvider.notifier).updateDoctorProfile(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          qualification: _qualificationController.text.trim(),
          experienceYears: expYears,
          clinicName: _clinicNameController.text.trim(),
          clinicAddress: _clinicAddressController.text.trim().isEmpty ? null : _clinicAddressController.text.trim(),
          consultationFee: fee,
          bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Doctor Profile',
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                labelText: 'Full Professional Name',
                hintText: 'e.g. Dr. Jane Smith',
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().length < 2) {
                    return 'Full name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Direct Phone / Office Line',
                hintText: '+1 (555) 000-0000',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _qualificationController,
                labelText: 'Medical Credentials & Degrees',
                hintText: 'e.g. MBBS, MD (Cardiology), FACC',
                prefixIcon: Icons.school_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Qualification is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _experienceController,
                      labelText: 'Experience (Years)',
                      hintText: 'e.g. 10',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.history_edu_outlined,
                      validator: (val) {
                        if (val == null || int.tryParse(val.trim()) == null) {
                          return 'Enter valid years';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _feeController,
                      labelText: 'Fee (\$ USD)',
                      hintText: 'e.g. 75.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _clinicNameController,
                labelText: 'Hospital or Clinic Name',
                hintText: 'e.g. St. Jude Healthcare Center',
                prefixIcon: Icons.local_hospital_outlined,
                validator: (val) {
                  if (val == null || val.trim().length < 2) {
                    return 'Clinic name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _clinicAddressController,
                labelText: 'Clinic Physical Address',
                hintText: 'Street address, Suite, City',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _bioController,
                labelText: 'Professional Bio & Specialties',
                hintText: 'Brief summary of clinical background...',
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Professional Profile',
                isLoading: state.isUpdating,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
