import { Request, Response, NextFunction } from 'express';
import { errorResponse } from '../utils/api_response';
import { env } from '../config/env';

export const errorHandler = (
  err: Error & { statusCode?: number; code?: string },
  _req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction
): void => {
  if (env.NODE_ENV === 'development') {
    console.error('Unhandled Server Error:', err);
  }

  const statusCode = err.statusCode || 500;
  const message =
    statusCode === 500 && env.NODE_ENV === 'production'
      ? 'An unexpected internal server error occurred.'
      : err.message || 'Internal Server Error';
  const code = err.code || 'INTERNAL_SERVER_ERROR';

  errorResponse(res, message, code, statusCode);
};
