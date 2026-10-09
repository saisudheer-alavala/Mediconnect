import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/health_records/data/health_record_repository.dart';
import 'package:mediconnect/features/health_records/domain/health_record_model.dart';
import 'package:mediconnect/features/health_records/presentation/health_record_controller.dart';

class _FakeHealthRecordRepository extends HealthRecordRepository {
  _FakeHealthRecordRepository() : super(client: ApiClient(storage: SecureStorageService()));

  final List<HealthRecordModel> _records = [
    HealthRecordModel(
      id: 'rec-test-1',
      patientId: 'patient-test-id',
      title: 'Complete Blood Count (CBC)',
      category: HealthRecordType.bloodTest,
      description: 'Hemoglobin 14.5 g/dL, normal platelet count.',
      fileUrl: 'https://storage.medicareconnect.com/records/cbc_test.pdf',
      fileSize: 1048576,
      uploadedAt: DateTime(2026, 10, 8),
    ),
    HealthRecordModel(
      id: 'rec-test-2',
      patientId: 'patient-test-id',
      title: 'Chest Radiography X-Ray',
      category: HealthRecordType.xRay,
      description: 'Normal findings.',
      fileUrl: 'https://storage.medicareconnect.com/records/cxr_test.pdf',
      fileSize: 2097152,
      uploadedAt: DateTime(2026, 10, 7),
    ),
  ];

  @override
  Future<List<HealthRecordModel>> getHealthRecords({String? category, String? search}) async {
    return List.from(_records);
  }

  @override
  Future<HealthRecordModel> createHealthRecord(Map<String, dynamic> payload) async {
    final record = HealthRecordModel(
      id: 'rec-test-${_records.length + 1}',
      patientId: 'patient-test-id',
      title: payload['title'] as String,
      category: HealthRecordType.fromServer(payload['category'] as String?),
      description: payload['description'] as String?,
      fileUrl: payload['fileUrl'] as String,
      fileSize: payload['fileSize'] as int?,
      uploadedAt: payload['uploadedAt'] != null
          ? DateTime.parse(payload['uploadedAt'] as String)
          : DateTime.now(),
    );
    _records.insert(0, record);
    return record;
  }

  @override
  Future<void> deleteHealthRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
  }
}

