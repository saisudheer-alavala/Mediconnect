import { userRepository } from '../repositories/user.repository';
import { hashPassword, comparePassword } from '../utils/password';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../utils/jwt';
import { PatientRegisterInput, DoctorRegisterInput, LoginInput } from '../validators/auth.validator';
import { prisma } from '../config/database';
import { auditService } from './audit.service';

export class AuthService {
  /**
   * Register a new patient
   */
  async registerPatient(input: PatientRegisterInput) {
    const existing = await userRepository.findByEmail(input.email);
    if (existing) {
      const error = new Error('An account with this email address already exists.');
      (error as Error & { statusCode: number; code: string }).statusCode = 409;
      (error as Error & { statusCode: number; code: string }).code = 'EMAIL_ALREADY_EXISTS';
      throw error;
    }

    const passwordHash = await hashPassword(input.password);
    const dateOfBirth = input.dateOfBirth ? new Date(input.dateOfBirth) : undefined;

    const user = await userRepository.createPatient({
      email: input.email,
      passwordHash,
      phone: input.phone,
      fullName: input.fullName,
      dateOfBirth,
      gender: input.gender,
    });

    await auditService.log({
      userId: user.id,
      action: 'REGISTER_PATIENT',
      resource: 'AUTH',
      details: `Patient registered: ${input.email}`,
    });

    const tokens = {
      accessToken: signAccessToken({ userId: user.id, email: user.email, role: user.role }),
      refreshToken: signRefreshToken({ userId: user.id, email: user.email, role: user.role }),
    };

    const fullUser = await userRepository.findById(user.id);
    return {
      user: this.sanitizeUser(fullUser),
      tokens,
    };
  }

  /**
   * Register a new doctor
   */
  async registerDoctor(input: DoctorRegisterInput) {
    const existingEmail = await userRepository.findByEmail(input.email);
    if (existingEmail) {
      const error = new Error('An account with this email address already exists.');
      (error as Error & { statusCode: number; code: string }).statusCode = 409;
      (error as Error & { statusCode: number; code: string }).code = 'EMAIL_ALREADY_EXISTS';
      throw error;
    }

    // Check unique license number
    const existingLicense = await prisma.doctorProfile.findUnique({
      where: { licenseNumber: input.licenseNumber },
    });
    if (existingLicense) {
      const error = new Error('A doctor with this medical license number is already registered.');
      (error as Error & { statusCode: number; code: string }).statusCode = 409;
      (error as Error & { statusCode: number; code: string }).code = 'LICENSE_ALREADY_EXISTS';
      throw error;
    }

    const passwordHash = await hashPassword(input.password);

    const user = await userRepository.createDoctor({
      email: input.email,
      passwordHash,
      phone: input.phone,
      fullName: input.fullName,
      specializationName: input.specializationName,
      qualification: input.qualification,
      licenseNumber: input.licenseNumber,
      experienceYears: input.experienceYears,
      clinicName: input.clinicName,
      clinicAddress: input.clinicAddress,
    });

    await auditService.log({
      userId: user.id,
      action: 'REGISTER_DOCTOR',
      resource: 'AUTH',
      details: `Doctor applicant registered: ${input.email}, License: ${input.licenseNumber}`,
    });

    const tokens = {
      accessToken: signAccessToken({ userId: user.id, email: user.email, role: user.role }),
      refreshToken: signRefreshToken({ userId: user.id, email: user.email, role: user.role }),
    };

    const fullUser = await userRepository.findById(user.id);
    return {
      user: this.sanitizeUser(fullUser),
      tokens,
    };
  }

  /**
   * Authenticate user with email and password
   */
  async login(input: LoginInput) {
    const user = await userRepository.findByEmail(input.email);
    if (!user) {
      await auditService.log({
        userId: null,
        action: 'LOGIN_FAILURE',
        resource: 'AUTH',
        details: `Invalid email attempted: ${input.email}`,
      });
      const error = new Error('Invalid email or password.');
      (error as Error & { statusCode: number; code: string }).statusCode = 401;
      (error as Error & { statusCode: number; code: string }).code = 'INVALID_CREDENTIALS';
      throw error;
    }

    if (!user.isActive) {
      await auditService.log({
        userId: user.id,
        action: 'LOGIN_BLOCKED_DEACTIVATED',
        resource: 'AUTH',
        details: `Deactivated user attempt: ${input.email}`,
      });
      const error = new Error('This account has been deactivated. Please contact support.');
      (error as Error & { statusCode: number; code: string }).statusCode = 403;
      (error as Error & { statusCode: number; code: string }).code = 'ACCOUNT_DEACTIVATED';
      throw error;
    }

    const isValidPassword = await comparePassword(input.password, user.passwordHash);
    if (!isValidPassword) {
      await auditService.log({
        userId: user.id,
        action: 'LOGIN_FAILURE',
        resource: 'AUTH',
        details: `Incorrect password for user: ${input.email}`,
      });
      const error = new Error('Invalid email or password.');
      (error as Error & { statusCode: number; code: string }).statusCode = 401;
      (error as Error & { statusCode: number; code: string }).code = 'INVALID_CREDENTIALS';
      throw error;
    }

    await auditService.log({
      userId: user.id,
      action: 'LOGIN_SUCCESS',
      resource: 'AUTH',
      details: `Successful authentication: ${input.email}`,
    });

    const tokens = {
      accessToken: signAccessToken({ userId: user.id, email: user.email, role: user.role }),
      refreshToken: signRefreshToken({ userId: user.id, email: user.email, role: user.role }),
    };

    return {
      user: this.sanitizeUser(user),
      tokens,
    };
  }

  /**
   * Refresh an access token using a valid refresh token
   */
  async refreshToken(refreshToken: string) {
    const payload = verifyRefreshToken(refreshToken);
    if (!payload) {
      const error = new Error('Invalid or expired refresh token.');
      (error as Error & { statusCode: number; code: string }).statusCode = 401;
      (error as Error & { statusCode: number; code: string }).code = 'INVALID_TOKEN';
      throw error;
    }

    const user = await userRepository.findById(payload.userId);
    if (!user || !user.isActive) {
      const error = new Error('User no longer exists or is deactivated.');
      (error as Error & { statusCode: number; code: string }).statusCode = 401;
      (error as Error & { statusCode: number; code: string }).code = 'USER_NOT_FOUND';
      throw error;
    }

    const newAccessToken = signAccessToken({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    return {
      accessToken: newAccessToken,
    };
  }

  /**
   * Get user profile by ID
   */
  async getCurrentUser(userId: string) {
    const user = await userRepository.findById(userId);
    if (!user) {
      const error = new Error('User not found.');
      (error as Error & { statusCode: number; code: string }).statusCode = 404;
      (error as Error & { statusCode: number; code: string }).code = 'NOT_FOUND';
      throw error;
    }
    return this.sanitizeUser(user);
  }

  /**
   * Remove sensitive fields such as passwordHash before returning
   */
  private sanitizeUser(user: any) {
    if (!user) return null;
    const { passwordHash, ...sanitized } = user;
    return sanitized;
  }
}

export const authService = new AuthService();
