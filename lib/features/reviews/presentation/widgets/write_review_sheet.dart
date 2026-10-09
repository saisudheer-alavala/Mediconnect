import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../review_controller.dart';

class WriteReviewSheet extends ConsumerStatefulWidget {
  final String doctorId;
  final String doctorName;
  final String? appointmentId;

  const WriteReviewSheet({
    super.key,
    required this.doctorId,
    required this.doctorName,
    this.appointmentId,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String doctorId,
    required String doctorName,
    String? appointmentId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WriteReviewSheet(
        doctorId: doctorId,
        doctorName: doctorName,
        appointmentId: appointmentId,
      ),
    );
  }

  @override
  ConsumerState<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<WriteReviewSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _commentController;

  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _ratingLabel(int stars) {
    return switch (stars) {
      5 => '5 - Exceptional Care',
      4 => '4 - Very Good Experience',
      3 => '3 - Satisfactory Consultation',
      2 => '2 - Fair / Room for Improvement',
      1 => '1 - Unsatisfactory Visit',
      _ => '$stars Stars',
    };
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(doctorReviewsControllerProvider.notifier)
        .submitReview(
          doctorId: widget.doctorId,
          rating: _selectedRating,
          title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
          comment: _commentController.text.trim(),
          appointmentId: widget.appointmentId,
        );

    if (mounted && success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorReviewsControllerProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom Sheet Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Write a Review',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Share your experience with ${widget.doctorName}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondaryLight),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Healthcare Boundary Alert
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verified patient reviews help others find appropriate care. Reviews describe bedside care and consultation satisfaction.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Interactive Star Selector
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        final isFilled = star <= _selectedRating;
                        return InkWell(
                          key: Key('star_rating_$star'),
                          onTap: () {
                            setState(() {
                              _selectedRating = star;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _ratingLabel(_selectedRating),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Headline / Title Field (Optional)
              Text(
                'Review Headline (Optional)',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('review_title_field'),
                controller: _titleController,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'e.g. Excellent explanation of treatment plan',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 14),

              // Feedback / Comment Field (Required)
              Text(
                'Detailed Experience Feedback',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('review_comment_field'),
                controller: _commentController,
                maxLines: 4,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText:
                      'How was the doctor’s listening, punctuality, and medical explanations? (Minimum 5 characters)',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your feedback.';
                  }
                  if (value.trim().length < 5) {
                    return 'Feedback must be at least 5 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              if (state.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.emergency.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.emergency,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // Submit Button
              ElevatedButton(
                key: const Key('submit_review_button'),
                onPressed: state.isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Verified Review',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
