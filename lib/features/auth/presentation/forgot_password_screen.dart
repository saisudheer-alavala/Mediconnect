import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _emailSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
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
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Forgot Your Password?',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the email address associated with your account and we will send you secure reset instructions.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          CustomTextField(
            labelText: 'Email Address',
            hintText: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Send Reset Instructions',
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Back to Log In',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 36,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Check Your Email',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We have sent password recovery instructions to:\n${_emailController.text}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        CustomButton(
          text: 'Return to Log In',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
