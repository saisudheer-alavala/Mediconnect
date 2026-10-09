import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/features/auth/presentation/doctor_register_screen.dart';
import 'package:mediconnect/features/auth/presentation/forgot_password_screen.dart';
import 'package:mediconnect/features/auth/presentation/login_screen.dart';
import 'package:mediconnect/features/auth/presentation/patient_register_screen.dart';

void main() {
  group('LoginScreen Tests', () {
    testWidgets('renders login components and validates empty input', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Patient'), findsOneWidget);
      expect(find.text('Doctor'), findsOneWidget);

      // Tap Log In with empty fields to trigger validation
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });

  group('PatientRegisterScreen Tests', () {
    testWidgets('renders patient registration fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PatientRegisterScreen(),
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Create Patient Account'), findsOneWidget);
    });
  });

  group('DoctorRegisterScreen Tests', () {
    testWidgets('renders doctor registration credentials fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DoctorRegisterScreen(),
          ),
        ),
      );

      expect(find.text('Primary Medical Specialization'), findsOneWidget);
      expect(find.text('Highest Medical Qualification'), findsOneWidget);
      expect(find.text('Medical License / Registration ID'), findsOneWidget);
      expect(find.text('Clinical Experience (in Years)'), findsOneWidget);
      expect(find.text('Affiliated Clinic / Hospital'), findsOneWidget);
      expect(find.text('Submit Doctor Registration'), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen Tests', () {
    testWidgets('renders forgot password view and shows email field', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      expect(find.text('Forgot Your Password?'), findsOneWidget);
      expect(find.text('Send Reset Instructions'), findsOneWidget);
    });
  });
}
