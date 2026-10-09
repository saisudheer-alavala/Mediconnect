"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.profileController = exports.ProfileController = void 0;
const profile_service_1 = require("../services/profile.service");
const api_response_1 = require("../utils/api_response");
class ProfileController {
    async getMyProfile(req, res) {
        try {
            const userId = req.user.userId;
            const profile = await profile_service_1.profileService.getMyProfile(userId);
            (0, api_response_1.successResponse)(res, profile, 'Profile retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve profile', 'GET_PROFILE_ERROR', error.statusCode || 400);
        }
    }
    async updatePatientProfile(req, res) {
        try {
            const userId = req.user.userId;
            const updated = await profile_service_1.profileService.updatePatientProfile(userId, req.body);
            (0, api_response_1.successResponse)(res, updated, 'Patient profile updated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to update patient profile', 'UPDATE_PATIENT_PROFILE_ERROR', error.statusCode || 400);
        }
    }
    async updateDoctorProfile(req, res) {
        try {
            const userId = req.user.userId;
            const updated = await profile_service_1.profileService.updateDoctorProfile(userId, req.body);
            (0, api_response_1.successResponse)(res, updated, 'Doctor profile updated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to update doctor profile', 'UPDATE_DOCTOR_PROFILE_ERROR', error.statusCode || 400);
        }
    }
    async changePassword(req, res) {
        try {
            const userId = req.user.userId;
            const result = await profile_service_1.profileService.changePassword(userId, req.body);
            (0, api_response_1.successResponse)(res, result, 'Password changed successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to change password', 'CHANGE_PASSWORD_ERROR', error.statusCode || 400);
        }
    }
    async deactivateAccount(req, res) {
        try {
            const userId = req.user.userId;
            const result = await profile_service_1.profileService.deactivateAccount(userId, req.body);
            (0, api_response_1.successResponse)(res, result, 'Account deactivated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to deactivate account', 'DEACTIVATE_ACCOUNT_ERROR', error.statusCode || 400);
        }
    }
}
exports.ProfileController = ProfileController;
exports.profileController = new ProfileController();
