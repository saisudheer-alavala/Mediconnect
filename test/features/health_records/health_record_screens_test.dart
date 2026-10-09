import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/health_records/data/health_record_repository.dart';
import 'package:mediconnect/features/health_records/domain/health_record_model.dart';
import 'package:mediconnect/features/health_records/presentation/add_edit_health_record_screen.dart';
import 'package:mediconnect/features/health_records/presentation/health_record_timeline_screen.dart';

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
  group('HealthRecordTimelineScreen Widget Tests', () {
    testWidgets('renders timeline screen with vitals, filter chips, search and records',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
          ],
          child: const MaterialApp(
            home: HealthRecordTimelineScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Header
      expect(find.text('Medical History & Records'), findsOneWidget);

      // Verify Vitals Bar
      expect(find.text('Recent Vital Signs'), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);

      // Verify Filter Chips & Timeline Header
      expect(find.text('All Records'), findsOneWidget);
      expect(find.text('Chronological Timeline'), findsOneWidget);

      // Verify Initial Record Items
      expect(find.text('Complete Blood Count (CBC)'), findsOneWidget);
      expect(find.text('BLOOD TEST'), findsOneWidget);
    });

    testWidgets('tapping document attachment pill opens preview modal', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
          ],
          child: const MaterialApp(
            home: HealthRecordTimelineScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final viewPill = find.text('• View').first;
      expect(viewPill, findsOneWidget);
      await tester.tap(viewPill);
      await tester.pumpAndSettle();

      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Download'), findsNothing);
    });

    testWidgets('tapping Log Vitals button opens modal bottom sheet', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
          ],
          child: const MaterialApp(
            home: HealthRecordTimelineScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final logBtn = find.text('Log Vitals');
      expect(logBtn, findsOneWidget);
      await tester.tap(logBtn);
      await tester.pumpAndSettle();

      expect(find.text('Log Vital Measurements'), findsOneWidget);
      expect(find.text('Blood Pressure (mmHg)'), findsOneWidget);
      expect(find.text('Save Vital Signs'), findsOneWidget);
    });
  });

  group('AddEditHealthRecordScreen Widget Tests', () {
    testWidgets('renders add record form and validates required title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthRecordRepositoryProvider.overrideWithValue(_FakeHealthRecordRepository()),
          ],
          child: const MaterialApp(
            home: AddEditHealthRecordScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upload Health Record'), findsOneWidget);
      expect(find.text('Record Title *'), findsOneWidget);
      expect(find.text('Record Category *'), findsOneWidget);
      expect(find.text('Attached Document / Report *'), findsOneWidget);
      final saveBtn = find.text('Save to Timeline');
      expect(saveBtn, findsOneWidget);

      // Attempt submit without title
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();
      expect(find.text('Please enter a record title'), findsOneWidget);

      // Enter title and submit
      await tester.enterText(find.byType(TextFormField).first, 'Full Body DEXA Scan');
      await tester.pumpAndSettle();
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();
    });
  });
}
