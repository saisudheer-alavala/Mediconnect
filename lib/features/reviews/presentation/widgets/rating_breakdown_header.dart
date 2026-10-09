import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/review_model.dart';

class RatingBreakdownHeader extends StatelessWidget {
  final RatingSummaryModel summary;
  final int? activeFilter;
  final ValueChanged<int?> onFilterChanged;

  const RatingBreakdownHeader({
    super.key,
    required this.summary,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final total = summary.totalReviews;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Column: Big Average Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    summary.averageRating > 0
                        ? summary.averageRating.toStringAsFixed(1)
                        : '0.0',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                      fontSize: 40,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return Icon(
                        starVal <= summary.averageRating.round()
                            ? Icons.star_rounded
                            : (starVal - 0.5 <= summary.averageRating
                                ? Icons.star_half_rounded
                                : Icons.star_outline_rounded),
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$total ${total == 1 ? 'review' : 'reviews'}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Vertical Divider
              Container(
                height: 90,
                width: 1,
                color: AppColors.borderLight,
              ),
              const SizedBox(width: 20),

              // Right Column: Star Breakdown Bars
              Expanded(
                child: Column(
                  children: [
                    _buildBreakdownRow(5, summary.ratingBreakdown.stars5, total),
                    const SizedBox(height: 4),
                    _buildBreakdownRow(4, summary.ratingBreakdown.stars4, total),
                    const SizedBox(height: 4),
                    _buildBreakdownRow(3, summary.ratingBreakdown.stars3, total),
                    const SizedBox(height: 4),
                    _buildBreakdownRow(2, summary.ratingBreakdown.stars2, total),
                    const SizedBox(height: 4),
                    _buildBreakdownRow(1, summary.ratingBreakdown.stars1, total),
                  ],
                ),
              ),
            ],
          ),

          if (activeFilter != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Filtering by $activeFilter-star reviews',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => onFilterChanged(null),
                  child: Text(
                    'Clear filter',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.emergency,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(int star, int count, int total) {
    final double pct = total > 0 ? (count / total) : 0.0;
    final isSelected = activeFilter == star;

    return InkWell(
      onTap: () {
        if (isSelected) {
          onFilterChanged(null);
        } else {
          onFilterChanged(star);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Row(
          children: [
            Text(
              '$star★',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: AppColors.backgroundLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSelected ? AppColors.primary : Colors.amber,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 20,
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
