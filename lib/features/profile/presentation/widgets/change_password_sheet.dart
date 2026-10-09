import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../profile_controller.dart';

class ChangePasswordSheet extends ConsumerStatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  ConsumerState<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(profileControllerProvider.notifier).changePassword(
          currentPassword: _currentController.text.trim(),
          newPassword: _newController.text.trim(),
        );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
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
                    'Change Password',
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
                controller: _currentController,
                labelText: 'Current Password',
                hintText: 'Enter your existing password',
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Current password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _newController,
                labelText: 'New Password',
                hintText: 'Min 8 characters, letters & numbers',
                isPassword: true,
                prefixIcon: Icons.key_rounded,
                validator: (val) {
                  if (val == null || val.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (!RegExp(r'[A-Za-z]').hasMatch(val) || !RegExp(r'[0-9]').hasMatch(val)) {
                    return 'Must contain both letters and numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _confirmController,
                labelText: 'Confirm New Password',
                hintText: 'Re-enter your new password',
                isPassword: true,
                prefixIcon: Icons.check_circle_outline_rounded,
                validator: (val) {
                  if (val != _newController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
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
                text: 'Update Password',
                isLoading: state.isUpdating,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
