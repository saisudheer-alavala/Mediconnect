"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prescriptionRoutes = void 0;
const express_1 = require("express");
const client_1 = require("@prisma/client");
const prescription_controller_1 = require("../controllers/prescription.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const role_middleware_1 = require("../middleware/role.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const prescription_validator_1 = require("../validators/prescription.validator");
const router = (0, express_1.Router)();
// Protect all prescription routes
router.use(auth_middleware_1.authenticateJwt);
// Issue prescription (Doctors only)
router.post('/', (0, role_middleware_1.requireRoles)(client_1.UserRole.DOCTOR), (0, validate_middleware_1.validateRequest)(prescription_validator_1.createPrescriptionSchema), prescription_controller_1.prescriptionController.issuePrescription);
// Get my prescriptions (Patient or Doctor)
router.get('/my', prescription_controller_1.prescriptionController.getMyPrescriptions);
// Get prescription for appointment
router.get('/appointment/:appointmentId', prescription_controller_1.prescriptionController.getPrescriptionByAppointmentId);
// Get prescription details by ID
router.get('/:id', prescription_controller_1.prescriptionController.getPrescriptionById);
exports.prescriptionRoutes = router;
