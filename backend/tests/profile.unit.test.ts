import {
  updatePatientProfileSchema,
  updateDoctorProfileSchema,
  changePasswordSchema,
  deactivateAccountSchema,
} from '../src/validators/profile.validator';
import { ProfileService } from '../src/services/profile.service';
import { comparePassword, hashPassword } from '../src/utils/password';

async function runTests() {
  console.log('--- RUNNING PATIENT & DOCTOR PROFILE UNIT TESTS ---');

  // Test 1: updatePatientProfileSchema with valid data
  console.log('1. Testing updatePatientProfileSchema with valid data...');
  const validPatient = {
    fullName: 'Jane Doe',
    phone: '+1-555-0199',
    gender: 'FEMALE' as const,
    bloodGroup: 'O+',
    allergies: 'Penicillin, Shellfish',
    chronicDiseases: 'Asthma',
  };

  const parsedPatient = updatePatientProfileSchema.parse(validPatient);
  if (parsedPatient.fullName !== 'Jane Doe' || parsedPatient.bloodGroup !== 'O+') {
    throw new Error('updatePatientProfileSchema failed for valid input');
  }
  console.log('   updatePatientProfileSchema validated successfully.');

  // Test 2: updatePatientProfileSchema rejects short name
  console.log('2. Testing updatePatientProfileSchema rejects short name...');
  try {
    updatePatientProfileSchema.parse({ fullName: 'A' });
    throw new Error('Should have failed for single-character name');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected short name.');
    } else {
      throw err;
    }
  }

  // Test 3: updateDoctorProfileSchema with valid professional details
  console.log('3. Testing updateDoctorProfileSchema with valid data...');
  const validDoctor = {
    fullName: 'Dr. Sarah Connor',
    phone: '+1-555-0288',
    qualification: 'MD, FACC',
    experienceYears: 14,
    clinicName: 'Apex Heart & Vascular Center',
    clinicAddress: '100 Medical Plaza, Suite 400',
    consultationFee: 150.0,
    bio: 'Board-certified cardiologist specializing in preventive medicine.',
  };

  const parsedDoctor = updateDoctorProfileSchema.parse(validDoctor);
  if (parsedDoctor.experienceYears !== 14 || parsedDoctor.consultationFee !== 150.0) {
    throw new Error('updateDoctorProfileSchema failed for valid input');
  }
  console.log('   updateDoctorProfileSchema validated successfully.');

  // Test 4: updateDoctorProfileSchema rejects negative experience
  console.log('4. Testing updateDoctorProfileSchema rejects negative experience...');
  try {
    updateDoctorProfileSchema.parse({ experienceYears: -3 });
    throw new Error('Should have failed for negative experience');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected negative experience.');
    } else {
      throw err;
    }
  }

  // Test 5: changePasswordSchema enforces 8 chars, letter, and number
  console.log('5. Testing changePasswordSchema password strength...');
  const validPw = {
    currentPassword: 'OldPassword123!',
    newPassword: 'NewSecurePass2026',
  };
  const parsedPw = changePasswordSchema.parse(validPw);
  if (parsedPw.newPassword !== 'NewSecurePass2026') {
    throw new Error('changePasswordSchema failed for valid password');
  }
  console.log('   changePasswordSchema accepted secure password.');

  try {
    changePasswordSchema.parse({
      currentPassword: 'OldPassword123!',
      newPassword: 'onlyletters',
    });
    throw new Error('Should have rejected password without numbers');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected password lacking numbers.');
    } else {
      throw err;
    }
  }

  // Test 6: deactivateAccountSchema validation
  console.log('6. Testing deactivateAccountSchema confirmation enforcement...');
  const validDeact = {
    password: 'CurrentPass123',
    confirm: true,
  };
  const parsedDeact = deactivateAccountSchema.parse(validDeact);
  if (!parsedDeact.confirm) {
    throw new Error('deactivateAccountSchema failed');
  }

  try {
    deactivateAccountSchema.parse({
      password: 'CurrentPass123',
      confirm: false,
    });
    throw new Error('Should have rejected unconfirmed deactivation');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly required explicit confirm=true.');
    } else {
      throw err;
    }
  }

  // Test 7: Verify password comparison logic and sanitization
  console.log('7. Testing password hashing & profile service sanitization logic...');
  const plain = 'SecretPass123!';
  const hashed = await hashPassword(plain);
  const matches = await comparePassword(plain, hashed);
  const wrongMatches = await comparePassword('WrongPassword', hashed);

  if (!matches || wrongMatches) {
    throw new Error('Password hashing verification mismatch');
  }
  console.log('   Password hashing & verification working as expected.');

  // Test sanitization via ProfileService reflection
  const svc = new ProfileService();
  const rawUserWithHash = {
    id: 'user-123',
    email: 'user@example.com',
    passwordHash: hashed,
    phone: '+1-555-1234',
    role: 'PATIENT',
  };
  const sanitized = (svc as any).sanitizeUser(rawUserWithHash);
  if ('passwordHash' in sanitized || sanitized.id !== 'user-123') {
    throw new Error('Profile sanitization failed to redact passwordHash');
  }
  console.log('   User sanitization successfully stripped passwordHash.');

  console.log('--- ALL 7 PROFILE UNIT TESTS PASSED SUCCESSFULLY! ---');
}

runTests().catch((err) => {
  console.error('Profile unit tests failed:', err);
  process.exit(1);
});
