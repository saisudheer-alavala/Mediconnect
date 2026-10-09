"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApp = void 0;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const env_1 = require("./config/env");
const routes_1 = require("./routes");
const error_middleware_1 = require("./middleware/error.middleware");
const rate_limit_middleware_1 = require("./middleware/rate_limit.middleware");
const api_response_1 = require("./utils/api_response");
const createApp = () => {
    const app = (0, express_1.default)();
    // 1. HTTP Security Headers (Helmet Hardening)
    app.use((0, helmet_1.default)({
        crossOriginResourcePolicy: { policy: 'cross-origin' },
        hsts: { maxAge: 31536000, includeSubDomains: true },
        frameguard: { action: 'deny' },
        noSniff: true,
        xssFilter: true,
    }));
    // 2. Production CORS Hardening
    const allowedOrigins = [
        env_1.env.CLIENT_URL,
        'http://localhost:3000',
        'http://localhost:5000',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:5000',
        'http://10.0.2.2:5000', // Android Emulator Host Loopback
    ];
    app.use((0, cors_1.default)({
        origin: (origin, callback) => {
            // Allow mobile apps, curl, Postman (requests with no origin)
            if (!origin)
                return callback(null, true);
            if (env_1.env.NODE_ENV === 'development' || allowedOrigins.includes(origin)) {
                return callback(null, true);
            }
            return callback(new Error(`CORS blocked for origin: ${origin}`));
        },
        credentials: true,
        methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin'],
    }));
    // 3. Request Logging
    app.use((0, morgan_1.default)(env_1.env.NODE_ENV === 'development' ? 'dev' : 'combined'));
    // 4. Strict Body Parsers & Size Limits
    app.use(express_1.default.json({ limit: '10mb' }));
    app.use(express_1.default.urlencoded({ extended: true, limit: '10mb' }));
    // 5. Global API Rate Limiter
    app.use('/api/v1', rate_limit_middleware_1.apiRateLimiter);
    // 6. API V1 Routes
    app.use('/api/v1', routes_1.apiRouter);
    // 7. 404 Route Catch-All
    app.use((req, res) => {
        (0, api_response_1.errorResponse)(res, `Route not found: ${req.method} ${req.originalUrl}`, 'NOT_FOUND', 404);
    });
    // 8. Global Error Handler
    app.use(error_middleware_1.errorHandler);
    return app;
};
exports.createApp = createApp;
