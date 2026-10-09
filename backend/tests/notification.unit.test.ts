import {
  createNotificationSchema,
  notificationQuerySchema,
} from '../src/validators/notification.validator';
import { NotificationType } from '@prisma/client';

async function runTests() {
  console.log('--- RUNNING NOTIFICATION & ADHERENCE REMINDERS UNIT TESTS ---');

  // Test 1: Valid notification schema with MEDICINE type
  console.log('1. Testing createNotificationSchema with valid medicine reminder...');
  const validMedAlert = {
    title: 'Medication Adherence Alert: Atorvastatin',
    message: 'Time to take your scheduled 20mg dose of Atorvastatin with water.',
    type: NotificationType.MEDICINE,
  };

  const parsedMed = createNotificationSchema.parse(validMedAlert);
  if (
    parsedMed.title !== 'Medication Adherence Alert: Atorvastatin' ||
    parsedMed.type !== NotificationType.MEDICINE
  ) {
    throw new Error('createNotificationSchema parsing failed for medicine alert');
  }
  console.log('   createNotificationSchema validated medicine alert successfully.');

  // Test 2: Valid appointment notification
  console.log('2. Testing createNotificationSchema with appointment notification...');
  const validApptAlert = {
    title: 'Appointment Confirmed',
    message: 'Your teleconsultation with Dr. Sarah Jenkins is confirmed for today at 10:30 AM.',
    type: NotificationType.APPOINTMENT,
  };

  const parsedAppt = createNotificationSchema.parse(validApptAlert);
  if (parsedAppt.type !== NotificationType.APPOINTMENT) {
    throw new Error('createNotificationSchema parsing failed for appointment');
  }
  console.log('   createNotificationSchema validated appointment alert successfully.');

  // Test 3: Notification with empty message should fail
  console.log('3. Testing createNotificationSchema with empty message...');
  try {
    createNotificationSchema.parse({
      title: 'Alert',
      message: ' ',
      type: NotificationType.SYSTEM,
    });
    throw new Error('Should have failed for empty message');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected notification with empty message.');
    } else {
      throw err;
    }
  }

  // Test 4: Invalid notification type enum
  console.log('4. Testing createNotificationSchema with invalid notification type...');
  try {
    createNotificationSchema.parse({
      title: 'System Notice',
      message: 'System undergoing maintenance.',
      type: 'INVALID_ALERT_TYPE',
    });
    throw new Error('Should have failed for invalid type');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected invalid notification type enum.');
    } else {
      throw err;
    }
  }

  // Test 5: Query filters
  console.log('5. Testing notificationQuerySchema with unreadOnly and type filters...');
  const query = notificationQuerySchema.parse({
    unreadOnly: 'true',
    type: NotificationType.MEDICINE,
  });
  if (query.unreadOnly !== 'true' || query.type !== NotificationType.MEDICINE) {
    throw new Error('notificationQuerySchema parsing failed');
  }
  console.log('   notificationQuerySchema validated successfully.');

  console.log('--- ALL NOTIFICATION & ADHERENCE REMINDERS UNIT TESTS PASSED! ---');
}

runTests().catch((err) => {
  console.error('Test run failed:', err);
  process.exit(1);
});
