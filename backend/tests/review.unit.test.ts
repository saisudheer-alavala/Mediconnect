import {
  createReviewSchema,
  reviewQuerySchema,
} from '../src/validators/review.validator';

async function runTests() {
  console.log('--- RUNNING DOCTOR RATINGS & REVIEWS UNIT TESTS ---');

  // Test 1: Valid review with 5 stars and feedback
  console.log('1. Testing createReviewSchema with 5 stars and thorough feedback...');
  const validReview = {
    rating: 5,
    title: 'Exceptional clinical guidance',
    comment: 'Dr. Sarah was extremely attentive and explained my medication schedule in detail.',
  };

  const parsed1 = createReviewSchema.parse(validReview);
  if (parsed1.rating !== 5 || parsed1.title !== 'Exceptional clinical guidance') {
    throw new Error('createReviewSchema failed for 5 star review');
  }
  console.log('   createReviewSchema validated 5-star review successfully.');

  // Test 2: Valid review with appointmentId UUID
  console.log('2. Testing createReviewSchema with appointmentId UUID...');
  const validWithAppt = {
    rating: 4,
    comment: 'Very thorough checkup and clear diagnosis.',
    appointmentId: 'c1234567-89ab-cdef-0123-456789abcdef',
  };

  const parsed2 = createReviewSchema.parse(validWithAppt);
  if (parsed2.rating !== 4 || parsed2.appointmentId !== 'c1234567-89ab-cdef-0123-456789abcdef') {
    throw new Error('createReviewSchema failed with appointmentId');
  }
  console.log('   createReviewSchema validated appointment-linked review successfully.');

  // Test 3: Reject rating > 5 or < 1
  console.log('3. Testing createReviewSchema with out-of-range rating (0 and 6 stars)...');
  try {
    createReviewSchema.parse({
      rating: 6,
      comment: 'Beyond 5 stars is invalid.',
    });
    throw new Error('Should have failed for rating > 5');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected rating of 6 stars.');
    } else {
      throw err;
    }
  }

  try {
    createReviewSchema.parse({
      rating: 0,
      comment: 'Zero star is invalid.',
    });
    throw new Error('Should have failed for rating < 1');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected rating of 0 stars.');
    } else {
      throw err;
    }
  }

  // Test 4: Reject too short comment (< 5 characters)
  console.log('4. Testing createReviewSchema with too short comment...');
  try {
    createReviewSchema.parse({
      rating: 5,
      comment: 'Good',
    });
    throw new Error('Should have failed for comment < 5 chars');
  } catch (err: any) {
    if (err.name === 'ZodError') {
      console.log('   Correctly rejected short review comment.');
    } else {
      throw err;
    }
  }

  // Test 5: Review query schema pagination defaults and transformations
  console.log('5. Testing reviewQuerySchema pagination and filtering...');
  const query = reviewQuerySchema.parse({
    page: '2',
    limit: '15',
    minRating: '4',
  });

  if (query.page !== 2 || query.limit !== 15 || query.minRating !== 4) {
    throw new Error('reviewQuerySchema transform failed');
  }
  console.log('   reviewQuerySchema transformed parameters successfully.');

  // Test 6: Rating summary breakdown and average calculation math
  console.log('6. Testing rating summary calculation logic...');
  const sampleRatings = [5, 5, 4, 3, 5, 4, 5, 2];
  let sum = 0;
  const breakdown = { stars5: 0, stars4: 0, stars3: 0, stars2: 0, stars1: 0 };
  for (const r of sampleRatings) {
    sum += r;
    if (r === 5) breakdown.stars5++;
    else if (r === 4) breakdown.stars4++;
    else if (r === 3) breakdown.stars3++;
    else if (r === 2) breakdown.stars2++;
    else if (r === 1) breakdown.stars1++;
  }
  const avg = Number((sum / sampleRatings.length).toFixed(1));

  if (avg !== 4.1 || breakdown.stars5 !== 4 || breakdown.stars4 !== 2) {
    throw new Error(`Rating summary calculation mismatch: avg=${avg}, breakdown=${JSON.stringify(breakdown)}`);
  }
  console.log(`   Calculated rating summary accurately: average=${avg}, 5-star count=${breakdown.stars5}.`);

  console.log('--- ALL DOCTOR RATINGS & REVIEWS UNIT TESTS PASSED! ---');
}

runTests().catch((err) => {
  console.error('Test suite failed:', err);
  process.exit(1);
});
