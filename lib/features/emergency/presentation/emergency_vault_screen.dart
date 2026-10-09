import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/section_header.dart';
import '../domain/emergency_model.dart';
import 'emergency_controller.dart';

class EmergencyVaultScreen extends ConsumerStatefulWidget {
  const EmergencyVaultScreen({super.key});

  @override
  ConsumerState<EmergencyVaultScreen> createState() => _EmergencyVaultScreenState();
}

class _EmergencyVaultScreenState extends ConsumerState<EmergencyVaultScreen> {
  String? _expandedProtocolId = 'cpr';

  @override
  Widget build(BuildContext context) {
    final emergencyState = ref.watch(emergencyControllerProvider);
    final profile = emergencyState.profile;
    final contacts = emergencyState.contacts;
    final protocols = emergencyState.protocols;
    final primaryContact = emergencyState.primaryContact;

    ref.listen<EmergencyState>(emergencyControllerProvider, (previous, next) {
      if (next.statusNotice != null && next.statusNotice != previous?.statusNotice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.statusNotice!),
            backgroundColor: AppColors.primaryDark,
            duration: const Duration(seconds: 2),
          ),
        );
        ref.read(emergencyControllerProvider.notifier).clearNotice();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.emergencyLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: AppColors.emergency,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Emergency Health Vault',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              try {
                context.go('/patient/home');
              } catch (_) {}
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Urgent SOS Action Dispatch Card
              _buildSosDispatchCard(primaryContact),
              const SizedBox(height: 24),

              // Digital ICE Medical ID Card
              _buildMedicalIdCard(profile),
              const SizedBox(height: 24),

