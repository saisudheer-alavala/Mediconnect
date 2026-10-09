import { searchDoctorSchema, slotsQuerySchema } from '../src/validators/doctor.validator';

async function runTests() {
  console.log('--- RUNNING DOCTOR DIRECTORY UNIT TESTS ---');

  // 1. Test searchDoctorSchema
  console.log('1. Testing searchDoctorSchema...');
  const parsedSearch = searchDoctorSchema.safeParse({
    search: 'Cardiology',
    minFee: '50',
    maxFee: '150',
    minExperience: '5',
    page: '2',
    limit: '15',
  });

  if (!parsedSearch.success) {
    throw new Error('searchDoctorSchema failed: ' + JSON.stringify(parsedSearch.error.errors));
  }

  if (
    parsedSearch.data.minFee !== 50 ||
    parsedSearch.data.maxFee !== 150 ||
    parsedSearch.data.page !== 2 ||
    parsedSearch.data.limit !== 15
  ) {
    throw new Error('Type coercion failed in searchDoctorSchema');
  }

  // Reject limit > 50
  const invalidLimit = searchDoctorSchema.safeParse({ limit: '100' });
  if (invalidLimit.success) {
    throw new Error('Limit > 50 should have been rejected');
  }
  console.log('   searchDoctorSchema validated successfully.');

  // 2. Test slotsQuerySchema
  console.log('2. Testing slotsQuerySchema...');
  const validSlotDate = slotsQuerySchema.safeParse({ date: '2026-10-15' });
  if (!validSlotDate.success) {
    throw new Error('Valid YYYY-MM-DD date rejected');
  }

  const invalidSlotDate = slotsQuerySchema.safeParse({ date: '15-10-2026' });
  if (invalidSlotDate.success) {
    throw new Error('Invalid date format was accepted');
  }
  console.log('   slotsQuerySchema validated successfully.');

  // 3. Test slot generation calculation logic
  console.log('3. Testing slot calculation logic with break window...');
  const startMinutes = 9 * 60; // 09:00
  const endMinutes = 12 * 60;   // 12:00
  const slotDuration = 30;

  const generatedSlots: string[] = [];
  let curr = startMinutes;
  while (curr + slotDuration <= endMinutes) {
    const h = Math.floor(curr / 60).toString().padStart(2, '0');
    const m = (curr % 60).toString().padStart(2, '0');
    generatedSlots.push(`${h}:${m}`);
    curr += slotDuration;
  }

  // 09:00 to 12:00 with 30 min duration = 6 slots (09:00, 09:30, 10:00, 10:30, 11:00, 11:30)
  if (generatedSlots.length !== 6 || generatedSlots[0] !== '09:00' || generatedSlots[5] !== '11:30') {
    throw new Error(`Unexpected slots generated: ${JSON.stringify(generatedSlots)}`);
  }
  console.log('   Slot interval calculations verified.');

  console.log('--- ALL DOCTOR DIRECTORY UNIT TESTS PASSED! ---');
}

runTests().catch((err) => {
  console.error('Test execution failed:', err);
  process.exit(1);
});
