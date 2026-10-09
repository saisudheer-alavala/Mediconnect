import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { env } from './config/env';
import { apiRouter } from './routes';
import { errorHandler } from './middleware/error.middleware';
import { apiRateLimiter } from './middleware/rate_limit.middleware';
import { errorResponse } from './utils/api_response';

export const createApp = (): Application => {
  const app = express();

  // 1. HTTP Security Headers (Helmet Hardening)
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: 'cross-origin' },
      hsts: { maxAge: 31536000, includeSubDomains: true },
      frameguard: { action: 'deny' },
      noSniff: true,
      xssFilter: true,
    })
  );

  // 2. Production CORS Hardening
  const allowedOrigins = [
    env.CLIENT_URL,
    'http://localhost:3000',
    'http://localhost:5000',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:5000',
    'http://10.0.2.2:5000', // Android Emulator Host Loopback
  ];

  app.use(
    cors({
      origin: (origin, callback) => {
        // Allow mobile apps, curl, Postman (requests with no origin)
        if (!origin) return callback(null, true);
        if (env.NODE_ENV === 'development' || allowedOrigins.includes(origin)) {
          return callback(null, true);
        }
        return callback(new Error(`CORS blocked for origin: ${origin}`));
      },
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin'],
    })
  );

  // 3. Request Logging
  app.use(morgan(env.NODE_ENV === 'development' ? 'dev' : 'combined'));

  // 4. Strict Body Parsers & Size Limits
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // 5. Global API Rate Limiter
  app.use('/api/v1', apiRateLimiter);

  // Root Redirect to API v1
  app.get('/', (_req: Request, res: Response) => {
    res.redirect('/api/v1');
  });

  // 6. API V1 Routes
  app.use('/api/v1', apiRouter);

  // 7. 404 Route Catch-All
  app.use((req: Request, res: Response) => {
    errorResponse(res, `Route not found: ${req.method} ${req.originalUrl}`, 'NOT_FOUND', 404);
  });

  // 8. Global Error Handler
  app.use(errorHandler);

  return app;
};
