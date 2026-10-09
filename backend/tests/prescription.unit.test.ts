import {
  createPrescriptionSchema,
  prescriptionMedicineSchema,
} from '../src/validators/prescription.validator';

async function runTests() {
  console.log('--- RUNNING PRESCRIPTION UNIT TESTS ---');

  // Test 1: Valid prescription input
  console.log('1. Testing createPrescriptionSchema with valid data...');
  const validData = {
    patientId: '123e4567-e89b-12d3-a456-426614174000',
    appointmentId: '123e4567-e89b-12d3-a456-426614174001',
    diagnosis: 'Acute bacterial pharyngitis',
    generalInstructions: 'Rest well, drink warm liquids, complete antibiotic course.',
    medicines: [
      {
        medicineName: 'Amoxicillin',
        dosage: '500mg',
        frequency: 'Three times daily',
        durationDays: 7,
        instructions: 'Take after meals with water',
      },
      {
        medicineName: 'Paracetamol',
        dosage: '650mg',
        frequency: 'As needed for fever',
        durationDays: 3,
        instructions: 'Do not exceed 4 tablets in 24 hours',
      },
    ],
  };

  const parsed = createPrescriptionSchema.parse(validData);
  if (parsed.medicines.length !== 2 || parsed.diagnosis !== 'Acute bacterial pharyngitis') {
    throw new Error('createPrescriptionSchema parsing failed');
  }
  console.log('   createPrescriptionSchema validated successfully.');

  // Test 2: Prescription without medicines should fail
  console.log('2. Testing createPrescriptionSchema with empty medicines list...');
  try {
    createPrescriptionSchema.parse({
      patientId: '123e4567-e89b-12d3-a456-426614174000',
      diagnosis: 'Hypertension',
      medicines: [],
    });
    throw new Error('Should have failed for empty medicines');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected prescription with empty medicines.');
    } else {
      throw err;
    }
  }

  // Test 3: Invalid durationDays in medicine
  console.log('3. Testing prescriptionMedicineSchema with invalid durationDays...');
  try {
    prescriptionMedicineSchema.parse({
      medicineName: 'Aspirin',
      dosage: '100mg',
      frequency: 'Once daily',
      durationDays: 0, // must be at least 1
    });
    throw new Error('Should have failed for durationDays = 0');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected medicine with durationDays < 1.');
    } else {
      throw err;
    }
  }

  // Test 4: Invalid patient UUID
  console.log('4. Testing invalid patient UUID format...');
  try {
    createPrescriptionSchema.parse({
      patientId: 'not-a-valid-uuid',
      diagnosis: 'Gastritis',
      medicines: [
        {
          medicineName: 'Omeprazole',
          dosage: '20mg',
          frequency: 'Once daily before breakfast',
          durationDays: 14,
        },
      ],
    });
    throw new Error('Should have failed for invalid UUID');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected invalid patient UUID.');
    } else {
      throw err;
    }
  }

  console.log('--- ALL PRESCRIPTION UNIT TESTS PASSED! ---');
}

runTests().catch((err) => {
  console.error('Test run failed:', err);
  process.exit(1);
});
