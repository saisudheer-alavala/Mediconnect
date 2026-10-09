import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../domain/schedule_model.dart';
import 'schedule_controller.dart';

class DoctorScheduleScreen extends ConsumerStatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  ConsumerState<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends ConsumerState<DoctorScheduleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(doctorScheduleControllerProvider.notifier).loadSchedule();
    });
  }

  Future<void> _pickTime({
    required BuildContext context,
    required String currentTime,
    required ValueChanged<String> onSelected,
  }) async {
    final parts = currentTime.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 9;
    final initialMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      onSelected('$hourStr:$minuteStr');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorScheduleControllerProvider);
    final notifier = ref.read(doctorScheduleControllerProvider.notifier);

    ref.listen<DoctorScheduleState>(doctorScheduleControllerProvider, (previous, next) {
      if (next.statusNotice != null && next.statusNotice != previous?.statusNotice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.statusNotice!),
            backgroundColor: AppColors.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
        ref.read(doctorScheduleControllerProvider.notifier).clearNotice();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Working Hours & Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              try {
                context.go('/doctor/home');
              } catch (_) {}
            }
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ElevatedButton(
            key: const Key('save_schedule_button'),
            onPressed: state.isSaving ? null : () => notifier.saveSchedule(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: state.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        state.isModified ? 'Save Schedule Changes' : 'Schedule Up to Date',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Capacity Summary Banner
            _buildCapacityBanner(state),
            const SizedBox(height: 16),

            // Clinical Safety Guardrail Notice
            _buildClinicalSafetyNotice(),
            const SizedBox(height: 20),

            // Days of the week list
            ...state.schedule.map((day) => _buildDayCard(context, day, notifier)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityBanner(DoctorScheduleState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.date_range_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.totalWeeklySlots} Consultation Slots / Week',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.activeDaysCount} active working days · ${_formatActiveDays(state.schedule)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatActiveDays(List<DoctorDayScheduleModel> list) {
    final active = list.where((d) => d.isActive).map((d) => d.shortDayName).join(', ');
    return active.isEmpty ? 'All days off' : active;
  }

  Widget _buildClinicalSafetyNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Schedule modifications update future slot generation. Already reserved and confirmed patient appointments are strictly preserved.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    DoctorDayScheduleModel day,
    DoctorScheduleController notifier,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: day.isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderLight,
          width: day.isActive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Day Name + Toggle Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: day.isActive
                          ? AppColors.primaryLight.withValues(alpha: 0.7)
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        day.shortDayName,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: day.isActive ? AppColors.primary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    day.dayName,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: day.isActive ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Switch(
                key: Key('toggle_day_${day.dayOfWeek}'),
                value: day.isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (active) => notifier.toggleDay(day.dayOfWeek, active),
              ),
            ],
          ),

          if (day.isActive) ...[
            const Divider(height: 20),

            // Shift Hours Pickers
            Text(
              'Shift Hours',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTimeChip(
                    label: 'Start',
                    time: day.startTime,
                    onTap: () {
                      _pickTime(
                        context: context,
                        currentTime: day.startTime,
                        onSelected: (newTime) =>
                            notifier.updateWorkingHours(day.dayOfWeek, newTime, day.endTime),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textSecondaryLight),
                ),
                Expanded(
                  child: _buildTimeChip(
                    label: 'End',
                    time: day.endTime,
                    onTap: () {
                      _pickTime(
                        context: context,
                        currentTime: day.endTime,
                        onSelected: (newTime) =>
                            notifier.updateWorkingHours(day.dayOfWeek, day.startTime, newTime),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Slot Duration Selector Chips
            Text(
              'Consultation Slot Duration',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [15, 30, 45, 60].map((dur) {
                final isSelected = day.slotDurationMinutes == dur;
                return ChoiceChip(
                  label: Text('$dur mins'),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  backgroundColor: AppColors.backgroundLight,
                  onSelected: (sel) {
                    if (sel) notifier.updateSlotDuration(day.dayOfWeek, dur);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Break / Lunch Interval
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Break Interval:',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (day.breakStartTime != null) {
                      notifier.updateBreak(day.dayOfWeek, null, null);
                    } else {
                      notifier.updateBreak(day.dayOfWeek, '13:00', '14:00');
                    }
                  },
                  child: Text(
                    day.breakStartTime != null
                        ? '${day.breakStartTime} - ${day.breakEndTime} (Remove)'
                        : '+ Add Lunch Break',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: day.breakStartTime != null ? AppColors.emergency : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Slot Generation Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    '${day.calculatedSlotCount} slots created for this day',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Day Off · Clinic Closed',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeChip({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 9,
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
