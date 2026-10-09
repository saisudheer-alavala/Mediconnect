import { Request, Response } from 'express';
import { prescriptionService } from '../services/prescription.service';
import { successResponse, errorResponse } from '../utils/api_response';

export class PrescriptionController {
  async issuePrescription(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const prescription = await prescriptionService.issuePrescription(userId, req.body);
      successResponse(res, prescription, 'Prescription issued successfully', 201);
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to issue prescription', 'ISSUE_PRESCRIPTION_ERROR', 400);
    }
  }

  async getMyPrescriptions(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const list = await prescriptionService.getMyPrescriptions(user);
      successResponse(res, list, 'Prescriptions retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve prescriptions', 'GET_PRESCRIPTIONS_ERROR', 400);
    }
  }

  async getPrescriptionById(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const { id } = req.params;
      const prescription = await prescriptionService.getPrescriptionById(user, id);
      successResponse(res, prescription, 'Prescription details retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve prescription', 'GET_PRESCRIPTION_DETAILS_ERROR', 404);
    }
  }

  async getPrescriptionByAppointmentId(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const { appointmentId } = req.params;
      const prescription = await prescriptionService.getPrescriptionByAppointmentId(user, appointmentId);
      successResponse(res, prescription, 'Appointment prescription retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve appointment prescription', 'GET_APPOINTMENT_PRESCRIPTION_ERROR', 404);
    }
  }
}

export const prescriptionController = new PrescriptionController();
