"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.healthRecordRoutes = void 0;
const express_1 = require("express");
const health_record_controller_1 = require("../controllers/health_record.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const health_record_validator_1 = require("../validators/health_record.validator");
const router = (0, express_1.Router)();
// Protect all health records routes
router.use(auth_middleware_1.authenticateJwt);
// Health Records CRUD
router.get('/', health_record_controller_1.healthRecordController.getMyRecords);
router.post('/', (0, validate_middleware_1.validateRequest)(health_record_validator_1.createHealthRecordSchema), health_record_controller_1.healthRecordController.createRecord);
router.get('/:id', health_record_controller_1.healthRecordController.getRecordById);
router.put('/:id', (0, validate_middleware_1.validateRequest)(health_record_validator_1.updateHealthRecordSchema), health_record_controller_1.healthRecordController.updateRecord);
router.delete('/:id', health_record_controller_1.healthRecordController.deleteRecord);
exports.healthRecordRoutes = router;
