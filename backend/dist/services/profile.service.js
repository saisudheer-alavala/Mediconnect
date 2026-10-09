"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.profileService = exports.ProfileService = void 0;
const profile_repository_1 = require("../repositories/profile.repository");
const password_1 = require("../utils/password");
const audit_service_1 = require("./audit.service");
class ProfileService {
    /**
     * Retrieve full user profile
     */
    async getMyProfile(userId) {
        const user = await profile_repository_1.profileRepository.getProfile(userId);
        if (!user) {
            const error = new Error('User account not found');
            error.statusCode = 404;
            throw error;
        }
        return this.sanitizeUser(user);
    }
    /**
     * Update patient profile information
     */
    async updatePatientProfile(userId, input) {
        const user = await profile_repository_1.profileRepository.getProfile(userId);
        if (!user) {
            const error = new Error('User account not found');
            error.statusCode = 404;
            throw error;
        }
        if (user.role !== 'PATIENT' || !user.patientProfile) {
            const error = new Error('User is not registered as a patient');
            error.statusCode = 400;
            throw error;
        }
        const updated = await profile_repository_1.profileRepository.updatePatient(userId, input);
        await audit_service_1.auditService.log({
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
    async updateDoctorProfile(userId, input) {
        const user = await profile_repository_1.profileRepository.getProfile(userId);
        if (!user) {
            const error = new Error('User account not found');
            error.statusCode = 404;
            throw error;
        }
        if (user.role !== 'DOCTOR' || !user.doctorProfile) {
            const error = new Error('User is not registered as a doctor');
            error.statusCode = 400;
            throw error;
        }
        const updated = await profile_repository_1.profileRepository.updateDoctor(userId, input);
        await audit_service_1.auditService.log({
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
    async changePassword(userId, input) {
        const user = await profile_repository_1.profileRepository.getProfile(userId);
        if (!user) {
            const error = new Error('User account not found');
            error.statusCode = 404;
            throw error;
        }
        const isMatch = await (0, password_1.comparePassword)(input.currentPassword, user.passwordHash);
        if (!isMatch) {
            await audit_service_1.auditService.log({
                userId,
                action: 'PASSWORD_CHANGE_FAILED',
                resource: 'PROFILE',
                details: 'Incorrect current password provided',
            });
            const error = new Error('Current password does not match');
            error.statusCode = 400;
            throw error;
        }
        const newHash = await (0, password_1.hashPassword)(input.newPassword);
        await profile_repository_1.profileRepository.updatePassword(userId, newHash);
        await audit_service_1.auditService.log({
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
    async deactivateAccount(userId, input) {
        const user = await profile_repository_1.profileRepository.getProfile(userId);
        if (!user) {
            const error = new Error('User account not found');
            error.statusCode = 404;
            throw error;
        }
        const isMatch = await (0, password_1.comparePassword)(input.password, user.passwordHash);
        if (!isMatch) {
            await audit_service_1.auditService.log({
                userId,
                action: 'DEACTIVATE_ACCOUNT_FAILED',
                resource: 'PROFILE',
                details: 'Incorrect password provided for deactivation',
            });
            const error = new Error('Invalid password provided for account deactivation');
            error.statusCode = 400;
            throw error;
        }
        await profile_repository_1.profileRepository.deactivateUser(userId);
        await audit_service_1.auditService.log({
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
    sanitizeUser(user) {
        if (!user)
            return null;
        const { passwordHash, ...sanitized } = user;
        return sanitized;
    }
}
exports.ProfileService = ProfileService;
exports.profileService = new ProfileService();
