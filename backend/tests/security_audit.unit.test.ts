import jwt from 'jsonwebtoken';
import { signAccessToken, verifyAccessToken } from '../src/utils/jwt';
import { MemoryRateLimiter } from '../src/middleware/rate_limit.middleware';
import { requireRoles } from '../src/middleware/role.middleware';
import { UserRole } from '@prisma/client';
import { auditService } from '../src/services/audit.service';
import { env } from '../src/config/env';

async function runTests() {
  console.log('--- RUNNING SECURITY AUDIT & PRODUCTION HARDENING UNIT TESTS ---');

  // Test 1: JWT Signing & HS256 enforcement
  console.log('1. Testing JWT algorithm enforcement & tamper rejection...');
  const validUser = {
    userId: 'user-sec-01',
    email: 'audit@medicare.test',
    role: UserRole.PATIENT,
  };
  const token = signAccessToken(validUser);
  const decoded = verifyAccessToken(token);

  if (!decoded || decoded.userId !== validUser.userId || decoded.role !== UserRole.PATIENT) {
    throw new Error('Valid token failed verification');
  }
  console.log('   Valid HS256 JWT verified successfully.');

  // Test 1b: Reject tampered token
  const tamperedToken = token.slice(0, -6) + 'abcdef';
  const tamperedResult = verifyAccessToken(tamperedToken);
  if (tamperedResult !== null) {
    throw new Error('Tampered token should have been rejected');
  }
  console.log('   Tampered signature correctly rejected.');

  // Test 1c: Reject 'none' algorithm token
  const header = Buffer.from(JSON.stringify({ alg: 'none', typ: 'JWT' })).toString('base64url');
  const payload = Buffer.from(JSON.stringify(validUser)).toString('base64url');
  const noneAlgToken = `${header}.${payload}.`;
  const noneResult = verifyAccessToken(noneAlgToken);
  if (noneResult !== null) {
    throw new Error("Token with 'none' algorithm should have been rejected!");
  }
  console.log("   Unsigned 'none' algorithm token rejected as expected.");

  // Test 2: In-Memory Rate Limiter Test
  console.log('2. Testing MemoryRateLimiter thresholding and headers...');
  const testLimiter = new MemoryRateLimiter({
    windowMs: 5000,
    max: 3,
    message: 'Test limit reached',
  });
  const middleware = testLimiter.getMiddleware();

  let reqHeaders: Record<string, string> = { 'x-forwarded-for': '192.168.1.100' };
  let mockRes: any = {
    headers: {} as Record<string, string>,
    statusCode: 200,
    body: null as any,
    setHeader(key: string, val: string) {
      this.headers[key] = val;
    },
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    json(data: any) {
      this.body = data;
      return this;
    },
  };

  let nextCalled = 0;
  const mockNext = () => {
    nextCalled++;
  };

  // Calls 1, 2, 3 should pass
  middleware({ headers: reqHeaders } as any, mockRes, mockNext);
  middleware({ headers: reqHeaders } as any, mockRes, mockNext);
  middleware({ headers: reqHeaders } as any, mockRes, mockNext);

  if (nextCalled !== 3) {
    throw new Error(`Expected 3 next() calls, got ${nextCalled}`);
  }
  if (mockRes.headers['X-RateLimit-Remaining'] !== '0') {
    throw new Error(`Expected 0 remaining requests, got ${mockRes.headers['X-RateLimit-Remaining']}`);
  }
  console.log('   First 3 requests within limit allowed.');

  // 4th call should hit rate limit (429)
  middleware({ headers: reqHeaders } as any, mockRes, mockNext);
  if (nextCalled !== 3) {
    throw new Error('4th request should not have called next()');
  }
  if (mockRes.statusCode !== 429 || mockRes.body?.code !== 'RATE_LIMIT_EXCEEDED') {
    throw new Error(`Expected 429 RATE_LIMIT_EXCEEDED, got status ${mockRes.statusCode}`);
  }
  if (!mockRes.headers['Retry-After']) {
    throw new Error('Retry-After header missing on 429 response');
  }
  console.log('   4th request correctly blocked with 429 and Retry-After header.');

  // Test 3: Role-Based Access Control (RBAC)
  console.log('3. Testing requireRoles middleware authorization gates...');
  const doctorOnly = requireRoles(UserRole.DOCTOR);

  // Unauthorized patient attempt
  let rbacStatus = 200;
  let rbacBody: any = null;
  const patientReq: any = {
    user: { userId: 'p1', email: 'pat@med.com', role: UserRole.PATIENT },
  };
  const patientRes: any = {
    status(code: number) {
      rbacStatus = code;
      return this;
    },
    json(data: any) {
      rbacBody = data;
      return this;
    },
  };
  let rbacNext = false;
  doctorOnly(patientReq, patientRes, () => {
    rbacNext = true;
  });

  if (rbacNext || rbacStatus !== 403 || rbacBody?.code !== 'FORBIDDEN') {
    throw new Error('requireRoles failed to reject Patient accessing Doctor-only route');
  }
  console.log('   Patient blocked from Doctor-only endpoint with 403 FORBIDDEN.');

  // Authorized doctor attempt
  const doctorReq: any = {
    user: { userId: 'd1', email: 'doc@med.com', role: UserRole.DOCTOR },
  };
  let doctorAllowed = false;
  doctorOnly(doctorReq, patientRes, () => {
    doctorAllowed = true;
  });

  if (!doctorAllowed) {
    throw new Error('requireRoles failed to allow authorized Doctor');
  }
  console.log('   Doctor authorized successfully.');

  // Test 4: AuditService graceful logging
  console.log('4. Testing AuditService non-blocking logging...');
  // Testing that logging non-existent DB in test mode handles gracefully
  await auditService.log({
    userId: 'user-audit-test',
    action: 'SECURITY_AUDIT_VERIFIED',
    resource: 'TEST_SUITE',
    details: 'Automated Phase 19 verification test run',
  });
  console.log('   AuditService invocation executed gracefully.');

  console.log('--- ALL SECURITY AUDIT UNIT TESTS PASSED SUCCESSFULLY! ---');
}

runTests().catch((err) => {
  console.error('Security audit unit tests failed:', err);
  process.exit(1);
});
