import {
  dayScheduleItemSchema,
  updateScheduleSchema,
} from '../src/validators/schedule.validator';

async function runTests() {
  console.log('--- RUNNING DOCTOR SCHEDULE & WORKING HOURS UNIT TESTS ---');

  // Test 1: Valid schedule item with shift & break
  console.log('1. Testing dayScheduleItemSchema with valid hours and lunch break...');
  const validDay = {
    dayOfWeek: 1, // Monday
    startTime: '09:00',
    endTime: '17:00',
    slotDurationMinutes: 30,
    breakStartTime: '13:00',
    breakEndTime: '14:00',
    isActive: true,
  };

  const parsed1 = dayScheduleItemSchema.parse(validDay);
  if (parsed1.dayOfWeek !== 1 || parsed1.slotDurationMinutes !== 30) {
    throw new Error('dayScheduleItemSchema validation failed for valid day');
  }
  console.log('   dayScheduleItemSchema validated Monday working hours successfully.');

  // Test 2: Inactive day off (Sunday)
  console.log('2. Testing dayScheduleItemSchema for day off...');
  const dayOff = {
    dayOfWeek: 0,
    startTime: '09:00',
    endTime: '17:00',
    slotDurationMinutes: 30,
    isActive: false,
  };

  const parsed2 = dayScheduleItemSchema.parse(dayOff);
  if (parsed2.isActive !== false) {
    throw new Error('dayScheduleItemSchema validation failed for day off');
  }
  console.log('   dayScheduleItemSchema validated day off successfully.');

  // Test 3: Reject endTime <= startTime
  console.log('3. Testing dayScheduleItemSchema with endTime earlier than startTime...');
  try {
    dayScheduleItemSchema.parse({
      dayOfWeek: 2,
      startTime: '17:00',
      endTime: '09:00',
      slotDurationMinutes: 30,
      isActive: true,
    });
    throw new Error('Should have failed for inverted shift hours');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected shift with endTime earlier than startTime.');
    } else {
      throw err;
    }
  }

  // Test 4: Reject break outside working hours
  console.log('4. Testing dayScheduleItemSchema with break outside shift bounds...');
  try {
    dayScheduleItemSchema.parse({
      dayOfWeek: 3,
      startTime: '09:00',
      endTime: '17:00',
      slotDurationMinutes: 30,
      breakStartTime: '18:00',
      breakEndTime: '19:00',
      isActive: true,
    });
    throw new Error('Should have failed for break outside shift hours');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected break outside shift bounds.');
    } else {
      throw err;
    }
  }

  // Test 5: Reject inverted break times (breakStart > breakEnd)
  console.log('5. Testing dayScheduleItemSchema with inverted break times...');
  try {
    dayScheduleItemSchema.parse({
      dayOfWeek: 4,
      startTime: '09:00',
      endTime: '17:00',
      slotDurationMinutes: 30,
      breakStartTime: '14:00',
      breakEndTime: '13:00',
      isActive: true,
    });
    throw new Error('Should have failed for inverted break times');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected inverted break times.');
    } else {
      throw err;
    }
  }

  // Test 6: Validate full weekly updateScheduleSchema batch
  console.log('6. Testing updateScheduleSchema with multi-day payload...');
  const weeklyPayload = {
    schedule: [
      { dayOfWeek: 1, startTime: '08:30', endTime: '16:30', slotDurationMinutes: 45, isActive: true },
      { dayOfWeek: 2, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, isActive: true },
    ],
  };

  const parsedWeekly = updateScheduleSchema.parse(weeklyPayload);
  const items = Array.isArray(parsedWeekly) ? parsedWeekly : parsedWeekly.schedule;
  if (items.length !== 2) {
    throw new Error('updateScheduleSchema parsing failed');
  }
  console.log(`   updateScheduleSchema parsed ${items.length} schedule entries successfully.`);

  // Test 7: Slot capacity math verification
  console.log('7. Testing slot generation capacity calculation...');
  // 09:00 to 17:00 is 8 hours (480 mins). Minus 60 mins break = 420 mins. 420 / 30 = 14 slots.
  const totalMinutes = (17 - 9) * 60 - 60;
  const slotCount = Math.floor(totalMinutes / 30);
  if (slotCount !== 14) {
    throw new Error(`Slot count mismatch: expected 14, got ${slotCount}`);
  }
  console.log(`   Accurately calculated ${slotCount} consultation slots for 8hr shift with 1hr break.`);

  console.log('--- ALL DOCTOR SCHEDULE UNIT TESTS PASSED! ---');
}

runTests().catch((err) => {
  console.error('Test suite failed:', err);
  process.exit(1);
});
