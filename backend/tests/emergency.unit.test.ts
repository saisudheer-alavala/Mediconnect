import {
  createEmergencyContactSchema,
  updateEmergencyContactSchema,
  updateMedicalIdSchema,
} from '../src/validators/emergency.validator';

async function runTests() {
  console.log('--- RUNNING EMERGENCY & HEALTH VAULT UNIT TESTS ---');

  // Test 1: Valid emergency contact input
  console.log('1. Testing createEmergencyContactSchema with valid primary contact...');
  const validContact = {
    name: 'Sarah Mercer',
    relationship: 'Spouse',
    phone: '+1 555-019-2834',
    isPrimary: true,
  };

  const parsedContact = createEmergencyContactSchema.parse(validContact);
  if (
    parsedContact.name !== 'Sarah Mercer' ||
    parsedContact.relationship !== 'Spouse' ||
    parsedContact.isPrimary !== true
  ) {
    throw new Error('createEmergencyContactSchema parsing failed');
  }
  console.log('   createEmergencyContactSchema validated successfully.');

  // Test 2: Contact with too short phone number should fail
  console.log('2. Testing createEmergencyContactSchema with invalid short phone...');
  try {
    createEmergencyContactSchema.parse({
      name: 'Dr. John',
      relationship: 'Doctor',
      phone: '123',
    });
    throw new Error('Should have failed for phone < 7 chars');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected short phone number.');
    } else {
      throw err;
    }
  }

  // Test 3: Contact with empty name should fail
  console.log('3. Testing createEmergencyContactSchema with empty name...');
  try {
    createEmergencyContactSchema.parse({
      name: ' ',
      relationship: 'Sibling',
      phone: '+1 555-999-8888',
    });
    throw new Error('Should have failed for empty name');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected empty name.');
    } else {
      throw err;
    }
  }

  // Test 4: Update medical ID schema with valid attributes
  console.log('4. Testing updateMedicalIdSchema with valid medical parameters...');
  const validMedicalId = {
    bloodGroup: 'O+',
    allergies: 'Penicillin, Peanuts, Sulfa Drugs',
    chronicDiseases: 'Mild Asthma, Type 2 Diabetes',
  };

  const parsedMedical = updateMedicalIdSchema.parse(validMedicalId);
  if (
    parsedMedical.bloodGroup !== 'O+' ||
    !parsedMedical.allergies?.includes('Penicillin')
  ) {
    throw new Error('updateMedicalIdSchema parsing failed');
  }
  console.log('   updateMedicalIdSchema validated successfully.');

  // Test 5: Partial contact updates
  console.log('5. Testing updateEmergencyContactSchema partial updates...');
  const partialUpdate = updateEmergencyContactSchema.parse({
    phone: '+1 555-444-3322',
  });
  if (partialUpdate.phone !== '+1 555-444-3322' || partialUpdate.name !== undefined) {
    throw new Error('updateEmergencyContactSchema partial failed');
  }
  console.log('   updateEmergencyContactSchema partial update validated successfully.');

  console.log('--- ALL EMERGENCY & HEALTH VAULT UNIT TESTS PASSED! ---');
}

runTests().catch((err) => {
  console.error('Test run failed:', err);
  process.exit(1);
});
