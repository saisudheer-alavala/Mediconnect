import { Request, Response } from 'express';
import { healthRecordService } from '../services/health_record.service';
import { successResponse, errorResponse } from '../utils/api_response';
import { HealthRecordQueryInput } from '../validators/health_record.validator';

export class HealthRecordController {
  async getMyRecords(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const query: HealthRecordQueryInput = {
        category: req.query.category as any,
        patientId: req.query.patientId as string | undefined,
        search: req.query.search as string | undefined,
      };

      const records = await healthRecordService.getMyRecords(user, query);
      successResponse(res, records, 'Health records retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve health records', 'GET_HEALTH_RECORDS_ERROR', 400);
    }
  }

  async getRecordById(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const { id } = req.params;
      const record = await healthRecordService.getRecordById(user, id);
      successResponse(res, record, 'Health record details retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve health record', 'GET_HEALTH_RECORD_DETAILS_ERROR', 404);
    }
  }

  async createRecord(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const record = await healthRecordService.createRecord(user, req.body, req.body.patientId);
      successResponse(res, record, 'Health record created successfully', 201);
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to create health record', 'CREATE_HEALTH_RECORD_ERROR', 400);
    }
  }

  async updateRecord(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const { id } = req.params;
      const record = await healthRecordService.updateRecord(user, id, req.body);
      successResponse(res, record, 'Health record updated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to update health record', 'UPDATE_HEALTH_RECORD_ERROR', 400);
    }
  }

  async deleteRecord(req: Request, res: Response): Promise<void> {
    try {
      const user = req.user!;
      const { id } = req.params;
      await healthRecordService.deleteRecord(user, id);
      successResponse(res, null, 'Health record deleted successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to delete health record', 'DELETE_HEALTH_RECORD_ERROR', 400);
    }
  }
}

export const healthRecordController = new HealthRecordController();
