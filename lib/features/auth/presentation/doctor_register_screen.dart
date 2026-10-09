import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'auth_controller.dart';

class DoctorRegisterScreen extends ConsumerStatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  ConsumerState<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends ConsumerState<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _clinicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedSpecialization = 'General Physician';

  final List<String> _specializations = const [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Orthopedic Surgeon',
    'Psychiatrist',
    'Gynecologist',
    'Ophthalmologist',
    'ENT Specialist',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _clinicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authControllerProvider.notifier).registerDoctor(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            specializationName: _selectedSpecialization,
            qualification: _qualificationController.text.trim(),
            licenseNumber: _licenseController.text.trim(),
            experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
            clinicName: _clinicController.text.trim(),
            phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Doctor registration submitted! Credentials will be verified by administration.',
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(authControllerProvider).errorMessage ?? 'Registration failed.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join Healthcare Provider Network',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your appointments, patient consultations, and digital prescriptions.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            size: 20,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Verification Notice: Doctor accounts require credential and license verification by our clinical administration before patient bookings become active.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF92400E),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      labelText: 'Full Name (e.g. Dr. Sarah Jenkins)',
                      hintText: 'Dr. Jane Smith',
                      controller: _nameController,
                      prefixIcon: Icons.badge_outlined,
                      validator: (val) => Validators.validateRequired(val, 'Doctor name'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Professional Email Address',
                      hintText: 'dr.jane@clinic.org',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Contact Phone Number',
                      hintText: '+1 234 567 8900',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primary Medical Specialization',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 13,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSpecialization,
                              isExpanded: true,
                              items: _specializations.map((spec) {
                                return DropdownMenuItem(value: spec, child: Text(spec));
                              }).toList(),
                              onChanged: (newVal) {
                                if (newVal != null) {
                                  setState(() => _selectedSpecialization = newVal);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Highest Medical Qualification',
                      hintText: 'e.g. MBBS, MD (Cardiology)',
                      controller: _qualificationController,
                      prefixIcon: Icons.school_outlined,
                      validator: (val) => Validators.validateRequired(val, 'Qualification'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Medical License / Registration ID',
                      hintText: 'e.g. MED-884920-REG',
                      controller: _licenseController,
                      prefixIcon: Icons.assignment_outlined,
                      validator: (val) => Validators.validateRequired(val, 'License number'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Clinical Experience (in Years)',
                      hintText: 'e.g. 8',
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.timeline_rounded,
                      validator: (val) => Validators.validatePositiveInteger(val, 'Experience'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Affiliated Clinic / Hospital',
                      hintText: 'e.g. City Care Medical Center',
                      controller: _clinicController,
                      prefixIcon: Icons.local_hospital_outlined,
                      validator: (val) => Validators.validateRequired(val, 'Clinic or hospital'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Password',
                      hintText: 'Minimum 8 characters with letters & numbers',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_reset_rounded,
                      validator: (val) => Validators.validateConfirmPassword(
                        val,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit Doctor Registration',
                      type: CustomButtonType.secondary,
                      isLoading: authState.isLoading,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already registered?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Log In',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
