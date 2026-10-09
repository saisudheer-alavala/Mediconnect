import { Request, Response, NextFunction } from 'express';
import { errorResponse } from '../utils/api_response';

interface RateLimitRecord {
  count: number;
  resetTime: number;
}

export interface RateLimiterOptions {
  windowMs: number;
  max: number;
  message?: string;
}

export class MemoryRateLimiter {
  private store: Map<string, RateLimitRecord> = new Map();
  private readonly windowMs: number;
  private readonly max: number;
  private readonly message: string;
  private cleanupTimer: NodeJS.Timeout | null = null;

  constructor(options: RateLimiterOptions) {
    this.windowMs = options.windowMs;
    this.max = options.max;
    this.message = options.message || 'Too many requests from this IP. Please try again later.';

    // Periodically sweep expired entries to prevent memory leaks
    this.cleanupTimer = setInterval(() => {
      this.sweep();
    }, 60000);

    // Unref timer so it does not keep process alive during unit tests
    if (this.cleanupTimer.unref) {
      this.cleanupTimer.unref();
    }
  }

  private sweep(): void {
    const now = Date.now();
    for (const [key, record] of this.store.entries()) {
      if (now > record.resetTime) {
        this.store.delete(key);
      }
    }
  }

  public getMiddleware() {
    return (req: Request, res: Response, next: NextFunction): void => {
      const now = Date.now();
      const ip =
        (req.headers['x-forwarded-for'] as string)?.split(',')[0].trim() ||
        req.ip ||
        req.socket.remoteAddress ||
        'unknown-ip';

      let record = this.store.get(ip);

      if (!record || now > record.resetTime) {
        record = {
          count: 1,
          resetTime: now + this.windowMs,
        };
        this.store.set(ip, record);
      } else {
        record.count++;
      }

      const remaining = Math.max(0, this.max - record.count);
      const resetSeconds = Math.ceil((record.resetTime - now) / 1000);

      res.setHeader('X-RateLimit-Limit', this.max.toString());
      res.setHeader('X-RateLimit-Remaining', remaining.toString());
      res.setHeader('X-RateLimit-Reset', resetSeconds.toString());

      if (record.count > this.max) {
        res.setHeader('Retry-After', resetSeconds.toString());
        errorResponse(
          res,
          `${this.message} Try again in ${resetSeconds}s.`,
          'RATE_LIMIT_EXCEEDED',
          429
        );
        return;
      }

      next();
    };
  }

  public reset(ip?: string): void {
    if (ip) {
      this.store.delete(ip);
    } else {
      this.store.clear();
    }
  }

  public getRecord(ip: string): RateLimitRecord | undefined {
    return this.store.get(ip);
  }
}

/**
 * Standard API rate limiter: 1,000 requests per 15-minute window
 */
export const apiRateLimiter = new MemoryRateLimiter({
  windowMs: 15 * 60 * 1000,
  max: 1000,
  message: 'General API request limit reached.',
}).getMiddleware();

/**
 * Strict authentication & security rate limiter: 15 requests per 15-minute window
 */
export const authRateLimiter = new MemoryRateLimiter({
  windowMs: 15 * 60 * 1000,
  max: 15,
  message: 'Too many authentication attempts.',
}).getMiddleware();
