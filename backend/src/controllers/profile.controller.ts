import { Request, Response } from 'express';
import { profileService } from '../services/profile.service';
import { successResponse, errorResponse } from '../utils/api_response';

export class ProfileController {
  async getMyProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const profile = await profileService.getMyProfile(userId);
      successResponse(res, profile, 'Profile retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve profile', 'GET_PROFILE_ERROR', error.statusCode || 400);
    }
  }

  async updatePatientProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const updated = await profileService.updatePatientProfile(userId, req.body);
      successResponse(res, updated, 'Patient profile updated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to update patient profile', 'UPDATE_PATIENT_PROFILE_ERROR', error.statusCode || 400);
    }
  }

  async updateDoctorProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const updated = await profileService.updateDoctorProfile(userId, req.body);
      successResponse(res, updated, 'Doctor profile updated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to update doctor profile', 'UPDATE_DOCTOR_PROFILE_ERROR', error.statusCode || 400);
    }
  }

  async changePassword(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const result = await profileService.changePassword(userId, req.body);
      successResponse(res, result, 'Password changed successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to change password', 'CHANGE_PASSWORD_ERROR', error.statusCode || 400);
    }
  }

  async deactivateAccount(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const result = await profileService.deactivateAccount(userId, req.body);
      successResponse(res, result, 'Account deactivated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to deactivate account', 'DEACTIVATE_ACCOUNT_ERROR', error.statusCode || 400);
    }
  }
}

export const profileController = new ProfileController();
