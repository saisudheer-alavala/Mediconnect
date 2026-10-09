import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'auth_controller.dart';

class PatientRegisterScreen extends ConsumerStatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  ConsumerState<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends ConsumerState<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedGender = 'Male';
  DateTime? _selectedDateOfBirth;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _selectedDateOfBirth ?? DateTime(now.year - 25, 1, 1);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authControllerProvider.notifier).registerPatient(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
            dateOfBirth: _dobController.text.isNotEmpty ? _dobController.text : null,
            gender: _selectedGender,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient account created successfully!'),
            backgroundColor: AppColors.success,
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
        title: const Text('Patient Registration'),
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
                      'Create Patient Profile',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your medications, consult doctors, and store health records securely.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      labelText: 'Full Name',
                      hintText: 'John Doe',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) => Validators.validateRequired(val, 'Full name'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Email Address',
                      hintText: 'john@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Phone Number',
                      hintText: '+1 234 567 8900',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Date of Birth',
                      hintText: 'YYYY-MM-DD',
                      controller: _dobController,
                      readOnly: true,
                      onTap: _pickDateOfBirth,
                      prefixIcon: Icons.calendar_today_outlined,
                      suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                      validator: (val) => Validators.validateRequired(val, 'Date of birth'),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gender',
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
                              value: _selectedGender,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'Male', child: Text('Male')),
                                DropdownMenuItem(value: 'Female', child: Text('Female')),
                                DropdownMenuItem(value: 'Other', child: Text('Other')),
                              ],
                              onChanged: (newVal) {
                                if (newVal != null) {
                                  setState(() => _selectedGender = newVal);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryLight),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your health information is stored securely and is only accessible by you and doctors you choose to consult.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryDark,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Create Patient Account',
                      isLoading: authState.isLoading,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
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
