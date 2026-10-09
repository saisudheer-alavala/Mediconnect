"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateRequest = void 0;
const zod_1 = require("zod");
const api_response_1 = require("../utils/api_response");
const validateRequest = (schema) => {
    return (req, res, next) => {
        try {
            req.body = schema.parse(req.body);
            next();
        }
        catch (error) {
            if (error instanceof zod_1.ZodError) {
                const validationErrors = error.errors.map((err) => ({
                    field: err.path.join('.'),
                    message: err.message,
                }));
                (0, api_response_1.errorResponse)(res, 'Input validation failed. Please check the submitted fields.', 'VALIDATION_ERROR', 422, validationErrors);
                return;
            }
            next(error);
        }
    };
};
exports.validateRequest = validateRequest;
