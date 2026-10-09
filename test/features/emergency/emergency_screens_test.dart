import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/emergency/data/emergency_repository.dart';
import 'package:mediconnect/features/emergency/domain/emergency_model.dart';
import 'package:mediconnect/features/emergency/presentation/emergency_vault_screen.dart';

class _FakeEmergencyRepository extends EmergencyRepository {
  _FakeEmergencyRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<MedicalIdModel> getEmergencyProfile() async {
    return const MedicalIdModel(
      id: 'patient-test-id',
      fullName: 'John Doe',
      bloodGroup: 'O+',
      allergies: 'Penicillin, Peanuts',
      chronicDiseases: 'Mild Asthma',
      emergencyContacts: [
        EmergencyContactModel(
          id: 'contact-test-1',
          name: 'Sarah Mercer',
          relationship: 'Spouse',
          phone: '+1 555-019-2834',
          isPrimary: true,
        ),
      ],
    );
  }

  @override
  Future<List<EmergencyContactModel>> getContacts() async {
    return const [
      EmergencyContactModel(
        id: 'contact-test-1',
        name: 'Sarah Mercer',
        relationship: 'Spouse',
        phone: '+1 555-019-2834',
        isPrimary: true,
      ),
    ];
  }
}

void main() {
  group('EmergencyVaultScreen Widget Tests', () {
    testWidgets('renders Emergency Vault screen with SOS card, ICE medical card, and contacts',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
          ],
          child: const MaterialApp(
            home: EmergencyVaultScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify AppBar & Title
      expect(find.text('Emergency Health Vault'), findsOneWidget);

      // Verify SOS Card
      expect(find.text('SOS EMERGENCY DISPATCH'), findsOneWidget);
      expect(find.text('Call 911 / 112'), findsOneWidget);

      // Verify Digital Medical ID Card
      expect(find.text('DIGITAL MEDICAL ID (I.C.E.)'), findsOneWidget);
      expect(find.text('BLOOD'), findsOneWidget);
      expect(find.text('O+'), findsOneWidget);
      expect(find.text('CRITICAL ALLERGIES'), findsOneWidget);
      expect(find.text('CHRONIC CONDITIONS & IMPAIRMENTS'), findsOneWidget);

      // Verify Emergency Contacts
      expect(find.text('Emergency Contacts (I.C.E.)'), findsOneWidget);
      expect(find.text('Sarah Mercer'), findsWidgets);
      expect(find.text('PRIMARY'), findsWidgets);

      // Verify First Aid Protocols
      expect(find.text('First Aid Emergency Protocols'), findsOneWidget);
      expect(find.text('Adult CPR (Cardiac Arrest)'), findsOneWidget);

      // Verify Legal Disclaimer
      expect(find.text('CRITICAL EMERGENCY DISCLAIMER'), findsOneWidget);
    });

    testWidgets('tapping Call 911/112 opens emergency confirmation modal', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
          ],
          child: const MaterialApp(
            home: EmergencyVaultScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final call911Button = find.text('Call 911 / 112');
      expect(call911Button, findsOneWidget);
      await tester.tap(call911Button);
      await tester.pumpAndSettle();

      expect(find.text('Confirm Call'), findsOneWidget);
      expect(find.text('Call Now'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm Call'), findsNothing);
    });

    testWidgets('tapping Add Contact opens bottom sheet with input fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
          ],
          child: const MaterialApp(
            home: EmergencyVaultScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final addBtn = find.text('Add Contact');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add Emergency Contact'), findsOneWidget);
      expect(find.text('Contact Name'), findsOneWidget);
      expect(find.text('Relationship'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Save Contact'), findsOneWidget);
    });

    testWidgets('tapping edit medical ID button opens edit sheet', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
          ],
          child: const MaterialApp(
            home: EmergencyVaultScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final editIcon = find.byIcon(Icons.edit_outlined);
      expect(editIcon, findsOneWidget);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      expect(find.text('Edit Medical ID (I.C.E.)'), findsOneWidget);
      expect(find.text('Blood Group'), findsOneWidget);
      expect(find.text('Known Allergies'), findsOneWidget);
      expect(find.text('Save Medical ID'), findsOneWidget);
    });

    testWidgets('tapping protocol card expands and collapses steps', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
          ],
          child: const MaterialApp(
            home: EmergencyVaultScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Stroke protocol starts collapsed
      final strokeCard = find.text('Stroke Identification (F.A.S.T)');
      expect(strokeCard, findsOneWidget);
      await tester.ensureVisible(strokeCard);
      await tester.pumpAndSettle();
      await tester.tap(strokeCard);
      await tester.pumpAndSettle();

      // Check for F.A.S.T steps
      expect(find.textContaining('Face Drooping'), findsOneWidget);
    });
  });
}
