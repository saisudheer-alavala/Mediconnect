"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.emergencyController = exports.EmergencyController = void 0;
const emergency_service_1 = require("../services/emergency.service");
const api_response_1 = require("../utils/api_response");
class EmergencyController {
    async getEmergencyProfile(req, res) {
        try {
            const userId = req.user.userId;
            const profile = await emergency_service_1.emergencyService.getEmergencyProfile(userId);
            (0, api_response_1.successResponse)(res, profile, 'Emergency medical profile retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve emergency profile', 'GET_EMERGENCY_PROFILE_ERROR', 400);
        }
    }
    async getEmergencyContacts(req, res) {
        try {
            const userId = req.user.userId;
            const contacts = await emergency_service_1.emergencyService.getEmergencyContacts(userId);
            (0, api_response_1.successResponse)(res, contacts, 'Emergency contacts retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve emergency contacts', 'GET_EMERGENCY_CONTACTS_ERROR', 400);
        }
    }
    async addEmergencyContact(req, res) {
        try {
            const userId = req.user.userId;
            const contact = await emergency_service_1.emergencyService.addEmergencyContact(userId, req.body);
            (0, api_response_1.successResponse)(res, contact, 'Emergency contact added successfully', 201);
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to add emergency contact', 'ADD_EMERGENCY_CONTACT_ERROR', 400);
        }
    }
    async updateEmergencyContact(req, res) {
        try {
            const userId = req.user.userId;
            const { contactId } = req.params;
            const contact = await emergency_service_1.emergencyService.updateEmergencyContact(userId, contactId, req.body);
            (0, api_response_1.successResponse)(res, contact, 'Emergency contact updated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to update emergency contact', 'UPDATE_EMERGENCY_CONTACT_ERROR', 400);
        }
    }
    async deleteEmergencyContact(req, res) {
        try {
            const userId = req.user.userId;
            const { contactId } = req.params;
            await emergency_service_1.emergencyService.deleteEmergencyContact(userId, contactId);
            (0, api_response_1.successResponse)(res, null, 'Emergency contact removed successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to delete emergency contact', 'DELETE_EMERGENCY_CONTACT_ERROR', 400);
        }
    }
    async updateMedicalProfile(req, res) {
        try {
            const userId = req.user.userId;
            const profile = await emergency_service_1.emergencyService.updateMedicalProfile(userId, req.body);
            (0, api_response_1.successResponse)(res, profile, 'Medical profile updated successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to update medical profile', 'UPDATE_MEDICAL_PROFILE_ERROR', 400);
        }
    }
}
exports.EmergencyController = EmergencyController;
exports.emergencyController = new EmergencyController();
