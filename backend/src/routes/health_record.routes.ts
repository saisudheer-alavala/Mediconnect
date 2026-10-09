import { Router } from 'express';
import { healthRecordController } from '../controllers/health_record.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validate.middleware';
import {
  createHealthRecordSchema,
  updateHealthRecordSchema,
} from '../validators/health_record.validator';

const router = Router();

// Protect all health records routes
router.use(authenticateJwt);

// Health Records CRUD
router.get('/', healthRecordController.getMyRecords);
router.post(
  '/',
  validateRequest(createHealthRecordSchema),
  healthRecordController.createRecord
);
router.get('/:id', healthRecordController.getRecordById);
router.put(
  '/:id',
  validateRequest(updateHealthRecordSchema),
  healthRecordController.updateRecord
);
router.delete('/:id', healthRecordController.deleteRecord);

export const healthRecordRoutes = router;
