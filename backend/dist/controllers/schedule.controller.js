"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.scheduleController = exports.ScheduleController = void 0;
const schedule_service_1 = require("../services/schedule.service");
const schedule_validator_1 = require("../validators/schedule.validator");
const api_response_1 = require("../utils/api_response");
class ScheduleController {
    async getMySchedule(req, res) {
        try {
            const userId = req.user.userId;
            const result = await schedule_service_1.scheduleService.getMySchedule(userId);
            (0, api_response_1.successResponse)(res, result, 'Doctor schedule retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve schedule', 'GET_SCHEDULE_ERROR', 400);
        }
    }
    async updateMySchedule(req, res) {
        try {
            const userId = req.user.userId;
            const validated = schedule_validator_1.updateScheduleSchema.parse(req.body);
            const result = await schedule_service_1.scheduleService.updateMySchedule(userId, validated);
            (0, api_response_1.successResponse)(res, result, 'Doctor schedule updated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to update schedule', 'UPDATE_SCHEDULE_ERROR', 400);
        }
    }
}
exports.ScheduleController = ScheduleController;
exports.scheduleController = new ScheduleController();
