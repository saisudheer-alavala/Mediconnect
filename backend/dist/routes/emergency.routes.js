"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.emergencyRoutes = void 0;
const express_1 = require("express");
const emergency_controller_1 = require("../controllers/emergency.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const emergency_validator_1 = require("../validators/emergency.validator");
const router = (0, express_1.Router)();
// Protect all emergency routes
router.use(auth_middleware_1.authenticateJwt);
// ICE / Medical Profile
router.get('/profile', emergency_controller_1.emergencyController.getEmergencyProfile);
router.put('/profile', (0, validate_middleware_1.validateRequest)(emergency_validator_1.updateMedicalIdSchema), emergency_controller_1.emergencyController.updateMedicalProfile);
// Emergency Contacts
router.get('/contacts', emergency_controller_1.emergencyController.getEmergencyContacts);
router.post('/contacts', (0, validate_middleware_1.validateRequest)(emergency_validator_1.createEmergencyContactSchema), emergency_controller_1.emergencyController.addEmergencyContact);
router.put('/contacts/:contactId', (0, validate_middleware_1.validateRequest)(emergency_validator_1.updateEmergencyContactSchema), emergency_controller_1.emergencyController.updateEmergencyContact);
router.delete('/contacts/:contactId', emergency_controller_1.emergencyController.deleteEmergencyContact);
exports.emergencyRoutes = router;
