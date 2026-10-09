"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authRateLimiter = exports.apiRateLimiter = exports.MemoryRateLimiter = void 0;
const api_response_1 = require("../utils/api_response");
class MemoryRateLimiter {
    store = new Map();
    windowMs;
    max;
    message;
    cleanupTimer = null;
    constructor(options) {
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
    sweep() {
        const now = Date.now();
        for (const [key, record] of this.store.entries()) {
            if (now > record.resetTime) {
                this.store.delete(key);
            }
        }
    }
    getMiddleware() {
        return (req, res, next) => {
            const now = Date.now();
            const ip = req.headers['x-forwarded-for']?.split(',')[0].trim() ||
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
            }
            else {
                record.count++;
            }
            const remaining = Math.max(0, this.max - record.count);
            const resetSeconds = Math.ceil((record.resetTime - now) / 1000);
            res.setHeader('X-RateLimit-Limit', this.max.toString());
            res.setHeader('X-RateLimit-Remaining', remaining.toString());
            res.setHeader('X-RateLimit-Reset', resetSeconds.toString());
            if (record.count > this.max) {
                res.setHeader('Retry-After', resetSeconds.toString());
                (0, api_response_1.errorResponse)(res, `${this.message} Try again in ${resetSeconds}s.`, 'RATE_LIMIT_EXCEEDED', 429);
                return;
            }
            next();
        };
    }
    reset(ip) {
        if (ip) {
            this.store.delete(ip);
        }
        else {
            this.store.clear();
        }
    }
    getRecord(ip) {
        return this.store.get(ip);
    }
}
exports.MemoryRateLimiter = MemoryRateLimiter;
/**
 * Standard API rate limiter: 1,000 requests per 15-minute window
 */
exports.apiRateLimiter = new MemoryRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 1000,
    message: 'General API request limit reached.',
}).getMiddleware();
/**
 * Strict authentication & security rate limiter: 15 requests per 15-minute window
 */
exports.authRateLimiter = new MemoryRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 15,
    message: 'Too many authentication attempts.',
}).getMiddleware();
