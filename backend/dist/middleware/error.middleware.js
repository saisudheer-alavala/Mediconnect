"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = void 0;
const api_response_1 = require("../utils/api_response");
const env_1 = require("../config/env");
const errorHandler = (err, _req, res, 
// eslint-disable-next-line @typescript-eslint/no-unused-vars
_next) => {
    if (env_1.env.NODE_ENV === 'development') {
        console.error('Unhandled Server Error:', err);
    }
    const statusCode = err.statusCode || 500;
    const message = statusCode === 500 && env_1.env.NODE_ENV === 'production'
        ? 'An unexpected internal server error occurred.'
        : err.message || 'Internal Server Error';
    const code = err.code || 'INTERNAL_SERVER_ERROR';
    (0, api_response_1.errorResponse)(res, message, code, statusCode);
};
exports.errorHandler = errorHandler;
