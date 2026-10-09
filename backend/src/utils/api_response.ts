import { Response } from 'express';

export interface ApiResponse<T = unknown> {
  success: boolean;
  message: string;
  data?: T;
  code?: string;
  errors?: unknown;
}

export const successResponse = <T>(
  res: Response,
  data?: T,
  message = 'Operation successful',
  statusCode = 200
): Response => {
  const responseBody: ApiResponse<T> = {
    success: true,
    message,
    data,
  };
  return res.status(statusCode).json(responseBody);
};

export const errorResponse = (
  res: Response,
  message: string,
  code = 'BAD_REQUEST',
  statusCode = 400,
  errors?: unknown
): Response => {
  const responseBody: ApiResponse = {
    success: false,
    message,
    code,
    ...(errors ? { errors } : {}),
  };
  return res.status(statusCode).json(responseBody);
};
