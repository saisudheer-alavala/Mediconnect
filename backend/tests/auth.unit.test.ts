import { hashPassword, comparePassword } from '../src/utils/password';
import { signAccessToken, verifyAccessToken, signRefreshToken, verifyRefreshToken } from '../src/utils/jwt';
import { patientRegisterSchema, doctorRegisterSchema, loginSchema } from '../src/validators/auth.validator';
import { UserRole } from '@prisma/client';

async function runTests() {
  console.log('--- RUNNING AUTH UNIT TESTS ---');

  // 1. Password Hashing Tests
  console.log('1. Testing Password Hashing & Verification...');
  const password = 'StrongPassword123';
  const hash = await hashPassword(password);

  if (!hash.startsWith('$2')) {
    throw new Error('Hash does not match bcrypt format');
  }

  const isMatch = await comparePassword(password, hash);
  if (!isMatch) {
    throw new Error('Correct password failed comparison');
  }

  const isWrongMatch = await comparePassword('WrongPassword', hash);
  if (isWrongMatch) {
    throw new Error('Incorrect password was erroneously validated');
  }
  console.log('   Password hashing verified.');

  // 2. JWT Signing & Verification Tests
  console.log('2. Testing JWT Signing & Verification...');
  const testPayload = {
    userId: 'test-user-uuid',
    email: 'patient@medicare.test',
    role: UserRole.PATIENT,
  };

  const accessToken = signAccessToken(testPayload);
  const verifiedAccess = verifyAccessToken(accessToken);
  if (!verifiedAccess || verifiedAccess.userId !== testPayload.userId || verifiedAccess.role !== UserRole.PATIENT) {
    throw new Error('Access token verification failed or payload mismatch');
  }

  const refreshToken = signRefreshToken(testPayload);
  const verifiedRefresh = verifyRefreshToken(refreshToken);
  if (!verifiedRefresh || verifiedRefresh.userId !== testPayload.userId) {
    throw new Error('Refresh token verification failed');
  }

  const tamperedResult = verifyAccessToken(accessToken + 'tampered');
  if (tamperedResult !== null) {
    throw new Error('Tampered token was erroneously accepted');
  }
  console.log('   JWT signing, verification & tampering rejection verified.');

  // 3. Validation Schema Tests
  console.log('3. Testing Zod Input Validation Schemas...');
  
  // Patient validation success
  const validPatient = patientRegisterSchema.safeParse({
    email: 'sarah@example.com',
    password: 'Password99',
    fullName: 'Sarah Jenkins',
    phone: '+1234567890',
  });
  if (!validPatient.success) {
    throw new Error('Valid patient input failed validation: ' + JSON.stringify(validPatient.error));
  }

  // Patient validation failure (weak password)
  const weakPatient = patientRegisterSchema.safeParse({
    email: 'sarah@example.com',
    password: 'short',
    fullName: 'Sarah Jenkins',
  });
  if (weakPatient.success) {
    throw new Error('Weak password was erroneously accepted');
  }

  // Doctor validation success
  const validDoctor = doctorRegisterSchema.safeParse({
    email: 'dr.smith@hospital.org',
    password: 'DoctorSecret1',
    fullName: 'Dr. Jane Smith',
    specializationName: 'Cardiologist',
    qualification: 'MD Cardiology',
    licenseNumber: 'LIC-992019',
    experienceYears: 10,
    clinicName: 'Heart Care Center',
  });
  if (!validDoctor.success) {
    throw new Error('Valid doctor input failed validation: ' + JSON.stringify(validDoctor.error));
  }

  // Login validation
  const validLogin = loginSchema.safeParse({
    email: 'test@example.com',
    password: 'secret',
  });
  if (!validLogin.success) {
    throw new Error('Valid login failed validation');
  }
  console.log('   Zod input validation schemas verified.');

  console.log('--- ALL AUTH UNIT TESTS PASSED SUCCESSFULLY! ---');
}

runTests().catch((err) => {
  console.error('Test Suite Failed:', err);
  process.exit(1);
});
