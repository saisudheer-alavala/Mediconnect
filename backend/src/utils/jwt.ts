import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { AuthUserPayload } from '../types/express';

/**
 * Generate a short-lived Access Token (e.g., 15m) with enforced HS256 algorithm
 */
export const signAccessToken = (payload: AuthUserPayload): string => {
  return jwt.sign(payload, env.JWT_ACCESS_SECRET, {
    algorithm: 'HS256',
    expiresIn: env.JWT_ACCESS_EXPIRES_IN as jwt.SignOptions['expiresIn'],
  });
};

/**
 * Generate a long-lived Refresh Token (e.g., 7d) with enforced HS256 algorithm
 */
export const signRefreshToken = (payload: AuthUserPayload): string => {
  return jwt.sign(payload, env.JWT_REFRESH_SECRET, {
    algorithm: 'HS256',
    expiresIn: env.JWT_REFRESH_EXPIRES_IN as jwt.SignOptions['expiresIn'],
  });
};

/**
 * Verify and decode an Access Token, strictly restricting accepted algorithms to HS256
 */
export const verifyAccessToken = (token: string): AuthUserPayload | null => {
  try {
    const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET, {
      algorithms: ['HS256'],
    });
    return decoded as AuthUserPayload;
  } catch {
    return null;
  }
};

/**
 * Verify and decode a Refresh Token, strictly restricting accepted algorithms to HS256
 */
export const verifyRefreshToken = (token: string): AuthUserPayload | null => {
  try {
    const decoded = jwt.verify(token, env.JWT_REFRESH_SECRET, {
      algorithms: ['HS256'],
    });
    return decoded as AuthUserPayload;
  } catch {
    return null;
  }
};
