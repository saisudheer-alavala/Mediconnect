import { Router } from 'express';
import { UserRole } from '@prisma/client';
import { medicineController } from '../controllers/medicine.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { requireRoles } from '../middleware/role.middleware';
import { validateRequest } from '../middleware/validate.middleware';
import {
  createMedicineSchema,
  updateMedicineSchema,
  logDoseSchema,
} from '../validators/medicine.validator';

const router = Router();

// Protect all medicine routes for authenticated Patients
router.use(authenticateJwt);
router.use(requireRoles(UserRole.PATIENT));

// Specific paths before parameterized /:id
router.get('/today', (req, res) => medicineController.getTodayMedicines(req, res));
router.get('/adherence', (req, res) => medicineController.getAdherenceReport(req, res));

// Collection routes
router.post('/', validateRequest(createMedicineSchema), (req, res) =>
  medicineController.createMedicine(req, res)
);
router.get('/', (req, res) => medicineController.getMedicines(req, res));

// Item routes
router.get('/:id', (req, res) => medicineController.getMedicineById(req, res));
router.put('/:id', validateRequest(updateMedicineSchema), (req, res) =>
  medicineController.updateMedicine(req, res)
);
router.delete('/:id', (req, res) => medicineController.deleteMedicine(req, res));

// Dose logging
router.post('/:id/log', validateRequest(logDoseSchema), (req, res) =>
  medicineController.logDose(req, res)
);

export const medicineRoutes = router;
