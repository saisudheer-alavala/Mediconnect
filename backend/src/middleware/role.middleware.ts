import { Request, Response, NextFunction } from 'express';
import { UserRole } from '@prisma/client';
import { errorResponse } from '../utils/api_response';

export const requireRoles = (...allowedRoles: UserRole[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      errorResponse(res, 'Authentication required before checking permissions.', 'UNAUTHORIZED', 401);
      return;
    }

    if (!allowedRoles.includes(req.user.role)) {
      errorResponse(
        res,
        `Access denied. Required role: [${allowedRoles.join(', ')}]. Your role: ${req.user.role}.`,
        'FORBIDDEN',
        403
      );
      return;
    }

    next();
  };
};
