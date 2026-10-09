"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.appointmentController = exports.AppointmentController = void 0;
const appointment_service_1 = require("../services/appointment.service");
const api_response_1 = require("../utils/api_response");
const appointment_validator_1 = require("../validators/appointment.validator");
class AppointmentController {
    async createAppointment(req, res) {
        try {
            const userId = req.user.userId;
            const appointment = await appointment_service_1.appointmentService.createAppointment(userId, req.body);
            (0, api_response_1.successResponse)(res, appointment, 'Appointment booked successfully', 201);
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to book appointment', 'BOOK_APPOINTMENT_ERROR', 400);
        }
    }
    async getAppointments(req, res) {
        try {
            const user = req.user;
            const filters = appointment_validator_1.queryAppointmentsSchema.parse(req.query);
            const appointments = await appointment_service_1.appointmentService.getAppointments(user, filters);
            (0, api_response_1.successResponse)(res, appointments, 'Appointments retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve appointments', 'GET_APPOINTMENTS_ERROR', 400);
        }
    }
    async getAppointmentById(req, res) {
        try {
            const user = req.user;
            const { id } = req.params;
            const appointment = await appointment_service_1.appointmentService.getAppointmentById(id, user);
            (0, api_response_1.successResponse)(res, appointment, 'Appointment retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve appointment', 'GET_APPOINTMENT_ERROR', 404);
        }
    }
    async updateStatus(req, res) {
        try {
            const user = req.user;
            const { id } = req.params;
            const updated = await appointment_service_1.appointmentService.updateStatus(id, user, req.body);
            (0, api_response_1.successResponse)(res, updated, 'Appointment status updated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to update appointment status', 'UPDATE_STATUS_ERROR', 400);
        }
    }
    async getTeleconsultationSession(req, res) {
        try {
            const user = req.user;
            const { id } = req.params;
            const session = await appointment_service_1.appointmentService.getTeleconsultationSession(id, user);
            (0, api_response_1.successResponse)(res, session, 'Teleconsultation session retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to initiate teleconsultation', 'TELECONSULTATION_ERROR', 400);
        }
    }
}
exports.AppointmentController = AppointmentController;
exports.appointmentController = new AppointmentController();
