"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.comparePassword = exports.hashPassword = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const constants_1 = require("../config/constants");
/**
 * Hash a plain text password using bcrypt
 */
const hashPassword = async (password) => {
    const salt = await bcryptjs_1.default.genSalt(constants_1.APP_CONSTANTS.PASSWORD_SALT_ROUNDS);
    return bcryptjs_1.default.hash(password, salt);
};
exports.hashPassword = hashPassword;
/**
 * Compare plain text password against a stored bcrypt hash
 */
const comparePassword = async (password, hash) => {
    return bcryptjs_1.default.compare(password, hash);
};
exports.comparePassword = comparePassword;
