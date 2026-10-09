import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../utils/jwt';
import { errorResponse } from '../utils/api_response';

export const authenticateJwt = (req: Request, res: Response, next: NextFunction): void => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    errorResponse(res, 'Authentication token missing or invalid format.', 'UNAUTHORIZED', 401);
    return;
  }

  const token = authHeader.split(' ')[1];
  const payload = verifyAccessToken(token);

  if (!payload) {
    errorResponse(res, 'Session expired or invalid authentication token.', 'UNAUTHORIZED', 401);
    return;
  }

  req.user = payload;
  next();
};
