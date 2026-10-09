"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authController = exports.AuthController = void 0;
const auth_service_1 = require("../services/auth.service");
const api_response_1 = require("../utils/api_response");
class AuthController {
    async registerPatient(req, res, next) {
        try {
            const result = await auth_service_1.authService.registerPatient(req.body);
            (0, api_response_1.successResponse)(res, result, 'Patient registered successfully.', 201);
        }
        catch (error) {
            next(error);
        }
    }
    async registerDoctor(req, res, next) {
        try {
            const result = await auth_service_1.authService.registerDoctor(req.body);
            (0, api_response_1.successResponse)(res, result, 'Doctor application submitted successfully.', 201);
        }
        catch (error) {
            next(error);
        }
    }
    async login(req, res, next) {
        try {
            const result = await auth_service_1.authService.login(req.body);
            (0, api_response_1.successResponse)(res, result, 'Logged in successfully.', 200);
        }
        catch (error) {
            next(error);
        }
    }
    async refreshToken(req, res, next) {
        try {
            const result = await auth_service_1.authService.refreshToken(req.body.refreshToken);
            (0, api_response_1.successResponse)(res, result, 'Access token refreshed successfully.', 200);
        }
        catch (error) {
            next(error);
        }
    }
    async getCurrentUser(req, res, next) {
        try {
            const userId = req.user.userId;
            const user = await auth_service_1.authService.getCurrentUser(userId);
            (0, api_response_1.successResponse)(res, user, 'User profile retrieved successfully.', 200);
        }
        catch (error) {
            next(error);
        }
    }
}
exports.AuthController = AuthController;
exports.authController = new AuthController();
