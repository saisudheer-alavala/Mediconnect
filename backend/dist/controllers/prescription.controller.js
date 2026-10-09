"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prescriptionController = exports.PrescriptionController = void 0;
const prescription_service_1 = require("../services/prescription.service");
const api_response_1 = require("../utils/api_response");
class PrescriptionController {
    async issuePrescription(req, res) {
        try {
            const userId = req.user.userId;
            const prescription = await prescription_service_1.prescriptionService.issuePrescription(userId, req.body);
            (0, api_response_1.successResponse)(res, prescription, 'Prescription issued successfully', 201);
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to issue prescription', 'ISSUE_PRESCRIPTION_ERROR', 400);
        }
    }
    async getMyPrescriptions(req, res) {
        try {
            const user = req.user;
            const list = await prescription_service_1.prescriptionService.getMyPrescriptions(user);
            (0, api_response_1.successResponse)(res, list, 'Prescriptions retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve prescriptions', 'GET_PRESCRIPTIONS_ERROR', 400);
        }
    }
    async getPrescriptionById(req, res) {
        try {
            const user = req.user;
            const { id } = req.params;
            const prescription = await prescription_service_1.prescriptionService.getPrescriptionById(user, id);
            (0, api_response_1.successResponse)(res, prescription, 'Prescription details retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve prescription', 'GET_PRESCRIPTION_DETAILS_ERROR', 404);
        }
    }
    async getPrescriptionByAppointmentId(req, res) {
        try {
            const user = req.user;
            const { appointmentId } = req.params;
            const prescription = await prescription_service_1.prescriptionService.getPrescriptionByAppointmentId(user, appointmentId);
            (0, api_response_1.successResponse)(res, prescription, 'Appointment prescription retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve appointment prescription', 'GET_APPOINTMENT_PRESCRIPTION_ERROR', 404);
        }
    }
}
exports.PrescriptionController = PrescriptionController;
exports.prescriptionController = new PrescriptionController();
