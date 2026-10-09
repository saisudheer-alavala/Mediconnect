"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyRefreshToken = exports.verifyAccessToken = exports.signRefreshToken = exports.signAccessToken = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const env_1 = require("../config/env");
/**
 * Generate a short-lived Access Token (e.g., 15m) with enforced HS256 algorithm
 */
const signAccessToken = (payload) => {
    return jsonwebtoken_1.default.sign(payload, env_1.env.JWT_ACCESS_SECRET, {
        algorithm: 'HS256',
        expiresIn: env_1.env.JWT_ACCESS_EXPIRES_IN,
    });
};
exports.signAccessToken = signAccessToken;
/**
 * Generate a long-lived Refresh Token (e.g., 7d) with enforced HS256 algorithm
 */
const signRefreshToken = (payload) => {
    return jsonwebtoken_1.default.sign(payload, env_1.env.JWT_REFRESH_SECRET, {
        algorithm: 'HS256',
        expiresIn: env_1.env.JWT_REFRESH_EXPIRES_IN,
    });
};
exports.signRefreshToken = signRefreshToken;
/**
 * Verify and decode an Access Token, strictly restricting accepted algorithms to HS256
 */
const verifyAccessToken = (token) => {
    try {
        const decoded = jsonwebtoken_1.default.verify(token, env_1.env.JWT_ACCESS_SECRET, {
            algorithms: ['HS256'],
        });
        return decoded;
    }
    catch {
        return null;
    }
};
exports.verifyAccessToken = verifyAccessToken;
/**
 * Verify and decode a Refresh Token, strictly restricting accepted algorithms to HS256
 */
const verifyRefreshToken = (token) => {
    try {
        const decoded = jsonwebtoken_1.default.verify(token, env_1.env.JWT_REFRESH_SECRET, {
            algorithms: ['HS256'],
        });
        return decoded;
    }
    catch {
        return null;
    }
};
exports.verifyRefreshToken = verifyRefreshToken;
