import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../domain/health_record_model.dart';
import 'health_record_controller.dart';

class HealthRecordTimelineScreen extends ConsumerStatefulWidget {
  const HealthRecordTimelineScreen({super.key});

  @override
  ConsumerState<HealthRecordTimelineScreen> createState() =>
      _HealthRecordTimelineScreenState();
}

class _HealthRecordTimelineScreenState
    extends ConsumerState<HealthRecordTimelineScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthRecordControllerProvider);
    final records = state.filteredRecords;
    final vitals = state.vitals;

    ref.listen<HealthRecordState>(healthRecordControllerProvider, (previous, next) {
      if (next.statusNotice != null && next.statusNotice != previous?.statusNotice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.statusNotice!),
            backgroundColor: AppColors.primaryDark,
            duration: const Duration(seconds: 2),
          ),
        );
        ref.read(healthRecordControllerProvider.notifier).clearNotice();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Medical History & Records',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            tooltip: 'Upload Health Record',
            onPressed: () {
              try {
                context.push('/patient/health-records/add');
              } catch (_) {}
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          try {
            context.push('/patient/health-records/add');
          } catch (_) {}
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
        label: Text(
          'Upload Record',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Recent Vital Signs Summary Section
              _buildVitalsSection(vitals),
              const SizedBox(height: 20),

              // Search Bar
              CustomTextField(
                controller: _searchCtrl,
                hintText: 'Search records, lab tests, scans...',
                prefixIcon: Icons.search_rounded,
                onChanged: (val) {
                  ref.read(healthRecordControllerProvider.notifier).searchRecords(val);
                },
              ),
              const SizedBox(height: 14),

              // Category Filter Chips
              _buildCategoryChips(state.selectedCategory),
              const SizedBox(height: 20),

              // Timeline Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chronological Timeline',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '${records.length} ${records.length == 1 ? 'record' : 'records'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Timeline Records List
              if (records.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 48,
                        color: AppColors.textMutedLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No health records found',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload lab reports, prescriptions, or imaging scans to track your history.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(
                  records.length,
                  (index) => _buildTimelineItem(records[index], isLast: index == records.length - 1),
                ),
              const SizedBox(height: 24),

              // Informational Healthcare Disclaimer
              _buildDisclaimerCard(),
              const SizedBox(height: 60), // Room for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalsSection(List<VitalMetricModel> vitals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Vital Signs',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showLogVitalsDialog(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Log Vitals'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vitals.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final vital = vitals[index];
              return Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(vital.icon, size: 18, color: vital.statusColor),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: vital.statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            vital.status,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: vital.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: vital.value,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryLight,
                              fontSize: 18,
                            ),
                            children: [
                              TextSpan(
                                text: ' ${vital.unit}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          vital.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(HealthRecordType? selected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All Records'),
            selected: selected == null,
            onSelected: (_) {
              ref.read(healthRecordControllerProvider.notifier).filterByCategory(null);
            },
            selectedColor: AppColors.primaryLight,
            labelStyle: AppTextStyles.labelMedium.copyWith(
              color: selected == null ? AppColors.primaryDark : AppColors.textSecondaryLight,
              fontWeight: selected == null ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          ...HealthRecordType.values.map((cat) {
            final isSelected = selected == cat;
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ChoiceChip(
                avatar: Icon(cat.icon, size: 16, color: isSelected ? cat.color : AppColors.textSecondaryLight),
                label: Text(cat.label),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(healthRecordControllerProvider.notifier).filterByCategory(cat);
                },
                selectedColor: cat.color.withValues(alpha: 0.15),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? cat.color : AppColors.textSecondaryLight,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(HealthRecordModel record, {required bool isLast}) {
    final cat = record.category;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical Timeline Line & Node
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: cat.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: cat.color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.borderLight,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Record Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category pill & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 14, color: cat.color),
                            const SizedBox(width: 6),
                            Text(
                              cat.label.toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: cat.color,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        record.formattedDate,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    record.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (record.description != null && record.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      record.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Attachment Pill & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => _showDocumentPreview(context, record),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.attach_file_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                record.formattedFileSize,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• View',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz_rounded, size: 20, color: AppColors.textSecondaryLight),
                        onSelected: (action) {
                          if (action == 'view') {
                            _showDocumentPreview(context, record);
                          } else if (action == 'delete') {
                            _confirmDeleteRecord(context, record);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('View Document'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.emergency),
                                SizedBox(width: 8),
                                Text('Delete Record', style: TextStyle(color: AppColors.emergency)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: AppColors.info,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Personal health records uploaded here are strictly for timeline tracking and patient information. They do not constitute autonomous diagnostic verification. Always consult your attending physician.',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF1E3A8A),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentPreview(BuildContext context, HealthRecordModel record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(record.category.icon, color: record.category.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                record.title,
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${record.category.label}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text('Recorded: ${record.formattedDate}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text('File Size: ${record.formattedFileSize}', style: AppTextStyles.bodyMedium),
            if (record.description != null) ...[
              const SizedBox(height: 10),
              Text('Notes:', style: AppTextStyles.labelLarge),
              Text(record.description!, style: AppTextStyles.bodySmall),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, color: AppColors.emergency),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      record.fileUrl.split('/').last,
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading ${record.title}...'),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRecord(BuildContext context, HealthRecordModel record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Health Record'),
        content: Text('Are you sure you want to remove "${record.title}" from your timeline?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(healthRecordControllerProvider.notifier).deleteRecord(record.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.emergency),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLogVitalsDialog(BuildContext context) {
    final bpCtrl = TextEditingController(text: '120/80');
    final hrCtrl = TextEditingController(text: '72');
    final gluCtrl = TextEditingController(text: '95');

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
              'Log Vital Measurements',
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: bpCtrl,
              labelText: 'Blood Pressure (mmHg)',
              hintText: 'e.g. 120/80',
              prefixIcon: Icons.speed_rounded,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: hrCtrl,
              labelText: 'Heart Rate (bpm)',
              hintText: 'e.g. 72',
              prefixIcon: Icons.favorite_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: gluCtrl,
              labelText: 'Fasting Blood Glucose (mg/dL)',
              hintText: 'e.g. 95',
              prefixIcon: Icons.water_drop_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Save Vital Signs',
              onPressed: () {
                if (bpCtrl.text.isNotEmpty) {
                  ref.read(healthRecordControllerProvider.notifier).addVitalMetric(
                        label: 'Blood Pressure',
                        value: bpCtrl.text.trim(),
                        unit: 'mmHg',
                        status: 'NORMAL',
                        icon: Icons.speed_rounded,
                      );
                }
                Navigator.of(sheetCtx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
