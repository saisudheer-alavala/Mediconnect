import { Request, Response } from 'express';
import { emergencyService } from '../services/emergency.service';
import { successResponse, errorResponse } from '../utils/api_response';

export class EmergencyController {
  async getEmergencyProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const profile = await emergencyService.getEmergencyProfile(userId);
      successResponse(res, profile, 'Emergency medical profile retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve emergency profile', 'GET_EMERGENCY_PROFILE_ERROR', 400);
    }
  }

  async getEmergencyContacts(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const contacts = await emergencyService.getEmergencyContacts(userId);
      successResponse(res, contacts, 'Emergency contacts retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve emergency contacts', 'GET_EMERGENCY_CONTACTS_ERROR', 400);
    }
  }

  async addEmergencyContact(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const contact = await emergencyService.addEmergencyContact(userId, req.body);
      successResponse(res, contact, 'Emergency contact added successfully', 201);
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to add emergency contact', 'ADD_EMERGENCY_CONTACT_ERROR', 400);
    }
  }

  async updateEmergencyContact(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { contactId } = req.params;
      const contact = await emergencyService.updateEmergencyContact(userId, contactId, req.body);
      successResponse(res, contact, 'Emergency contact updated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to update emergency contact', 'UPDATE_EMERGENCY_CONTACT_ERROR', 400);
    }
  }

  async deleteEmergencyContact(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { contactId } = req.params;
      await emergencyService.deleteEmergencyContact(userId, contactId);
      successResponse(res, null, 'Emergency contact removed successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to delete emergency contact', 'DELETE_EMERGENCY_CONTACT_ERROR', 400);
    }
  }

  async updateMedicalProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const profile = await emergencyService.updateMedicalProfile(userId, req.body);
      successResponse(res, profile, 'Medical profile updated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to update medical profile', 'UPDATE_MEDICAL_PROFILE_ERROR', 400);
    }
  }
}

export const emergencyController = new EmergencyController();
