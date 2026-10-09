"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.medicineRoutes = void 0;
const express_1 = require("express");
const client_1 = require("@prisma/client");
const medicine_controller_1 = require("../controllers/medicine.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const role_middleware_1 = require("../middleware/role.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const medicine_validator_1 = require("../validators/medicine.validator");
const router = (0, express_1.Router)();
// Protect all medicine routes for authenticated Patients
router.use(auth_middleware_1.authenticateJwt);
router.use((0, role_middleware_1.requireRoles)(client_1.UserRole.PATIENT));
// Specific paths before parameterized /:id
router.get('/today', (req, res) => medicine_controller_1.medicineController.getTodayMedicines(req, res));
router.get('/adherence', (req, res) => medicine_controller_1.medicineController.getAdherenceReport(req, res));
// Collection routes
router.post('/', (0, validate_middleware_1.validateRequest)(medicine_validator_1.createMedicineSchema), (req, res) => medicine_controller_1.medicineController.createMedicine(req, res));
router.get('/', (req, res) => medicine_controller_1.medicineController.getMedicines(req, res));
// Item routes
router.get('/:id', (req, res) => medicine_controller_1.medicineController.getMedicineById(req, res));
router.put('/:id', (0, validate_middleware_1.validateRequest)(medicine_validator_1.updateMedicineSchema), (req, res) => medicine_controller_1.medicineController.updateMedicine(req, res));
router.delete('/:id', (req, res) => medicine_controller_1.medicineController.deleteMedicine(req, res));
// Dose logging
router.post('/:id/log', (0, validate_middleware_1.validateRequest)(medicine_validator_1.logDoseSchema), (req, res) => medicine_controller_1.medicineController.logDose(req, res));
exports.medicineRoutes = router;
