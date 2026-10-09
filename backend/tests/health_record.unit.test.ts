import {
  createHealthRecordSchema,
  updateHealthRecordSchema,
  healthRecordQuerySchema,
} from '../src/validators/health_record.validator';
import { HealthRecordCategory } from '@prisma/client';

async function runTests() {
  console.log('--- RUNNING HEALTH RECORD & TIMELINE UNIT TESTS ---');

  // Test 1: Valid health record input
  console.log('1. Testing createHealthRecordSchema with valid blood test record...');
  const validRecord = {
    title: 'Comprehensive Metabolic Panel (CMP)',
    category: HealthRecordCategory.BLOOD_TEST,
    description: 'Fasting blood glucose 92 mg/dL, normal kidney and liver panel.',
    fileUrl: 'https://storage.medicareconnect.com/records/cmp_2026_10.pdf',
    fileSize: 1048576,
    mimeType: 'application/pdf',
    uploadedAt: new Date().toISOString(),
  };

  const parsed = createHealthRecordSchema.parse(validRecord);
  if (
    parsed.title !== 'Comprehensive Metabolic Panel (CMP)' ||
    parsed.category !== HealthRecordCategory.BLOOD_TEST ||
    parsed.fileSize !== 1048576
  ) {
    throw new Error('createHealthRecordSchema failed parsing valid record');
  }
  console.log('   createHealthRecordSchema validated successfully.');

  // Test 2: Missing fileUrl should fail
  console.log('2. Testing createHealthRecordSchema with missing fileUrl...');
  try {
    createHealthRecordSchema.parse({
      title: 'Chest X-Ray Report',
      category: HealthRecordCategory.X_RAY,
      fileUrl: '',
    });
    throw new Error('Should have failed for empty fileUrl');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected record with empty fileUrl.');
    } else {
      throw err;
    }
  }

  // Test 3: Invalid category enum
  console.log('3. Testing createHealthRecordSchema with invalid category enum...');
  try {
    createHealthRecordSchema.parse({
      title: 'MRI Brain',
      category: 'INVALID_CATEGORY',
      fileUrl: 'https://example.com/mri.pdf',
    });
    throw new Error('Should have failed for invalid category');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected invalid category enum.');
    } else {
      throw err;
    }
  }

  // Test 4: Partial update
  console.log('4. Testing updateHealthRecordSchema with partial updates...');
  const partial = updateHealthRecordSchema.parse({
    title: 'Updated Chest X-Ray (Clear)',
    description: 'Bilateral lung fields clear of consolidation.',
  });
  if (
    partial.title !== 'Updated Chest X-Ray (Clear)' ||
    partial.category !== undefined
  ) {
    throw new Error('updateHealthRecordSchema partial failed');
  }
  console.log('   updateHealthRecordSchema partial update validated successfully.');

  // Test 5: Query filters
  console.log('5. Testing healthRecordQuerySchema with category and search filter...');
  const query = healthRecordQuerySchema.parse({
    category: HealthRecordCategory.SCAN,
    search: 'Cardiology',
  });
  if (query.category !== HealthRecordCategory.SCAN || query.search !== 'Cardiology') {
    throw new Error('healthRecordQuerySchema failed');
  }
  console.log('   healthRecordQuerySchema validated successfully.');

  console.log('--- ALL HEALTH RECORD & TIMELINE UNIT TESTS PASSED! ---');
}

runTests().catch((err) => {
  console.error('Test run failed:', err);
  process.exit(1);
});
