import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_controller.dart';
import 'profile_controller.dart';
import 'widgets/change_password_sheet.dart';
import 'widgets/edit_doctor_profile_sheet.dart';
import 'widgets/edit_patient_profile_sheet.dart';
import 'widgets/medical_disclaimer_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load fresh profile asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  void _showEditProfileSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        if (user.role == UserRole.doctor) {
          return EditDoctorProfileSheet(user: user);
        }
        return EditPatientProfileSheet(user: user);
      },
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ChangePasswordSheet(),
    );
  }

  void _showMedicalDisclaimerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const MedicalDisclaimerSheet(),
    );
  }

  void _showLanguageSelector() {
    final currentLang = ref.read(profileControllerProvider).preferredLanguage;
    final languages = ['English', 'Spanish', 'French', 'Hindi', 'German'];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Select Preferred Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              final isSelected = lang == currentLang;
              return ListTile(
                title: Text(lang),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(profileControllerProvider.notifier).setLanguage(lang);
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of MediCare Connect?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _handleDeactivate() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Deactivate Account'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deactivating your account will disable all appointment bookings and regimen notifications. To proceed, please enter your password:',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                labelText: 'Account Password',
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Password is required to deactivate';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Deactivate Now'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(profileControllerProvider.notifier)
          .deactivateAccount(password: passwordController.text.trim());

      if (success && mounted) {
        await ref.read(authControllerProvider.notifier).logout();
        if (mounted) {
          context.go('/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account has been deactivated.'),
              backgroundColor: AppColors.textSecondaryLight,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final authUser = ref.watch(authControllerProvider).user;
    final user = profileState.user ?? authUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings'),
        centerTitle: false,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () => _showEditProfileSheet(user),
            ),
        ],
      ),
      body: user == null && profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(profileControllerProvider.notifier).loadProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (user != null) _buildProfileHeader(user),
                    const SizedBox(height: 16),
                    if (user != null) _buildDomainDetailsCard(user),
                    const SizedBox(height: 20),
                    _buildSettingsSection(
                      title: 'ACCOUNT DETAILS',
                      children: [
                        _buildSettingsTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Personal & Clinical Details',
                          subtitle: user?.role == UserRole.doctor
                              ? 'Manage clinic info, fee & bio'
                              : 'Manage name, phone & allergies',
                          onTap: () {
                            if (user != null) _showEditProfileSheet(user);
                          },
                        ),
                        _buildSettingsTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Security & Password',
                          subtitle: 'Change account password',
                          onTap: _showChangePasswordSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSettingsSection(
                      title: 'APP PREFERENCES',
                      children: [
                        SwitchListTile.adaptive(
                          value: profileState.notificationsEnabled,
                          activeThumbColor: AppColors.primary,
                          title: Text(
                            'Medication & Appointment Alerts',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Push reminders for regimen doses and scheduled visits',
                            style: AppTextStyles.bodySmall,
                          ),
                          secondary: Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                          onChanged: (val) {
                            ref.read(profileControllerProvider.notifier).toggleNotifications(val);
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        SwitchListTile.adaptive(
                          value: profileState.isDarkMode,
                          activeThumbColor: AppColors.primary,
                          title: Text(
                            'Dark Theme',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Switch between clean light and dark high-contrast modes',
                            style: AppTextStyles.bodySmall,
                          ),
                          secondary: Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                          onChanged: (val) {
                            ref.read(profileControllerProvider.notifier).toggleDarkMode(val);
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        SwitchListTile.adaptive(
                          value: profileState.biometricsEnabled,
                          activeThumbColor: AppColors.primary,
                          title: Text(
                            'Biometric App Lock',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Require biometric authentication to open clinical records',
                            style: AppTextStyles.bodySmall,
                          ),
                          secondary: Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                          onChanged: (val) {
                            ref.read(profileControllerProvider.notifier).toggleBiometrics(val);
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsTile(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          subtitle: profileState.preferredLanguage,
                          onTap: _showLanguageSelector,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSettingsSection(
                      title: 'CLINICAL GOVERNANCE & LEGAL',
                      children: [
                        _buildSettingsTile(
                          icon: Icons.health_and_safety_outlined,
                          title: 'Medical Boundaries & Safety Notice',
                          subtitle: 'Regimen aid boundaries & emergency disclaimers',
                          onTap: _showMedicalDisclaimerSheet,
                        ),
                        _buildSettingsTile(
                          icon: Icons.policy_outlined,
                          title: 'Privacy Policy & HIPAA Compliance',
                          subtitle: 'End-to-end data encryption & record security',
                          onTap: _showMedicalDisclaimerSheet,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'App Version',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                              ),
                              Text(
                                'v1.0.0 (Production Build)',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsSection(
                      title: 'ACCOUNT ACTIONS',
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout_rounded, color: AppColors.textSecondaryLight),
                          title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('Sign out of your active session on this device'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: _handleLogout,
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                          title: const Text(
                            'Deactivate Account',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                          subtitle: const Text('Temporarily or permanently disable this profile'),
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error),
                          onTap: _handleDeactivate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    final isDoctor = user.role == UserRole.doctor;
    final initials = user.displayName.isNotEmpty
        ? user.displayName.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: isDoctor ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.primaryLight,
            child: Text(
              initials,
              style: AppTextStyles.headlineSmall.copyWith(
                color: isDoctor ? AppColors.secondary : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDoctor && (user.doctorProfile?.isVerified ?? false)) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDoctor ? AppColors.secondaryLight : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isDoctor ? 'DOCTOR' : 'PATIENT',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDoctor ? AppColors.secondary : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (user.phone != null && user.phone!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        user.phone!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainDetailsCard(UserModel user) {
    if (user.role == UserRole.doctor) {
      final doc = user.doctorProfile;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDetailStat(
                    label: 'Qualification',
                    value: doc?.qualification ?? 'MD',
                    icon: Icons.school_outlined,
                  ),
                ),
                Expanded(
                  child: _buildDetailStat(
                    label: 'Experience',
                    value: '${doc?.experienceYears ?? 0} Years',
                    icon: Icons.history_edu_outlined,
                  ),
                ),
                Expanded(
                  child: _buildDetailStat(
                    label: 'Clinic',
                    value: doc?.clinicName ?? 'Private Clinic',
                    icon: Icons.local_hospital_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final pat = user.patientProfile;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDetailStat(
              label: 'Blood Group',
              value: pat?.bloodGroup ?? 'Not Set',
              icon: Icons.bloodtype_outlined,
              iconColor: AppColors.error,
            ),
          ),
          Expanded(
            child: _buildDetailStat(
              label: 'Known Allergies',
              value: pat?.allergies?.isNotEmpty == true ? pat!.allergies! : 'None Reported',
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warning,
            ),
          ),
          Expanded(
            child: _buildDetailStat(
              label: 'Chronic Diseases',
              value: pat?.chronicDiseases?.isNotEmpty == true ? pat!.chronicDiseases! : 'None Reported',
              icon: Icons.medical_information_outlined,
              iconColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat({
    required String label,
    required String value,
    required IconData icon,
    Color iconColor = AppColors.primary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
      onTap: onTap,
    );
  }
}
