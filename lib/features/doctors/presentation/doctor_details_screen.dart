import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../reviews/presentation/review_controller.dart';
import '../../reviews/presentation/widgets/rating_breakdown_header.dart';
import '../../reviews/presentation/widgets/review_card.dart';
import '../../reviews/presentation/widgets/write_review_sheet.dart';
import '../domain/doctor_model.dart';
import 'doctor_controller.dart';

class DoctorDetailsScreen extends ConsumerStatefulWidget {
  final DoctorModel doctor;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
  });

  @override
  ConsumerState<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends ConsumerState<DoctorDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(doctorDirectoryControllerProvider.notifier).loadDoctorDetails(widget.doctor.id);
      ref.read(doctorReviewsControllerProvider.notifier).loadReviewsAndSummary(widget.doctor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorDirectoryControllerProvider);
    final doctor = state.selectedDoctor ?? widget.doctor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consultation Fee', style: AppTextStyles.bodySmall),
                  Text(
                    '\$${doctor.consultationFee.toStringAsFixed(0)}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  text: 'Book Consultation',
                  onPressed: () {
                    try {
                      context.push('/patient/appointments/book', extra: doctor);
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Proceeding to slot selection with ${doctor.fullName}...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Hero Card
            _buildDoctorHeroCard(doctor),
            const SizedBox(height: 20),

            // Metrics Summary Grid
            _buildMetricsRow(doctor),
            const SizedBox(height: 24),

            // About Bio
            if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
              Text('About Doctor', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text(
                doctor.bio!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Clinic Location
            Text('Clinic Location', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_rounded, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctor.clinicName, style: AppTextStyles.titleSmall),
                        if (doctor.clinicAddress != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            doctor.clinicAddress!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Practice Hours
            Text('Weekly Practice Hours', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            if (doctor.availabilities.isEmpty)
              Text(
                'Consultation schedule available upon request.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: doctor.availabilities.map((av) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            av.dayName,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${av.startTime} - ${av.endTime}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),

            // Patient Reviews & Ratings
            _buildReviewsSection(doctor),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorHeroCard(DoctorModel doctor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                doctor.fullName.split(' ').map((e) => e[0]).take(2).join(),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
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
                        doctor.fullName,
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (doctor.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    doctor.specializationName,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  doctor.qualification,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(DoctorModel doctor) {
    return Row(
      children: [
        _buildMetricItem(
          icon: Icons.workspace_premium_rounded,
          color: AppColors.primary,
          title: 'Experience',
          value: '${doctor.experienceYears}+ Yrs',
        ),
        const SizedBox(width: 12),
        _buildMetricItem(
          icon: Icons.star_rounded,
          color: AppColors.warning,
          title: 'Rating',
          value: '4.9 ★',
        ),
        const SizedBox(width: 12),
        _buildMetricItem(
          icon: Icons.verified_user_rounded,
          color: AppColors.success,
          title: 'Status',
          value: doctor.isVerified ? 'Verified' : 'Pending',
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(DoctorModel doctor) {
    final reviewsState = ref.watch(doctorReviewsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Reviews',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Verified feedback from consultations',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
            OutlinedButton.icon(
              key: const Key('write_review_button'),
              onPressed: () {
                WriteReviewSheet.show(
                  context,
                  doctorId: doctor.id,
                  doctorName: doctor.fullName,
                );
              },
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: const Text('Review'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Rating Breakdown Header
        RatingBreakdownHeader(
          summary: reviewsState.summary,
          activeFilter: reviewsState.activeRatingFilter,
          onFilterChanged: (filter) {
            ref.read(doctorReviewsControllerProvider.notifier).setFilter(filter);
          },
        ),
        const SizedBox(height: 16),

        // Reviews List
        if (reviewsState.filteredReviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    size: 36,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    reviewsState.activeRatingFilter != null
                        ? 'No ${reviewsState.activeRatingFilter}-star reviews found.'
                        : 'No reviews yet for this practitioner.',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to share your verified consultation feedback!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...reviewsState.filteredReviews.map((r) => ReviewCard(review: r)),
      ],
    );
  }
}

