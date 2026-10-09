import { profileRepository } from '../repositories/profile.repository';
import { hashPassword, comparePassword } from '../utils/password';
import {
  UpdatePatientProfileInput,
  UpdateDoctorProfileInput,
  ChangePasswordInput,
  DeactivateAccountInput,
} from '../validators/profile.validator';
import { auditService } from './audit.service';

export class ProfileService {
  /**
   * Retrieve full user profile
   */
  async getMyProfile(userId: string) {
    const user = await profileRepository.getProfile(userId);
    if (!user) {
      const error = new Error('User account not found');
      (error as Error & { statusCode: number }).statusCode = 404;
      throw error;
    }
    return this.sanitizeUser(user);
  }

  /**
   * Update patient profile information
   */
  async updatePatientProfile(userId: string, input: UpdatePatientProfileInput) {
    const user = await profileRepository.getProfile(userId);
    if (!user) {
      const error = new Error('User account not found');
      (error as Error & { statusCode: number }).statusCode = 404;
      throw error;
    }

    if (user.role !== 'PATIENT' || !user.patientProfile) {
      const error = new Error('User is not registered as a patient');
      (error as Error & { statusCode: number }).statusCode = 400;
      throw error;
    }

    const updated = await profileRepository.updatePatient(userId, input);

    await auditService.log({
      userId,
      action: 'PATIENT_PROFILE_UPDATED',
      resource: 'PROFILE',
      details: `Patient profile details updated`,
    });

    return this.sanitizeUser(updated);
  }

  /**
   * Update doctor profile information
   */
  async updateDoctorProfile(userId: string, input: UpdateDoctorProfileInput) {
    const user = await profileRepository.getProfile(userId);
    if (!user) {
      const error = new Error('User account not found');
      (error as Error & { statusCode: number }).statusCode = 404;
      throw error;
    }

    if (user.role !== 'DOCTOR' || !user.doctorProfile) {
      const error = new Error('User is not registered as a doctor');
      (error as Error & { statusCode: number }).statusCode = 400;
      throw error;
    }

    const updated = await profileRepository.updateDoctor(userId, input);

    await auditService.log({
      userId,
      action: 'DOCTOR_PROFILE_UPDATED',
      resource: 'PROFILE',
      details: `Doctor professional details updated`,
    });

    return this.sanitizeUser(updated);
  }

  /**
   * Change account password with current password verification
   */
  async changePassword(userId: string, input: ChangePasswordInput) {
    const user = await profileRepository.getProfile(userId);
    if (!user) {
      const error = new Error('User account not found');
      (error as Error & { statusCode: number }).statusCode = 404;
      throw error;
    }

    const isMatch = await comparePassword(input.currentPassword, user.passwordHash);
    if (!isMatch) {
      await auditService.log({
        userId,
        action: 'PASSWORD_CHANGE_FAILED',
        resource: 'PROFILE',
        details: 'Incorrect current password provided',
      });
      const error = new Error('Current password does not match');
      (error as Error & { statusCode: number }).statusCode = 400;
      throw error;
    }

    const newHash = await hashPassword(input.newPassword);
    await profileRepository.updatePassword(userId, newHash);

    await auditService.log({
      userId,
      action: 'PASSWORD_CHANGED',
      resource: 'PROFILE',
      details: 'Account password changed successfully',
    });

    return { success: true, message: 'Password updated successfully' };
  }

  /**
   * Soft deactivate account after password verification
   */
  async deactivateAccount(userId: string, input: DeactivateAccountInput) {
    const user = await profileRepository.getProfile(userId);
    if (!user) {
      const error = new Error('User account not found');
      (error as Error & { statusCode: number }).statusCode = 404;
      throw error;
    }

    const isMatch = await comparePassword(input.password, user.passwordHash);
    if (!isMatch) {
      await auditService.log({
        userId,
        action: 'DEACTIVATE_ACCOUNT_FAILED',
        resource: 'PROFILE',
        details: 'Incorrect password provided for deactivation',
      });
      const error = new Error('Invalid password provided for account deactivation');
      (error as Error & { statusCode: number }).statusCode = 400;
      throw error;
    }

    await profileRepository.deactivateUser(userId);

    await auditService.log({
      userId,
      action: 'ACCOUNT_DEACTIVATED',
      resource: 'PROFILE',
      details: 'Account soft-deactivated upon user request',
    });

    return { success: true, message: 'Account deactivated successfully' };
  }

  /**
   * Strip sensitive fields (e.g. passwordHash) from response object
   */
  private sanitizeUser(user: any) {
    if (!user) return null;
    const { passwordHash, ...sanitized } = user;
    return sanitized;
  }
}

export const profileService = new ProfileService();
