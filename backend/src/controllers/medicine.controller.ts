import { Request, Response } from 'express';
import { medicineService } from '../services/medicine.service';
import { successResponse, errorResponse } from '../utils/api_response';

export class MedicineController {
  async createMedicine(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const medicine = await medicineService.createMedicine(userId, req.body);
      successResponse(res, medicine, 'Medicine regimen created successfully', 201);
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to create medicine regimen', 'CREATE_MEDICINE_ERROR', 400);
    }
  }

  async getMedicines(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const activeOnly = req.query.activeOnly === 'true';
      const medicines = await medicineService.getMedicines(userId, activeOnly);
      successResponse(res, medicines, 'Medicines retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve medicines', 'GET_MEDICINES_ERROR', 400);
    }
  }

  async getTodayMedicines(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const dateStr = req.query.date as string | undefined;
      const schedule = await medicineService.getTodayMedicines(userId, dateStr);
      successResponse(res, schedule, "Today's medicine schedule retrieved successfully");
    } catch (error: any) {
      errorResponse(res, error.message || "Failed to retrieve today's medicine schedule", 'GET_TODAY_ERROR', 400);
    }
  }

  async getAdherenceReport(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const days = req.query.days ? parseInt(req.query.days as string, 10) : 7;
      const report = await medicineService.getAdherenceReport(userId, days);
      successResponse(res, report, 'Adherence report retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve adherence report', 'GET_ADHERENCE_ERROR', 400);
    }
  }

  async getMedicineById(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const medicine = await medicineService.getMedicineById(userId, id);
      successResponse(res, medicine, 'Medicine details retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve medicine details', 'GET_MEDICINE_ERROR', 404);
    }
  }

  async updateMedicine(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const updated = await medicineService.updateMedicine(userId, id, req.body);
      successResponse(res, updated, 'Medicine regimen updated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to update medicine regimen', 'UPDATE_MEDICINE_ERROR', 400);
    }
  }

  async deleteMedicine(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const result = await medicineService.deleteMedicine(userId, id);
      successResponse(res, result, 'Medicine regimen discontinued successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to discontinue medicine', 'DELETE_MEDICINE_ERROR', 400);
    }
  }

  async logDose(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const log = await medicineService.logDose(userId, id, req.body);
      successResponse(res, log, 'Medicine dose logged successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to log medicine dose', 'LOG_DOSE_ERROR', 400);
    }
  }
}

export const medicineController = new MedicineController();
