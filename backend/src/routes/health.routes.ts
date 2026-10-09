import { Router, Request, Response } from 'express';
import { successResponse } from '../utils/api_response';
import { env } from '../config/env';

const router = Router();

router.get('/', (_req: Request, res: Response) => {
  successResponse(
    res,
    {
      status: 'healthy',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      environment: env.NODE_ENV,
      service: 'MediCare Connect REST API',
    },
    'MediCare Connect API service is operational'
  );
});

export const healthRoutes = router;
