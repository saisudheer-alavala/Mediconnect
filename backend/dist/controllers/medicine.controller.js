"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.medicineController = exports.MedicineController = void 0;
const medicine_service_1 = require("../services/medicine.service");
const api_response_1 = require("../utils/api_response");
class MedicineController {
    async createMedicine(req, res) {
        try {
            const userId = req.user.userId;
            const medicine = await medicine_service_1.medicineService.createMedicine(userId, req.body);
            (0, api_response_1.successResponse)(res, medicine, 'Medicine regimen created successfully', 201);
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to create medicine regimen', 'CREATE_MEDICINE_ERROR', 400);
        }
    }
    async getMedicines(req, res) {
        try {
            const userId = req.user.userId;
            const activeOnly = req.query.activeOnly === 'true';
            const medicines = await medicine_service_1.medicineService.getMedicines(userId, activeOnly);
            (0, api_response_1.successResponse)(res, medicines, 'Medicines retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve medicines', 'GET_MEDICINES_ERROR', 400);
        }
    }
    async getTodayMedicines(req, res) {
        try {
            const userId = req.user.userId;
            const dateStr = req.query.date;
            const schedule = await medicine_service_1.medicineService.getTodayMedicines(userId, dateStr);
            (0, api_response_1.successResponse)(res, schedule, "Today's medicine schedule retrieved successfully");
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || "Failed to retrieve today's medicine schedule", 'GET_TODAY_ERROR', 400);
        }
    }
    async getAdherenceReport(req, res) {
        try {
            const userId = req.user.userId;
            const days = req.query.days ? parseInt(req.query.days, 10) : 7;
            const report = await medicine_service_1.medicineService.getAdherenceReport(userId, days);
            (0, api_response_1.successResponse)(res, report, 'Adherence report retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve adherence report', 'GET_ADHERENCE_ERROR', 400);
        }
    }
    async getMedicineById(req, res) {
        try {
            const userId = req.user.userId;
            const { id } = req.params;
            const medicine = await medicine_service_1.medicineService.getMedicineById(userId, id);
            (0, api_response_1.successResponse)(res, medicine, 'Medicine details retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve medicine details', 'GET_MEDICINE_ERROR', 404);
        }
    }
    async updateMedicine(req, res) {
        try {
            const userId = req.user.userId;
            const { id } = req.params;
            const updated = await medicine_service_1.medicineService.updateMedicine(userId, id, req.body);
            (0, api_response_1.successResponse)(res, updated, 'Medicine regimen updated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to update medicine regimen', 'UPDATE_MEDICINE_ERROR', 400);
        }
    }
    async deleteMedicine(req, res) {
        try {
            const userId = req.user.userId;
            const { id } = req.params;
            const result = await medicine_service_1.medicineService.deleteMedicine(userId, id);
            (0, api_response_1.successResponse)(res, result, 'Medicine regimen discontinued successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to discontinue medicine', 'DELETE_MEDICINE_ERROR', 400);
        }
    }
    async logDose(req, res) {
        try {
            const userId = req.user.userId;
            const { id } = req.params;
            const log = await medicine_service_1.medicineService.logDose(userId, id, req.body);
            (0, api_response_1.successResponse)(res, log, 'Medicine dose logged successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to log medicine dose', 'LOG_DOSE_ERROR', 400);
        }
    }
}
exports.MedicineController = MedicineController;
exports.medicineController = new MedicineController();
