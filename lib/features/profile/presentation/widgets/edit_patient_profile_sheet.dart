import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/domain/user_model.dart';
import '../profile_controller.dart';

class EditPatientProfileSheet extends ConsumerStatefulWidget {
  final UserModel user;

  const EditPatientProfileSheet({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditPatientProfileSheet> createState() => _EditPatientProfileSheetState();
}

class _EditPatientProfileSheetState extends ConsumerState<EditPatientProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _chronicController;
  String? _selectedBloodGroup;
  String? _selectedGender;
  DateTime? _selectedDob;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _genders = ['MALE', 'FEMALE', 'OTHER'];

  @override
  void initState() {
    super.initState();
    final profile = widget.user.patientProfile;
    _nameController = TextEditingController(text: profile?.fullName ?? widget.user.displayName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _allergiesController = TextEditingController(text: profile?.allergies ?? '');
    _chronicController = TextEditingController(text: profile?.chronicDiseases ?? '');
    _selectedBloodGroup = profile?.bloodGroup;
    _selectedGender = profile?.gender?.toUpperCase();
    if (profile?.dateOfBirth != null && profile!.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDob = DateTime.parse(profile.dateOfBirth!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _allergiesController.dispose();
    _chronicController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 25, 1, 1),
      firstDate: DateTime(now.year - 110),
      lastDate: now,
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(profileControllerProvider.notifier).updatePatientProfile(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          dateOfBirth: _selectedDob != null ? DateFormat('yyyy-MM-dd').format(_selectedDob!) : null,
          gender: _selectedGender,
          bloodGroup: _selectedBloodGroup,
          allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
          chronicDiseases: _chronicController.text.trim().isEmpty ? null : _chronicController.text.trim(),
        );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient profile updated successfully'),
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
                    'Edit Patient Profile',
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
                labelText: 'Full Legal Name',
                hintText: 'Enter your full name',
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
                labelText: 'Phone Number',
                hintText: '+1 (555) 000-0000',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 14),
              // Date of Birth & Gender Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDateOfBirth,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Date of Birth',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                                  ),
                                  Text(
                                    _selectedDob != null
                                        ? DateFormat('MMM d, yyyy').format(_selectedDob!)
                                        : 'Tap to select',
                                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: const Icon(Icons.people_outline_rounded, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      hint: const Text('Gender'),
                      items: _genders.map((g) {
                        return DropdownMenuItem(
                          value: g,
                          child: Text(
                            g == 'MALE' ? 'Male' : (g == 'FEMALE' ? 'Female' : 'Other'),
                            style: AppTextStyles.bodyMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedGender = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: 'Blood Group',
                  prefixIcon: const Icon(Icons.bloodtype_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                hint: const Text('Select Blood Group'),
                items: _bloodGroups.map((bg) {
                  return DropdownMenuItem(
                    value: bg,
                    child: Text(bg, style: AppTextStyles.bodyMedium),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBloodGroup = val;
                  });
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _allergiesController,
                labelText: 'Known Allergies',
                hintText: 'e.g. Penicillin, Peanuts (or None)',
                prefixIcon: Icons.warning_amber_rounded,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _chronicController,
                labelText: 'Personal Health Thoughts & Conditions',
                hintText: 'e.g. Hypertension, diet notes, morning consultations preferred...',
                maxLines: 2,
                prefixIcon: Icons.medical_information_outlined,
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
                text: 'Save Profile Changes',
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
