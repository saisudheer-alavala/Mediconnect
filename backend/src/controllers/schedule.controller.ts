import { Request, Response } from 'express';
import { scheduleService } from '../services/schedule.service';
import { updateScheduleSchema } from '../validators/schedule.validator';
import { successResponse, errorResponse } from '../utils/api_response';

export class ScheduleController {
  async getMySchedule(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const result = await scheduleService.getMySchedule(userId);
      successResponse(res, result, 'Doctor schedule retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve schedule', 'GET_SCHEDULE_ERROR', 400);
    }
  }

  async updateMySchedule(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const validated = updateScheduleSchema.parse(req.body);
      const result = await scheduleService.updateMySchedule(userId, validated);
      successResponse(res, result, 'Doctor schedule updated successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to update schedule', 'UPDATE_SCHEDULE_ERROR', 400);
    }
  }
}

export const scheduleController = new ScheduleController();
