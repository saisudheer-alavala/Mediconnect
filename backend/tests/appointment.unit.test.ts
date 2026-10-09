import {
  createAppointmentSchema,
  updateAppointmentStatusSchema,
  queryAppointmentsSchema,
} from '../src/validators/appointment.validator';
import { AppointmentStatus } from '@prisma/client';

async function runTests() {
  console.log('--- RUNNING APPOINTMENT UNIT TESTS ---');

  // 1. Test createAppointmentSchema
  console.log('1. Testing createAppointmentSchema...');
  const validBooking = {
    doctorId: '123e4567-e89b-12d3-a456-426614174000',
    appointmentDate: '2026-10-15',
    startTime: '10:30',
    patientNotes: 'Routine cardiology follow-up and ECG review',
  };

  const parsedValid = createAppointmentSchema.safeParse(validBooking);
  if (!parsedValid.success) {
    throw new Error('createAppointmentSchema failed on valid booking: ' + JSON.stringify(parsedValid.error.errors));
  }

  // Reject invalid date
  const invalidDate = createAppointmentSchema.safeParse({
    ...validBooking,
    appointmentDate: '15/10/2026',
  });
  if (invalidDate.success) {
    throw new Error('Invalid date format was accepted');
  }

  // Reject invalid time
  const invalidTime = createAppointmentSchema.safeParse({
    ...validBooking,
    startTime: '25:00',
  });
  if (invalidTime.success) {
    throw new Error('Invalid start time was accepted');
  }
  console.log('   createAppointmentSchema validated successfully.');

  // 2. Test updateAppointmentStatusSchema
  console.log('2. Testing updateAppointmentStatusSchema...');
  const validStatusUpdate = updateAppointmentStatusSchema.safeParse({
    status: AppointmentStatus.CANCELLED,
    cancellationReason: 'Patient rescheduled due to travel conflict',
  });
  if (!validStatusUpdate.success) {
    throw new Error('Status update schema rejected valid transition');
  }

  const invalidStatusUpdate = updateAppointmentStatusSchema.safeParse({
    status: 'UNKNOWN_STATUS',
  });
  if (invalidStatusUpdate.success) {
    throw new Error('Invalid status was accepted');
  }
  console.log('   updateAppointmentStatusSchema validated successfully.');

  // 3. Test endTime calculation (+30 mins)
  console.log('3. Testing endTime calculation logic...');
  const calculateEndTime = (start: string) => {
    const [h, m] = start.split(':').map(Number);
    const endMinutes = h * 60 + m + 30;
    const endH = Math.floor(endMinutes / 60).toString().padStart(2, '0');
    const endM = (endMinutes % 60).toString().padStart(2, '0');
    return `${endH}:${endM}`;
  };

  if (calculateEndTime('10:30') !== '11:00') {
    throw new Error('Failed 10:30 -> 11:00 calculation');
  }
  if (calculateEndTime('11:45') !== '12:15') {
    throw new Error('Failed 11:45 -> 12:15 calculation');
  }
  console.log('   End-time calculation verified.');

  console.log('--- ALL APPOINTMENT UNIT TESTS PASSED! ---');
}

runTests().catch((err) => {
  console.error('Test execution failed:', err);
  process.exit(1);
});
