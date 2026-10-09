"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.doctorController = exports.DoctorController = void 0;
const doctor_service_1 = require("../services/doctor.service");
const api_response_1 = require("../utils/api_response");
const doctor_validator_1 = require("../validators/doctor.validator");
class DoctorController {
    async getSpecializations(_req, res) {
        try {
            const specializations = await doctor_service_1.doctorService.getSpecializations();
            (0, api_response_1.successResponse)(res, specializations, 'Specializations retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve specializations', 'GET_SPECIALIZATIONS_ERROR', 400);
        }
    }
    async getDoctors(req, res) {
        try {
            const parsedFilters = doctor_validator_1.searchDoctorSchema.parse(req.query);
            const result = await doctor_service_1.doctorService.searchDoctors(parsedFilters);
            (0, api_response_1.successResponse)(res, result, 'Doctors retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to search doctors', 'SEARCH_DOCTORS_ERROR', 400);
        }
    }
    async getDoctorById(req, res) {
        try {
            const { id } = req.params;
            const doctor = await doctor_service_1.doctorService.getDoctorById(id);
            (0, api_response_1.successResponse)(res, doctor, 'Doctor profile retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve doctor details', 'GET_DOCTOR_ERROR', 404);
        }
    }
    async getAvailableSlots(req, res) {
        try {
            const { id } = req.params;
            const { date } = doctor_validator_1.slotsQuerySchema.parse(req.query);
            const slots = await doctor_service_1.doctorService.getAvailableSlots(id, date);
            (0, api_response_1.successResponse)(res, slots, 'Available slots calculated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to calculate available slots', 'GET_SLOTS_ERROR', 400);
        }
    }
}
exports.DoctorController = DoctorController;
exports.doctorController = new DoctorController();
