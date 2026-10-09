"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticateJwt = void 0;
const jwt_1 = require("../utils/jwt");
const api_response_1 = require("../utils/api_response");
const authenticateJwt = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        (0, api_response_1.errorResponse)(res, 'Authentication token missing or invalid format.', 'UNAUTHORIZED', 401);
        return;
    }
    const token = authHeader.split(' ')[1];
    const payload = (0, jwt_1.verifyAccessToken)(token);
    if (!payload) {
        (0, api_response_1.errorResponse)(res, 'Session expired or invalid authentication token.', 'UNAUTHORIZED', 401);
        return;
    }
    req.user = payload;
    next();
};
exports.authenticateJwt = authenticateJwt;
