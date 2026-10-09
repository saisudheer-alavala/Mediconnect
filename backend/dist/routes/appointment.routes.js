"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.appointmentRoutes = void 0;
const express_1 = require("express");
const client_1 = require("@prisma/client");
const appointment_controller_1 = require("../controllers/appointment.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const role_middleware_1 = require("../middleware/role.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const appointment_validator_1 = require("../validators/appointment.validator");
const router = (0, express_1.Router)();
// Protect all appointment routes
router.use(auth_middleware_1.authenticateJwt);
// Book appointment (Patients only)
router.post('/', (0, role_middleware_1.requireRoles)(client_1.UserRole.PATIENT), (0, validate_middleware_1.validateRequest)(appointment_validator_1.createAppointmentSchema), (req, res) => appointment_controller_1.appointmentController.createAppointment(req, res));
// Get appointments for authenticated patient or doctor
router.get('/', (req, res) => appointment_controller_1.appointmentController.getAppointments(req, res));
// Appointment details
router.get('/:id', (req, res) => appointment_controller_1.appointmentController.getAppointmentById(req, res));
// Transition appointment status (Confirm, Cancel, Complete, No-Show)
router.patch('/:id/status', (0, validate_middleware_1.validateRequest)(appointment_validator_1.updateAppointmentStatusSchema), (req, res) => appointment_controller_1.appointmentController.updateStatus(req, res));
// Get teleconsultation session room metadata
router.get('/:id/teleconsultation', (req, res) => appointment_controller_1.appointmentController.getTeleconsultationSession(req, res));
exports.appointmentRoutes = router;
