"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.env = void 0;
const dotenv_1 = __importDefault(require("dotenv"));
const zod_1 = require("zod");
dotenv_1.default.config();
const envSchema = zod_1.z.object({
    NODE_ENV: zod_1.z.enum(['development', 'production', 'test']).default('development'),
    PORT: zod_1.z.string().default('5000').transform((val) => parseInt(val, 10)),
    DATABASE_URL: zod_1.z.string().min(1, 'DATABASE_URL is required'),
    JWT_ACCESS_SECRET: zod_1.z.string().min(16, 'JWT_ACCESS_SECRET must be at least 16 chars'),
    JWT_REFRESH_SECRET: zod_1.z.string().min(16, 'JWT_REFRESH_SECRET must be at least 16 chars'),
    JWT_ACCESS_EXPIRES_IN: zod_1.z.string().default('15m'),
    JWT_REFRESH_EXPIRES_IN: zod_1.z.string().default('7d'),
    CLIENT_URL: zod_1.z.string().default('http://localhost:3000'),
});
const parseEnv = () => {
    const parsed = envSchema.safeParse(process.env);
    if (!parsed.success) {
        console.error('Invalid environment variables:');
        console.error(parsed.error.format());
        process.exit(1);
    }
    return parsed.data;
};
exports.env = parseEnv();