              // ICE Emergency Contacts List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Emergency Contacts (I.C.E.)',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddContactModal(context),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: const Text('Add Contact'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (contacts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Center(
                    child: Text(
                      'No emergency contacts added yet.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                    ),
                  ),
                )
              else
                ...contacts.map((contact) => _buildContactCard(contact)),
              const SizedBox(height: 24),

              // First Aid & Emergency Protocol Guides
              const SectionHeader(
                title: 'First Aid Emergency Protocols',
                actionText: 'Certified Guides',
              ),
              const SizedBox(height: 10),
              ...protocols.map((protocol) => _buildProtocolCard(protocol)),
              const SizedBox(height: 24),

              // Medical Disclaimer & Legal Boundary
              _buildDisclaimerBanner(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSosDispatchCard(EmergencyContactModel? primaryContact) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOS EMERGENCY DISPATCH',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Immediate One-Tap Assistance',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              // 911 / 112 Services Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmEmergencyCall('911 / 112 Emergency Dispatch', '911'),
                  icon: const Icon(Icons.emergency_rounded, size: 20),
                  label: const Text('Call 911 / 112'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.emergency,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Call Primary ICE Contact Button
              if (primaryContact != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmEmergencyCall(
                      'Primary Contact (${primaryContact.name})',
                      primaryContact.phone,
                    ),
                    icon: const Icon(Icons.contact_phone_rounded, size: 18),
                    label: Text(
                      primaryContact.name.split(' ').first,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalIdCard(MedicalIdModel profile) {
    final allergiesList = profile.allergies
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final chronicList = profile.chronicDiseases
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'DIGITAL MEDICAL ID (I.C.E.)',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _showEditMedicalIdModal(context, profile),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF38BDF8),
                    size: 18,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Name & Blood Group Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient Legal Name',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryLight,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.fullName,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.emergencyLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.emergency.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'BLOOD',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.emergency,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            profile.bloodGroup,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.emergency,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.borderLight),

                // Critical Allergies
                Text(
                  'CRITICAL ALLERGIES',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFFB91C1C),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: allergiesList.map((allergy) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.emergencyLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.emergency.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.emergency),
                          const SizedBox(width: 5),
                          Text(
                            allergy,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF991B1B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Chronic Conditions
                Text(
                  'CHRONIC CONDITIONS & IMPAIRMENTS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: chronicList.map((condition) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.health_and_safety_outlined, size: 14, color: AppColors.primaryDark),
                          const SizedBox(width: 5),
                          Text(
                            condition,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContactModel contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: contact.isPrimary
              ? const Color(0xFFF59E0B)
              : AppColors.borderLight,
          width: contact.isPrimary ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: contact.isPrimary
                  ? const Color(0xFFFEF3C7)
                  : AppColors.inputBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              contact.isPrimary ? Icons.star_rounded : Icons.person_rounded,
              color: contact.isPrimary
                  ? const Color(0xFFD97706)
                  : AppColors.textSecondaryLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        contact.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRIMARY',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFFB45309),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${contact.relationship} • ${contact.phone}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmEmergencyCall(contact.name, contact.phone),
            icon: const Icon(
              Icons.phone_forwarded_rounded,
              color: AppColors.secondary,
              size: 22,
            ),
            tooltip: 'Call ${contact.name}',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondaryLight),
            onSelected: (action) {
              if (action == 'primary') {
                ref.read(emergencyControllerProvider.notifier).setPrimaryContact(contact.id);
              } else if (action == 'delete') {
                _confirmDeleteContact(context, contact);
              }
            },
            itemBuilder: (context) => [
              if (!contact.isPrimary)
                const PopupMenuItem(
                  value: 'primary',
                  child: Row(
                    children: [
                      Icon(Icons.star_outline_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Set as Primary'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.emergency),
                    SizedBox(width: 8),
                    Text('Remove Contact', style: TextStyle(color: AppColors.emergency)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(FirstAidProtocolModel protocol) {
    final isExpanded = _expandedProtocolId == protocol.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? protocol.themeColor.withValues(alpha: 0.5) : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedProtocolId = isExpanded ? null : protocol.id;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: protocol.themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      protocol.icon,
                      color: protocol.themeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          protocol.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          protocol.subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: protocol.steps.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final step = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: protocol.themeColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$idx',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.gavel_rounded,
                size: 20,
                color: Color(0xFFB45309),
              ),
              const SizedBox(width: 8),
              Text(
                'CRITICAL EMERGENCY DISCLAIMER',
                style: AppTextStyles.labelMedium.copyWith(
                  color: const Color(0xFFB45309),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'MediCare Connect is an informational personal health vault and does NOT replace licensed emergency dispatch or professional medical judgment. In the event of an acute medical crisis, immediately dial local emergency services (911, 112, 108) or proceed to the nearest emergency hospital.',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF78350F),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmEmergencyCall(String targetName, String phoneNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: AppColors.emergency),
            const SizedBox(width: 8),
            const Text('Confirm Call'),
          ],
        ),
        content: Text(
          'Initiate phone call to $targetName at $phoneNumber?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergency,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Simulating call to $targetName ($phoneNumber)...'),
                  backgroundColor: AppColors.emergency,
                ),
              );
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteContact(BuildContext context, EmergencyContactModel contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Contact'),
        content: Text('Are you sure you want to remove ${contact.name} from your ICE contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(emergencyControllerProvider.notifier).deleteEmergencyContact(contact.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.emergency),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddContactModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final relCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    bool isPrimary = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Emergency Contact',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: nameCtrl,
                labelText: 'Contact Name',
                hintText: 'e.g. Sarah Mercer',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: relCtrl,
                labelText: 'Relationship',
                hintText: 'e.g. Spouse, Parent, Sibling',
                prefixIcon: Icons.favorite_outline_rounded,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: phoneCtrl,
                labelText: 'Phone Number',
                hintText: '+1 555-019-2834',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Set as Primary Emergency Contact',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                ),
                subtitle: Text(
                  'Primary contact appears directly on the emergency dispatch card',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                ),
                value: isPrimary,
                activeTrackColor: AppColors.primary,
                onChanged: (val) {
                  setModalState(() {
                    isPrimary = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Save Contact',
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
                    ref.read(emergencyControllerProvider.notifier).addEmergencyContact(
                          name: nameCtrl.text.trim(),
                          relationship: relCtrl.text.trim().isEmpty ? 'Contact' : relCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          isPrimary: isPrimary,
                        );
                    Navigator.of(sheetCtx).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMedicalIdModal(BuildContext context, MedicalIdModel profile) {
    final bloodCtrl = TextEditingController(text: profile.bloodGroup);
    final allergiesCtrl = TextEditingController(text: profile.allergies);
    final chronicCtrl = TextEditingController(text: profile.chronicDiseases);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Medical ID (I.C.E.)',
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: bloodCtrl,
              labelText: 'Blood Group',
              hintText: 'e.g. O+, A+, B-, AB+',
              prefixIcon: Icons.water_drop_outlined,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: allergiesCtrl,
              labelText: 'Known Allergies',
              hintText: 'e.g. Penicillin, Peanuts (comma separated)',
              prefixIcon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: chronicCtrl,
              labelText: 'Chronic Diseases & Conditions',
              hintText: 'e.g. Asthma, Hypertension, Diabetes',
              prefixIcon: Icons.medical_services_outlined,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Save Medical ID',
              onPressed: () {
                ref.read(emergencyControllerProvider.notifier).updateMedicalProfile(
                      bloodGroup: bloodCtrl.text.trim(),
                      allergies: allergiesCtrl.text.trim(),
                      chronicDiseases: chronicCtrl.text.trim(),
                    );
                Navigator.of(sheetCtx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