void main() {
  group('HealthRecordDomainModel Unit Tests', () {
    test('HealthRecordModel serialization, copyWith, and helpers', () {
      final now = DateTime(2026, 10, 8);
      final record = HealthRecordModel(
        id: 'rec-101',
        patientId: 'p-1',
        title: 'Lipid Profile',
        category: HealthRecordType.bloodTest,
        description: 'Total cholesterol: 180 mg/dL',
        fileUrl: 'https://example.com/lipid.pdf',
        fileSize: 512000,
        uploadedAt: now,
      );

      final json = record.toJson();
      expect(json['id'], 'rec-101');
      expect(json['category'], 'BLOOD_TEST');
      expect(json['title'], 'Lipid Profile');

      final parsed = HealthRecordModel.fromJson(json);
      expect(parsed.id, 'rec-101');
      expect(parsed.category, HealthRecordType.bloodTest);
      expect(parsed.formattedFileSize, '500.0 KB');
      expect(parsed.formattedDate, contains('2026'));

      final updated = parsed.copyWith(title: 'Updated Lipid Profile');
      expect(updated.title, 'Updated Lipid Profile');
      expect(updated.category, HealthRecordType.bloodTest);
    });

    test('HealthRecordType server key mapping fallback', () {
      expect(HealthRecordType.fromServer('BLOOD_TEST'), HealthRecordType.bloodTest);
      expect(HealthRecordType.fromServer('X_RAY'), HealthRecordType.xRay);
      expect(HealthRecordType.fromServer('SCAN'), HealthRecordType.scan);
      expect(HealthRecordType.fromServer('DISCHARGE_SUMMARY'), HealthRecordType.dischargeSummary);
      expect(HealthRecordType.fromServer('PRESCRIPTION'), HealthRecordType.prescription);
      expect(HealthRecordType.fromServer('UNKNOWN_CATEGORY'), HealthRecordType.other);
      expect(HealthRecordType.fromServer(null), HealthRecordType.other);
    });

    test('VitalMetricModel defaults and formatting', () {
      final vitals = VitalMetricModel.defaultVitals;
      expect(vitals.length, 4);
      final bp = vitals.first;
      expect(bp.label, 'Blood Pressure');
      expect(bp.unit, 'mmHg');
      expect(bp.status, 'NORMAL');
      expect(bp.formattedDate.isNotEmpty, true);
    });
  });

  group('HealthRecordController State Management Tests', () {
    test('initializes with fallback records and vitals', () {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
        ],
      );

      final state = container.read(healthRecordControllerProvider);
      expect(state.records.isNotEmpty, true);
      expect(state.vitals.isNotEmpty, true);
      expect(state.filteredRecords.length, state.records.length);
      expect(state.selectedCategory, isNull);
    });

    test('filterByCategory narrows filteredRecords', () async {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
        ],
      );

      final notifier = container.read(healthRecordControllerProvider.notifier);
      await notifier.loadRecords();

      notifier.filterByCategory(HealthRecordType.bloodTest);
      final state = container.read(healthRecordControllerProvider);
      expect(state.selectedCategory, HealthRecordType.bloodTest);
      expect(
        state.filteredRecords.every((r) => r.category == HealthRecordType.bloodTest),
        true,
      );

      // Clearing filter
      notifier.filterByCategory(null);
      final cleared = container.read(healthRecordControllerProvider);
      expect(cleared.selectedCategory, isNull);
    });

    test('searchRecords matches title and description', () async {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
        ],
      );

      final notifier = container.read(healthRecordControllerProvider.notifier);
      await notifier.loadRecords();

      notifier.searchRecords('Radiography');
      final searchResult = container.read(healthRecordControllerProvider).filteredRecords;
      expect(searchResult.any((r) => r.title.contains('Radiography')), true);

      // Non-matching query
      notifier.searchRecords('non-existent-medical-keyword-999');
      final emptyResult = container.read(healthRecordControllerProvider).filteredRecords;
      expect(emptyResult.isEmpty, true);
    });

    test('createRecord adds record to top of list', () async {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
        ],
      );

      final notifier = container.read(healthRecordControllerProvider.notifier);
      await notifier.loadRecords();
      final initialCount = container.read(healthRecordControllerProvider).records.length;

      await notifier.createRecord(
        title: 'MRI Lumbar Spine',
        category: HealthRecordType.scan,
        description: 'L4-L5 disc protrusion without nerve root compression.',
        fileUrl: 'https://storage.medicareconnect.com/records/mri_spine.pdf',
        fileSize: 4194304,
      );

      final updatedState = container.read(healthRecordControllerProvider);
      expect(updatedState.records.length, initialCount + 1);
      expect(updatedState.records.first.title, 'MRI Lumbar Spine');
      expect(updatedState.records.first.category, HealthRecordType.scan);
    });

    test('deleteRecord removes record from state', () async {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
        ],
      );

      final notifier = container.read(healthRecordControllerProvider.notifier);
      await notifier.loadRecords();
      final target = container.read(healthRecordControllerProvider).records.first;

      await notifier.deleteRecord(target.id);
      final updatedState = container.read(healthRecordControllerProvider);
      expect(updatedState.records.any((r) => r.id == target.id), false);
    });

    test('addVitalMetric inserts new vital sign reading', () {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
        ],
      );

      final notifier = container.read(healthRecordControllerProvider.notifier);
      final initialVitalsCount = container.read(healthRecordControllerProvider).vitals.length;

      notifier.addVitalMetric(
        label: 'Body Temperature',
        value: '98.4',
        unit: '°F',
        status: 'NORMAL',
        icon: Icons.thermostat_rounded,
      );

      final updatedState = container.read(healthRecordControllerProvider);
      expect(updatedState.vitals.length, initialVitalsCount + 1);
      expect(updatedState.vitals.first.label, 'Body Temperature');
    });
  });
}
