import { Request, Response } from 'express';
import { appointmentService } from '../services/appointment.service';
import { successResponse, errorResponse } from '../utils/api_response';
import { queryAppointmentsSchema } from '../validators/appointment.validator';

export class AppointmentController {
  async createAppointment(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const appointment = await appointmentService.createAppointment(userId, req.body);
      successResponse(res, appointment, 'Appointment booked successfully', 201);
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to book appointment', 'BOOK_APPOINTMENT_ERROR', 400);
    }
  }

  async getAppointments(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const filters = queryAppointmentsSchema.parse(req.query);
      const appointments = await appointmentService.getAppointments(user, filters);
      successResponse(res, appointments, 'Appointments retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve appointments', 'GET_APPOINTMENTS_ERROR', 400);
    }
  }

  async getAppointmentById(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const { id } = req.params;
      const appointment = await appointmentService.getAppointmentById(id, user);
      successResponse(res, appointment, 'Appointment retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve appointment', 'GET_APPOINTMENT_ERROR', 404);
    }
  }

  async updateStatus(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const { id } = req.params;
      const updated = await appointmentService.updateStatus(id, user, req.body);
      successResponse(res, updated, 'Appointment status updated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to update appointment status', 'UPDATE_STATUS_ERROR', 400);
    }
  }

  async getTeleconsultationSession(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const { id } = req.params;
      const session = await appointmentService.getTeleconsultationSession(id, user);
      successResponse(res, session, 'Teleconsultation session retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to initiate teleconsultation', 'TELECONSULTATION_ERROR', 400);
    }
  }
}

export const appointmentController = new AppointmentController();
