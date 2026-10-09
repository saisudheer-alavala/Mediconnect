import { Request, Response } from 'express';
import { doctorService } from '../services/doctor.service';
import { successResponse, errorResponse } from '../utils/api_response';
import { searchDoctorSchema, slotsQuerySchema } from '../validators/doctor.validator';

export class DoctorController {
  async getSpecializations(_req: Request, res: Response): Promise<void> {
    try {
      const specializations = await doctorService.getSpecializations();
      successResponse(res, specializations, 'Specializations retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve specializations', 'GET_SPECIALIZATIONS_ERROR', 400);
    }
  }

  async getDoctors(req: Request, res: Response): Promise<void> {
    try {
      const parsedFilters = searchDoctorSchema.parse(req.query);
      const result = await doctorService.searchDoctors(parsedFilters);
      successResponse(res, result, 'Doctors retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to search doctors', 'SEARCH_DOCTORS_ERROR', 400);
    }
  }

  async getDoctorById(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const doctor = await doctorService.getDoctorById(id);
      successResponse(res, doctor, 'Doctor profile retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve doctor details', 'GET_DOCTOR_ERROR', 404);
    }
  }

  async getAvailableSlots(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const { date } = slotsQuerySchema.parse(req.query);
      const slots = await doctorService.getAvailableSlots(id, date);
      successResponse(res, slots, 'Available slots calculated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to calculate available slots', 'GET_SLOTS_ERROR', 400);
    }
  }
}

export const doctorController = new DoctorController();
