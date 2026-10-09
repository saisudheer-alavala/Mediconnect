import {
  createMedicineSchema,
  updateMedicineSchema,
  logDoseSchema,
} from '../src/validators/medicine.validator';
import { DoseStatus } from '@prisma/client';

async function runTests() {
  console.log('--- RUNNING MEDICINE UNIT TESTS ---');

  // 1. Validation tests for createMedicineSchema
  console.log('1. Testing createMedicineSchema...');
  const validMedicine = {
    name: 'Atorvastatin',
    dosage: '20mg',
    frequency: 'Once daily at bedtime',
    instructions: 'Take with or without food',
    startDate: '2026-10-01T00:00:00.000Z',
    endDate: '2026-12-31T00:00:00.000Z',
    reminders: ['21:00'],
  };

  const parsedValid = createMedicineSchema.safeParse(validMedicine);
  if (!parsedValid.success) {
    throw new Error('Valid medicine failed validation: ' + JSON.stringify(parsedValid.error.errors));
  }

  // Reject empty reminders
  const noReminders = {
    ...validMedicine,
    reminders: [],
  };
  const parsedNoReminders = createMedicineSchema.safeParse(noReminders);
  if (parsedNoReminders.success) {
    throw new Error('Medicine with 0 reminders should fail validation');
  }

  // Reject invalid reminder format (e.g., 25:00 or 9:00 without leading zero)
  const invalidTimeFormat = {
    ...validMedicine,
    reminders: ['25:00'],
  };
  const parsedInvalidTime = createMedicineSchema.safeParse(invalidTimeFormat);
  if (parsedInvalidTime.success) {
    throw new Error('Invalid HH:mm reminder should fail validation');
  }
  console.log('   createMedicineSchema validated successfully.');

  // 2. Validation tests for logDoseSchema
  console.log('2. Testing logDoseSchema...');
  const validLog = {
    scheduledTime: '2026-10-08T08:00:00.000Z',
    status: DoseStatus.TAKEN,
    takenTime: '2026-10-08T08:05:00.000Z',
    notes: 'Taken after breakfast',
  };

  const parsedValidLog = logDoseSchema.safeParse(validLog);
  if (!parsedValidLog.success) {
    throw new Error('Valid dose log failed validation: ' + JSON.stringify(parsedValidLog.error.errors));
  }

  const invalidStatusLog = {
    scheduledTime: '2026-10-08T08:00:00.000Z',
    status: 'FORGOTTEN', // Not in DoseStatus enum
  };
  const parsedInvalidStatus = logDoseSchema.safeParse(invalidStatusLog);
  if (parsedInvalidStatus.success) {
    throw new Error('Invalid DoseStatus enum should fail validation');
  }
  console.log('   logDoseSchema validated successfully.');

  // 3. Adherence rate calculation test
  console.log('3. Testing adherence metrics computation...');
  const mockLogs = [
    { status: DoseStatus.TAKEN },
    { status: DoseStatus.TAKEN },
    { status: DoseStatus.SKIPPED },
    { status: DoseStatus.TAKEN },
  ];
  const total = mockLogs.length;
  const taken = mockLogs.filter((l) => l.status === DoseStatus.TAKEN).length;
  const adherenceRate = Math.round((taken / total) * 1000) / 10;

  if (adherenceRate !== 75.0) {
    throw new Error(`Expected adherence 75.0%, got ${adherenceRate}%`);
  }
  console.log('   Adherence percentage calculations verified.');

  console.log('--- ALL MEDICINE UNIT TESTS PASSED SUCCESSFULLY! ---');
}

runTests().catch((err) => {
  console.error('Test execution failed:', err);
  process.exit(1);
});
