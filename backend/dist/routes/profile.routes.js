"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.profileRoutes = void 0;
const express_1 = require("express");
const profile_controller_1 = require("../controllers/profile.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const rate_limit_middleware_1 = require("../middleware/rate_limit.middleware");
const profile_validator_1 = require("../validators/profile.validator");
const router = (0, express_1.Router)();
// Protect all profile endpoints with JWT authentication
router.use(auth_middleware_1.authenticateJwt);
// Get authenticated user's profile
router.get('/me', profile_controller_1.profileController.getMyProfile);
// Update patient profile
router.put('/patient', (0, validate_middleware_1.validateRequest)(profile_validator_1.updatePatientProfileSchema), profile_controller_1.profileController.updatePatientProfile);
// Update doctor profile
router.put('/doctor', (0, validate_middleware_1.validateRequest)(profile_validator_1.updateDoctorProfileSchema), profile_controller_1.profileController.updateDoctorProfile);
// Change account password
router.post('/change-password', rate_limit_middleware_1.authRateLimiter, (0, validate_middleware_1.validateRequest)(profile_validator_1.changePasswordSchema), profile_controller_1.profileController.changePassword);
// Deactivate account
router.post('/deactivate', rate_limit_middleware_1.authRateLimiter, (0, validate_middleware_1.validateRequest)(profile_validator_1.deactivateAccountSchema), profile_controller_1.profileController.deactivateAccount);
exports.profileRoutes = router;
