"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.healthRoutes = void 0;
const express_1 = require("express");
const api_response_1 = require("../utils/api_response");
const env_1 = require("../config/env");
const router = (0, express_1.Router)();
router.get('/', (_req, res) => {
    (0, api_response_1.successResponse)(res, {
        status: 'healthy',
        uptime: process.uptime(),
        timestamp: new Date().toISOString(),
        environment: env_1.env.NODE_ENV,
        service: 'MediCare Connect REST API',
    }, 'MediCare Connect API service is operational');
});
exports.healthRoutes = router;
