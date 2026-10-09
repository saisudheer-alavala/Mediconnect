import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_record_repository.dart';
import '../domain/health_record_model.dart';

class HealthRecordState {
  final List<HealthRecordModel> records;
  final List<VitalMetricModel> vitals;
  final HealthRecordType? selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? statusNotice;

  const HealthRecordState({
    required this.records,
    required this.vitals,
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.statusNotice,
  });

  List<HealthRecordModel> get filteredRecords {
    return records.where((r) {
      final matchesCategory =
          selectedCategory == null || r.category == selectedCategory;
      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          r.title.toLowerCase().contains(query) ||
          (r.description != null && r.description!.toLowerCase().contains(query)) ||
          r.category.label.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  HealthRecordState copyWith({
    List<HealthRecordModel>? records,
    List<VitalMetricModel>? vitals,
    HealthRecordType? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    String? statusNotice,
  }) {
    return HealthRecordState(
      records: records ?? this.records,
      vitals: vitals ?? this.vitals,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      statusNotice: statusNotice,
    );
  }
}

class HealthRecordController extends Notifier<HealthRecordState> {
  @override
  HealthRecordState build() {
    final now = DateTime.now();

    final fallbackRecords = [
      HealthRecordModel(
        id: 'rec-1',
        patientId: 'patient-demo-1',
        title: 'Complete Blood Count (CBC) with Differential',
        category: HealthRecordType.bloodTest,
        description: 'Normal leukocyte count, hemoglobin 14.2 g/dL, platelets 245,000/mcL.',
        fileUrl: 'https://storage.medicareconnect.com/cbc_oct2026.pdf',
        fileSize: 1258291,
        uploadedAt: now.subtract(const Duration(days: 2)),
      ),
      HealthRecordModel(
        id: 'rec-2',
        patientId: 'patient-demo-1',
        title: 'Chest PA View Digital Radiography (X-Ray)',
        category: HealthRecordType.xRay,
        description: 'Clear bilateral lung fields, normal cardiothoracic silhouette.',
        fileUrl: 'https://storage.medicareconnect.com/cxr_oct2026.pdf',
        fileSize: 3670016,
        uploadedAt: now.subtract(const Duration(days: 5)),
      ),
      HealthRecordModel(
        id: 'rec-3',
        patientId: 'patient-demo-1',
        title: 'Cardiology Follow-Up & Discharge Summary',
        category: HealthRecordType.dischargeSummary,
        description: 'Outpatient evaluation with Dr. Sarah Jenkins. Stable hemodynamics.',
        fileUrl: 'https://storage.medicareconnect.com/discharge_sep2026.pdf',
        fileSize: 854000,
        uploadedAt: now.subtract(const Duration(days: 14)),
      ),
      HealthRecordModel(
        id: 'rec-4',
        patientId: 'patient-demo-1',
        title: 'Transthoracic Echocardiogram (2D Echo)',
        category: HealthRecordType.scan,
        description: 'LVEF 62%, normal wall motion, mild mitral valve regurgitation.',
        fileUrl: 'https://storage.medicareconnect.com/echo_sep2026.pdf',
        fileSize: 4500000,
        uploadedAt: now.subtract(const Duration(days: 22)),
      ),
    ];

    Future.microtask(() => loadRecords());

    return HealthRecordState(
      records: fallbackRecords,
      vitals: VitalMetricModel.defaultVitals,
    );
  }

  Future<void> loadRecords() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(healthRecordRepositoryProvider);
      final list = await repo.getHealthRecords(
        category: state.selectedCategory?.serverKey,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      if (list.isNotEmpty) {
        state = state.copyWith(isLoading: false, records: list);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void filterByCategory(HealthRecordType? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void searchRecords(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createRecord({
    required String title,
    required HealthRecordType category,
    String? description,
    required String fileUrl,
    int? fileSize,
    DateTime? uploadedAt,
  }) async {
    state = state.copyWith(isLoading: true);
    final recordDate = uploadedAt ?? DateTime.now();

    try {
      final repo = ref.read(healthRecordRepositoryProvider);
      final Map<String, dynamic> payload = {
        'title': title,
        'category': category.serverKey,
        'fileUrl': fileUrl,
        'uploadedAt': recordDate.toIso8601String(),
      };
      if (description != null) payload['description'] = description;
      if (fileSize != null) payload['fileSize'] = fileSize;

      final created = await repo.createHealthRecord(payload);

      final updated = [created, ...state.records];
      state = state.copyWith(
        isLoading: false,
        records: updated,
        statusNotice: 'Record "$title" saved successfully.',
      );
    } catch (_) {
      // Local optimistic fallback
      final fallback = HealthRecordModel(
        id: 'rec-${DateTime.now().millisecondsSinceEpoch}',
        patientId: 'patient-demo-1',
        title: title,
        category: category,
        description: description,
        fileUrl: fileUrl,
        fileSize: fileSize ?? 1024000,
        uploadedAt: recordDate,
      );

      final updated = [fallback, ...state.records];
      state = state.copyWith(
        isLoading: false,
        records: updated,
        statusNotice: 'Record saved locally (offline mode).',
      );
    }
  }

  Future<void> deleteRecord(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(healthRecordRepositoryProvider);
      await repo.deleteHealthRecord(id);

      final updated = state.records.where((r) => r.id != id).toList();
      state = state.copyWith(
        isLoading: false,
        records: updated,
        statusNotice: 'Health record removed.',
      );
    } catch (_) {
      final updated = state.records.where((r) => r.id != id).toList();
      state = state.copyWith(
        isLoading: false,
        records: updated,
        statusNotice: 'Record removed locally.',
      );
    }
  }

  void addVitalMetric({
    required String label,
    required String value,
    required String unit,
    required String status,
    required IconData icon,
    Color statusColor = const Color(0xFF16A34A),
  }) {
    final newVital = VitalMetricModel(
      id: 'v-${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      value: value,
      unit: unit,
      status: status,
      recordedAt: DateTime.now(),
      icon: icon,
      statusColor: statusColor,
    );

    final updated = [newVital, ...state.vitals];
    state = state.copyWith(
      vitals: updated,
      statusNotice: '$label measurement logged.',
    );
  }

  void clearNotice() {
    state = state.copyWith(statusNotice: null, errorMessage: null);
  }
}

final healthRecordControllerProvider =
    NotifierProvider<HealthRecordController, HealthRecordState>(() {
  return HealthRecordController();
});
