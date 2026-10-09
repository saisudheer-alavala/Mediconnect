import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth.service';
import { successResponse } from '../utils/api_response';

export class AuthController {
  async registerPatient(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await authService.registerPatient(req.body);
      successResponse(res, result, 'Patient registered successfully.', 201);
    } catch (error) {
      next(error);
    }
  }

  async registerDoctor(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await authService.registerDoctor(req.body);
      successResponse(res, result, 'Doctor application submitted successfully.', 201);
    } catch (error) {
      next(error);
    }
  }

  async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await authService.login(req.body);
      successResponse(res, result, 'Logged in successfully.', 200);
    } catch (error) {
      next(error);
    }
  }

  async refreshToken(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await authService.refreshToken(req.body.refreshToken);
      successResponse(res, result, 'Access token refreshed successfully.', 200);
    } catch (error) {
      next(error);
    }
  }

  async getCurrentUser(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const user = await authService.getCurrentUser(userId);
      successResponse(res, user, 'User profile retrieved successfully.', 200);
    } catch (error) {
      next(error);
    }
  }
}

export const authController = new AuthController();
