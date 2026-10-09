"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorResponse = exports.successResponse = void 0;
const successResponse = (res, data, message = 'Operation successful', statusCode = 200) => {
    const responseBody = {
        success: true,
        message,
        data,
    };
    return res.status(statusCode).json(responseBody);
};
exports.successResponse = successResponse;
const errorResponse = (res, message, code = 'BAD_REQUEST', statusCode = 400, errors) => {
    const responseBody = {
        success: false,
        message,
        code,
        ...(errors ? { errors } : {}),
    };
    return res.status(statusCode).json(responseBody);
};
exports.errorResponse = errorResponse;
