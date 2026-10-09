"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.healthRecordController = exports.HealthRecordController = void 0;
const health_record_service_1 = require("../services/health_record.service");
const api_response_1 = require("../utils/api_response");
class HealthRecordController {
    async getMyRecords(req, res) {
        try {
            const user = req.user;
            const query = {
                category: req.query.category,
                patientId: req.query.patientId,
                search: req.query.search,
            };
            const records = await health_record_service_1.healthRecordService.getMyRecords(user, query);
            (0, api_response_1.successResponse)(res, records, 'Health records retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve health records', 'GET_HEALTH_RECORDS_ERROR', 400);
        }
    }
    async getRecordById(req, res) {
        try {
            const user = req.user;
            const { id } = req.params;
            const record = await health_record_service_1.healthRecordService.getRecordById(user, id);
            (0, api_response_1.successResponse)(res, record, 'Health record details retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve health record', 'GET_HEALTH_RECORD_DETAILS_ERROR', 404);
        }
    }
    async createRecord(req, res) {
        try {
            const user = req.user;
            const record = await health_record_service_1.healthRecordService.createRecord(user, req.body, req.body.patientId);
            (0, api_response_1.successResponse)(res, record, 'Health record created successfully', 201);
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to create health record', 'CREATE_HEALTH_RECORD_ERROR', 400);
        }
    }
    async updateRecord(req, res) {
        try {
            const user = req.user;
            const { id } = req.params;
            const record = await health_record_service_1.healthRecordService.updateRecord(user, id, req.body);
            (0, api_response_1.successResponse)(res, record, 'Health record updated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to update health record', 'UPDATE_HEALTH_RECORD_ERROR', 400);
        }
    }
    async deleteRecord(req, res) {
        try {
            const user = req.user;
            const { id } = req.params;
            await health_record_service_1.healthRecordService.deleteRecord(user, id);
            (0, api_response_1.successResponse)(res, null, 'Health record deleted successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to delete health record', 'DELETE_HEALTH_RECORD_ERROR', 400);
        }
    }
}
exports.HealthRecordController = HealthRecordController;
exports.healthRecordController = new HealthRecordController();
