import bcrypt from 'bcryptjs';
import { APP_CONSTANTS } from '../config/constants';

/**
 * Hash a plain text password using bcrypt
 */
export const hashPassword = async (password: string): Promise<string> => {
  const salt = await bcrypt.genSalt(APP_CONSTANTS.PASSWORD_SALT_ROUNDS);
  return bcrypt.hash(password, salt);
};

/**
 * Compare plain text password against a stored bcrypt hash
 */
export const comparePassword = async (password: string, hash: string): Promise<boolean> => {
  return bcrypt.compare(password, hash);
};
