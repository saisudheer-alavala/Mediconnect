import { Router } from 'express';
import { healthRoutes } from './health.routes';
import { authRoutes } from './auth.routes';
import { medicineRoutes } from './medicine.routes';
import { doctorRoutes } from './doctor.routes';
import { appointmentRoutes } from './appointment.routes';
import { prescriptionRoutes } from './prescription.routes';
import { emergencyRoutes } from './emergency.routes';
import { healthRecordRoutes } from './health_record.routes';
import { notificationRoutes } from './notification.routes';
import { reviewRoutes } from './review.routes';
import { profileRoutes } from './profile.routes';

import { successResponse } from '../utils/api_response';

const router = Router();

// Base API V1 Directory
router.get('/', (_req, res) => {
  successResponse(res, {
    name: 'MediCare Connect REST API',
    version: 'v1',
    endpoints: {
      health: '/api/v1/health',
      auth: '/api/v1/auth',
      medicines: '/api/v1/medicines',
      doctors: '/api/v1/doctors',
      appointments: '/api/v1/appointments',
      prescriptions: '/api/v1/prescriptions',
      emergency: '/api/v1/emergency',
      healthRecords: '/api/v1/health-records',
      notifications: '/api/v1/notifications',
      reviews: '/api/v1/reviews',
      profile: '/api/v1/profile',
    },
  }, 'MediCare Connect API v1 is active');
});

// Health Check
router.use('/health', healthRoutes);

// Authentication & Identity
router.use('/auth', authRoutes);

// MediTrack — Medicine Regimen & Reminders
router.use('/medicines', medicineRoutes);

// CareConnect — Doctor Directory & Search
router.use('/doctors', doctorRoutes);

// CareConnect — Appointments Management
router.use('/appointments', appointmentRoutes);

// CareConnect — Digital Prescriptions
router.use('/prescriptions', prescriptionRoutes);

// Emergency & SOS Health Vault
router.use('/emergency', emergencyRoutes);

// Health Records & Medical History Timeline
router.use('/health-records', healthRecordRoutes);

// Notifications & Adherence Reminders
router.use('/notifications', notificationRoutes);

// Doctor Ratings & Patient Reviews
router.use('/reviews', reviewRoutes);

// User Profile, Settings & Preferences
router.use('/profile', profileRoutes);
router.use('/users', profileRoutes);

export const apiRouter = router;


