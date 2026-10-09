import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../domain/prescription_model.dart';
import 'prescription_controller.dart';

class PrescriptionListScreen extends ConsumerStatefulWidget {
  const PrescriptionListScreen({super.key});

  @override
  ConsumerState<PrescriptionListScreen> createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends ConsumerState<PrescriptionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(prescriptionControllerProvider.notifier).loadPrescriptions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prescriptionControllerProvider);

    final filtered = state.prescriptions.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.doctorName.toLowerCase().contains(q) ||
          p.diagnosis.toLowerCase().contains(q) ||
          p.doctorSpecialization.toLowerCase().contains(q) ||
          p.medicines.any((m) => m.medicineName.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Digital Prescriptions'),
      ),
      body: Column(
        children: [
          // Healthcare Boundary Notice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.infoLight.withValues(alpha: 0.4),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Informational Vault: Digital prescriptions are authorized clinical records. Fulfill via licensed pharmacists.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search prescription, diagnosis or doctor...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondaryLight),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Prescriptions List
          Expanded(
            child: state.isLoading && state.prescriptions.isEmpty
                ? const Center(child: LoadingIndicator(message: 'Loading prescriptions...'))
                : filtered.isEmpty
                    ? EmptyStateView(
                        icon: Icons.receipt_long_rounded,
                        title: _searchQuery.isNotEmpty ? 'No Matching Prescriptions' : 'No Digital Prescriptions',
                        description: _searchQuery.isNotEmpty
                            ? 'No prescriptions found matching "$_searchQuery".'
                            : 'When a doctor issues a digital prescription during a consultation, it will appear here.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(prescriptionControllerProvider.notifier).loadPrescriptions(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final rx = filtered[index];
                            return _buildPrescriptionCard(rx);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionModel rx) {
    return GestureDetector(
      key: Key('prescription_card_${rx.id}'),
      onTap: () {
        context.push('/patient/prescriptions/${rx.id}', extra: rx);
      },
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Doctor Info + Rx badge
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Rx',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rx.doctorName, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          rx.doctorSpecialization,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Diagnosis
              Row(
                children: [
                  const Icon(Icons.assignment_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rx.diagnosis,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Footer Meta: Date & Medication Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rx.formattedIssuedDate,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${rx.totalMedicinesCount} Medications',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
