import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'auth_controller.dart';

enum AuthRole { patient, doctor }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthRole _selectedRole = AuthRole.patient;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      if (success) {
        final authState = ref.read(authControllerProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome back, ${authState.user?.displayName ?? "User"}!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        if (authState.isDoctor || _selectedRole == AuthRole.doctor) {
          context.go('/doctor');
        } else {
          context.go('/patient');
        }
      } else {
        final error = ref.read(authControllerProvider).errorMessage ?? 'Login failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showRoleSignupBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Join MediCare Connect',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your account type to proceed with registration',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Register as Patient',
                  prefixIcon: Icons.person_outline_rounded,
                  type: CustomButtonType.primary,
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/register-patient');
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Register as Doctor',
                  prefixIcon: Icons.medical_services_outlined,
                  type: CustomButtonType.outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/register-doctor');
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          size: 38,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome to ${AppConstants.appName}',
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Access your medications, appointments & healthcare team',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    SegmentedButton<AuthRole>(
                      segments: const [
                        ButtonSegment<AuthRole>(
                          value: AuthRole.patient,
                          label: Text('Patient'),
                          icon: Icon(Icons.person_rounded),
                        ),
                        ButtonSegment<AuthRole>(
                          value: AuthRole.doctor,
                          label: Text('Doctor'),
                          icon: Icon(Icons.badge_rounded),
                        ),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedRole = newSelection.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: AppColors.primaryLight,
                        selectedForegroundColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      labelText: 'Email Address',
                      hintText: 'name@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (val) => Validators.validateRequired(val, 'Password'),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Log In',
                      isLoading: authState.isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: _showRoleSignupBottomSheet,
                          child: Text(
                            'Sign Up',
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
