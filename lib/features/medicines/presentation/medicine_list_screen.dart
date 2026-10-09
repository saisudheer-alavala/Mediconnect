import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../domain/medicine_model.dart';
import 'medicine_controller.dart';
import 'add_edit_medicine_screen.dart';

class MedicineListScreen extends ConsumerStatefulWidget {
  const MedicineListScreen({super.key});

  @override
  ConsumerState<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends ConsumerState<MedicineListScreen> {
  int _selectedTabIndex = 0; // 0 = Active, 1 = All

  String _formatTimeStr(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      return DateFormat.jm().format(dt);
    } catch (_) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicineControllerProvider);
    final controller = ref.read(medicineControllerProvider.notifier);

    final activeMedicines = state.medicines.where((m) => m.isActive).toList();
    final displayedMedicines = _selectedTabIndex == 0 ? activeMedicines : state.medicines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediTrack — Medications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.loadInitialData(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditMedicineScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Medication',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadInitialData(),
        child: state.isLoading && state.medicines.isEmpty
            ? const Center(child: LoadingIndicator(message: 'Loading medication regimen...'))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Adherence Metric Card
                  if (state.adherenceReport != null)
                    _buildAdherenceCard(state.adherenceReport!),
                  const SizedBox(height: 20),

                  // Tab switch: Active vs All
                  Row(
                    children: [
                      _buildTabButton('Active (${activeMedicines.length})', 0),
                      const SizedBox(width: 8),
                      _buildTabButton('All (${state.medicines.length})', 1),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Medicine list or empty state
                  if (displayedMedicines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: EmptyStateView(
                        icon: Icons.medication_rounded,
                        title: _selectedTabIndex == 0 ? 'No Active Medications' : 'No Medications Found',
                        description: _selectedTabIndex == 0
                            ? 'You do not have any active medication regimens recorded.'
                            : 'Add your medications to receive timely pill reminders and track adherence.',
                        actionText: 'Add First Medication',
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AddEditMedicineScreen()),
                          );
                        },
                      ),
                    )
                  else
                    ...displayedMedicines.map((m) => _buildMedicineCard(context, m, controller)),

                  const SizedBox(height: 80), // Padding for FAB
                ],
              ),
      ),
    );
  }

  Widget _buildAdherenceCard(AdherenceReportModel report) {
    final rate = report.adherenceRatePercentage;
    final color = rate >= 80 ? AppColors.success : (rate >= 60 ? AppColors.warning : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_rounded, color: color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text('7-Day Adherence Score', style: AppTextStyles.titleMedium),
                ],
              ),
              Text(
                '${rate.toStringAsFixed(1)}%',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (rate / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${report.takenDoses} of ${report.totalDoses} doses taken',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              ),
              Text(
                '${report.skippedDoses} skipped',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(BuildContext context, MedicineModel med, MedicineController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: med.isActive ? AppColors.borderLight : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: med.isActive
                        ? AppColors.primaryLight.withValues(alpha: 0.6)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: med.isActive ? AppColors.primary : Colors.grey,
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
                              med.name,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: med.isActive ? null : TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!med.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Discontinued',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${med.dosage} • ${med.frequency}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (val) {
                    if (val == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditMedicineScreen(existingMedicine: med),
                        ),
                      );
                    } else if (val == 'discontinue') {
                      _showDiscontinueDialog(context, med, controller);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Regimen'),
                        ],
                      ),
                    ),
                    if (med.isActive)
                      const PopupMenuItem(
                        value: 'discontinue',
                        child: Row(
                          children: [
                            Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Discontinue', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (med.instructions != null && med.instructions!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        med.instructions!,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Reminders row
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: med.reminders.map((r) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimeStr(r.reminderTime),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
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
    );
  }

  void _showDiscontinueDialog(
    BuildContext context,
    MedicineModel med,
    MedicineController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discontinue Medication?'),
        content: Text(
          'Are you sure you want to discontinue "${med.name}"? Past adherence history will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.discontinueMedicine(med.id);
            },
            child: const Text('Discontinue', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
