import { execSync } from 'child_process';
import * as path from 'path';

const testFiles = [
  'appointment.unit.test.ts',
  'auth.unit.test.ts',
  'doctor.unit.test.ts',
  'emergency.unit.test.ts',
  'health_record.unit.test.ts',
  'medicine.unit.test.ts',
  'notification.unit.test.ts',
  'prescription.unit.test.ts',
  'profile.unit.test.ts',
  'review.unit.test.ts',
  'schedule.unit.test.ts',
  'security_audit.unit.test.ts',
];

console.log('=================================================================');
console.log(' MEDICARE CONNECT — FULL BACKEND COMPREHENSIVE SUITE VERIFICATION');
console.log(' Total Suites: ' + testFiles.length);
console.log('=================================================================\n');

let passedCount = 0;
let failedCount = 0;

for (const file of testFiles) {
  const filePath = path.join(__dirname, file);
  process.stdout.write(`Executing [${file}] ... `);
  try {
    execSync(`npx ts-node "${filePath}"`, {
      stdio: 'pipe',
      cwd: path.join(__dirname, '..'),
    });
    console.log('PASSED (Exit 0)');
    passedCount++;
  } catch (err: any) {
    console.log('FAILED');
    console.error(err.stdout ? err.stdout.toString() : err.message);
    failedCount++;
  }
}

console.log('\n=================================================================');
console.log(` SUMMARY: ${passedCount}/${testFiles.length} Test Suites Passed.`);
if (failedCount === 0) {
  console.log(' RESULT: 100% OF BACKEND SUITES VERIFIED AND HEALTHY!');
  console.log('=================================================================');
  process.exit(0);
} else {
  console.error(` FAILURE: ${failedCount} suites encountered errors.`);
  console.log('=================================================================');
  process.exit(1);
}
