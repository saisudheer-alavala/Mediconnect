import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Verified Badge, Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.7),
                child: Text(
                  review.initials,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.patientName,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 11,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Verified',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.formattedDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Star Rating Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${review.rating}.0',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Optional Review Headline
          if (review.title != null && review.title!.trim().isNotEmpty) ...[
            Text(
              review.title!,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Review Comment Text
          Text(
            review.comment,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
