import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../domain/doctor_model.dart';
import 'doctor_controller.dart';
import 'doctor_details_screen.dart';

class DoctorSearchScreen extends ConsumerStatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  ConsumerState<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends ConsumerState<DoctorSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorDirectoryControllerProvider);
    final controller = ref.read(doctorDirectoryControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors & Specialists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.loadInitialData(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => controller.search(val),
                decoration: InputDecoration(
                  hintText: 'Search doctor, specialty, or clinic...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMutedLight),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            controller.search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            // Horizontal Specialization Pills
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSpecChip(
                    label: 'All Specialties',
                    isSelected: state.selectedSpecializationId == null,
                    onTap: () => controller.filterBySpecialization(null),
                  ),
                  ...state.specializations.map((spec) {
                    final isSelected = state.selectedSpecializationId == spec.id;
                    return _buildSpecChip(
                      label: spec.name,
                      isSelected: isSelected,
                      onTap: () => controller.filterBySpecialization(spec.id),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Results count label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.doctors.length} Doctors Available',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Doctor List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadInitialData(),
                child: state.isLoading && state.doctors.isEmpty
                    ? const Center(child: LoadingIndicator(message: 'Searching doctors directory...'))
                    : state.doctors.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: EmptyStateView(
                              icon: Icons.person_search_rounded,
                              title: 'No Doctors Found',
                              description:
                                  'Try adjusting your search keywords or switching specialty filter.',
                              actionText: 'Clear Filters',
                              onAction: () {
                                _searchController.clear();
                                controller.search('');
                                controller.filterBySpecialization(null);
                              },
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: state.doctors.length,
                            itemBuilder: (context, index) {
                              final doc = state.doctors[index];
                              return _buildDoctorCard(context, doc);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.textPrimaryLight,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DoctorDetailsScreen(doctor: doc),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Initials
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          doc.fullName.split(' ').map((e) => e[0]).take(2).join(),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                                  doc.fullName,
                                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (doc.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doc.specializationName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doc.clinicName,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: AppColors.borderLight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${doc.experienceYears}+ yrs exp',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${doc.consultationFee.toStringAsFixed(0)} / visit',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'View Profile',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
