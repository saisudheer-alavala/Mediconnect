"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authRoutes = void 0;
const express_1 = require("express");
const auth_controller_1 = require("../controllers/auth.controller");
const validate_middleware_1 = require("../middleware/validate.middleware");
const auth_middleware_1 = require("../middleware/auth.middleware");
const auth_validator_1 = require("../validators/auth.validator");
const rate_limit_middleware_1 = require("../middleware/rate_limit.middleware");
const router = (0, express_1.Router)();
// Registration with brute-force / flood protection
router.post('/register/patient', rate_limit_middleware_1.authRateLimiter, (0, validate_middleware_1.validateRequest)(auth_validator_1.patientRegisterSchema), auth_controller_1.authController.registerPatient);
router.post('/register/doctor', rate_limit_middleware_1.authRateLimiter, (0, validate_middleware_1.validateRequest)(auth_validator_1.doctorRegisterSchema), auth_controller_1.authController.registerDoctor);
// Login & Token Rotation
router.post('/login', rate_limit_middleware_1.authRateLimiter, (0, validate_middleware_1.validateRequest)(auth_validator_1.loginSchema), auth_controller_1.authController.login);
router.post('/refresh-token', (0, validate_middleware_1.validateRequest)(auth_validator_1.refreshTokenSchema), auth_controller_1.authController.refreshToken);
// Protected User Profile
router.get('/me', auth_middleware_1.authenticateJwt, auth_controller_1.authController.getCurrentUser);
exports.authRoutes = router;
