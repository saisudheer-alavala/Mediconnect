import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../domain/medicine_model.dart';
import 'medicine_controller.dart';

class AddEditMedicineScreen extends ConsumerStatefulWidget {
  final MedicineModel? existingMedicine;

  const AddEditMedicineScreen({
    super.key,
    this.existingMedicine,
  });

  @override
  ConsumerState<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends ConsumerState<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;

  String _selectedFrequency = 'Twice daily';
  final List<String> _frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Every 8 hours',
    'Every 12 hours',
    'Weekly',
    'As needed (PRN)',
  ];

  late DateTime _startDate;
  DateTime? _endDate;
  bool _isOngoing = true;

  final List<TimeOfDay> _reminderTimes = [];

  @override
  void initState() {
    super.initState();
    final med = widget.existingMedicine;

    _nameController = TextEditingController(text: med?.name ?? '');
    _dosageController = TextEditingController(text: med?.dosage ?? '');
    _instructionsController = TextEditingController(text: med?.instructions ?? '');

    if (med != null && _frequencyOptions.contains(med.frequency)) {
      _selectedFrequency = med.frequency;
    } else if (med != null) {
      _selectedFrequency = _frequencyOptions.first;
    }

    _startDate = med?.startDate ?? DateTime.now();
    _endDate = med?.endDate;
    _isOngoing = med?.endDate == null;

    if (med != null && med.reminders.isNotEmpty) {
      for (final r in med.reminders) {
        final parts = r.reminderTime.split(':');
        if (parts.length == 2) {
          _reminderTimes.add(TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 8,
            minute: int.tryParse(parts[1]) ?? 0,
          ));
        }
      }
    } else {
      // Defaults for a new medicine
      _reminderTimes.add(const TimeOfDay(hour: 8, minute: 0));
      _reminderTimes.add(const TimeOfDay(hour: 20, minute: 0));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  String _to24HourString(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      final exists = _reminderTimes.any(
        (t) => t.hour == picked.hour && t.minute == picked.minute,
      );
      if (!exists) {
        setState(() {
          _reminderTimes.add(picked);
          _reminderTimes.sort(
            (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
          );
        });
      }
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
          _isOngoing = true;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 7)),
      firstDate: _startDate,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _isOngoing = false;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_reminderTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one reminder time.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final reminders24h = _reminderTimes.map(_to24HourString).toList();

    final payload = {
      'name': _nameController.text.trim(),
      'dosage': _dosageController.text.trim(),
      'frequency': _selectedFrequency,
      'instructions': _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim(),
      'startDate': _startDate.toIso8601String(),
      'endDate': _isOngoing ? null : _endDate?.toIso8601String(),
      'reminders': reminders24h,
    };

    final controller = ref.read(medicineControllerProvider.notifier);
    bool success;

    if (widget.existingMedicine != null) {
      success = await controller.updateMedicine(widget.existingMedicine!.id, payload);
    } else {
      success = await controller.createMedicine(payload);
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingMedicine != null
                ? 'Medicine updated successfully!'
                : 'Medicine added to your regimen!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMedicine != null;
    final state = ref.watch(medicineControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medication' : 'Add Medication'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medical safety banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'MediTrack is a personal adherence reminder tool. Always follow your prescribing doctor\'s precise dosage directions.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                Text('Medicine Details', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                CustomTextField(
                  labelText: 'Medicine Name',
                  hintText: 'e.g., Metformin, Atorvastatin, Lisinopril',
                  prefixIcon: Icons.medication_rounded,
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Medicine name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dosage
                CustomTextField(
                  labelText: 'Dosage',
                  hintText: 'e.g., 500mg, 1 tablet, 5ml',
                  prefixIcon: Icons.colorize_rounded,
                  controller: _dosageController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Dosage is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Frequency Dropdown
                Text('Frequency', style: AppTextStyles.labelLarge),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFrequency,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: _frequencyOptions.map((f) {
                        return DropdownMenuItem<String>(
                          value: f,
                          child: Text(f, style: AppTextStyles.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFrequency = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Instructions
                CustomTextField(
                  labelText: 'Instructions (Optional)',
                  hintText: 'e.g., Take after food with a full glass of water',
                  prefixIcon: Icons.description_outlined,
                  controller: _instructionsController,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Reminder times section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reminder Times', style: AppTextStyles.titleMedium),
                    TextButton.icon(
                      onPressed: _pickReminderTime,
                      icon: const Icon(Icons.add_alarm_rounded, size: 18),
                      label: const Text('Add Time'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _reminderTimes.map((time) {
                    return Chip(
                      avatar: const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                      label: Text(_formatTimeOfDay(time), style: AppTextStyles.labelMedium),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16),
                      onDeleted: _reminderTimes.length > 1
                          ? () {
                              setState(() => _reminderTimes.remove(time));
                            }
                          : null,
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                      side: const BorderSide(color: AppColors.primary),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Schedule Duration
                Text('Regimen Duration', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date', style: AppTextStyles.labelSmall),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_startDate),
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _isOngoing ? null : _pickEndDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: _isOngoing ? Colors.grey.shade100 : AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Date', style: AppTextStyles.labelSmall),
                              const SizedBox(height: 4),
                              Text(
                                _isOngoing
                                    ? 'Ongoing'
                                    : (_endDate != null
                                        ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                        : 'Select Date'),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _isOngoing ? Colors.grey : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _isOngoing,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _isOngoing = val ?? true;
                          if (_isOngoing) _endDate = null;
                        });
                      },
                    ),
                    Text('Ongoing long-term medication', style: AppTextStyles.bodyMedium),
                  ],
                ),
                const SizedBox(height: 32),

                // Save CTA
                CustomButton(
                  text: isEditing ? 'Save Changes' : 'Save Medication Regimen',
                  isLoading: state.isSubmitting,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
