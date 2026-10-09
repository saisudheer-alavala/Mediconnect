import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { errorResponse } from '../utils/api_response';

export const validateRequest = (schema: ZodSchema) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      req.body = schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const validationErrors = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message,
        }));
        errorResponse(
          res,
          'Input validation failed. Please check the submitted fields.',
          'VALIDATION_ERROR',
          422,
          validationErrors
        );
        return;
      }
      next(error);
    }
  };
};
