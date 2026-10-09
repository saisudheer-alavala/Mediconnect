import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../domain/health_record_model.dart';
import 'health_record_controller.dart';

class AddEditHealthRecordScreen extends ConsumerStatefulWidget {
  const AddEditHealthRecordScreen({super.key});

  @override
  ConsumerState<AddEditHealthRecordScreen> createState() =>
      _AddEditHealthRecordScreenState();
}

class _AddEditHealthRecordScreenState
    extends ConsumerState<AddEditHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  HealthRecordType _selectedCategory = HealthRecordType.bloodTest;
  DateTime _recordDate = DateTime.now();
  final String _selectedFileName = 'Lab_Report_Results.pdf';
  final int _selectedFileSize = 2048500; // ~2.0 MB
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Upload Health Record',
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
                context.go('/patient/health-records');
              } catch (_) {}
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Record Title Field
                CustomTextField(
                  controller: _titleCtrl,
                  labelText: 'Record Title *',
                  hintText: 'e.g. Lipid Profile, Chest X-Ray, Echo Scan',
                  prefixIcon: Icons.badge_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a record title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Record Category Selector
                Text(
                  'Record Category *',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HealthRecordType.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      avatar: Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                      label: Text(cat.label),
                      selected: isSelected,
                      selectedColor: cat.color,
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Date Picker Tile
                Text(
                  'Date of Record *',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _recordDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _recordDate = picked;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, MMM dd, yyyy').format(_recordDate),
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondaryLight),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Simulated File Attachment Card
                Text(
                  'Attached Document / Report *',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontSize: 13,
                  ),
                ),
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
                          color: AppColors.emergencyLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: AppColors.emergency,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFileName,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'PDF Document • 2.0 MB • Ready to upload',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondaryLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Document attachment selected')),
                          );
                        },
                        icon: const Icon(Icons.sync_rounded, color: AppColors.primary),
                        tooltip: 'Change Document',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Clinical Notes / Description Field
                CustomTextField(
                  controller: _notesCtrl,
                  labelText: 'Clinical Remarks & Observations (Optional)',
                  hintText: 'e.g. Findings, laboratory values, doctor recommendations...',
                  maxLines: 4,
                  prefixIcon: Icons.notes_rounded,
                ),
                const SizedBox(height: 30),

                // Submit Button
                CustomButton(
                  text: 'Save to Timeline',
                  isLoading: _isSubmitting,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      await ref.read(healthRecordControllerProvider.notifier).createRecord(
            title: _titleCtrl.text.trim(),
            category: _selectedCategory,
            description: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
            fileUrl: 'https://storage.medicareconnect.com/records/$_selectedFileName',
            fileSize: _selectedFileSize,
            uploadedAt: _recordDate,
          );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          try {
            context.go('/patient/health-records');
          } catch (_) {}
        }
      }
    }
  }
}
