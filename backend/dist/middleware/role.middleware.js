"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireRoles = void 0;
const api_response_1 = require("../utils/api_response");
const requireRoles = (...allowedRoles) => {
    return (req, res, next) => {
        if (!req.user) {
            (0, api_response_1.errorResponse)(res, 'Authentication required before checking permissions.', 'UNAUTHORIZED', 401);
            return;
        }
        if (!allowedRoles.includes(req.user.role)) {
            (0, api_response_1.errorResponse)(res, `Access denied. Required role: [${allowedRoles.join(', ')}]. Your role: ${req.user.role}.`, 'FORBIDDEN', 403);
            return;
        }
        next();
    };
};
exports.requireRoles = requireRoles;
