"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.apiRouter = void 0;
const express_1 = require("express");
const health_routes_1 = require("./health.routes");
const auth_routes_1 = require("./auth.routes");
const medicine_routes_1 = require("./medicine.routes");
const doctor_routes_1 = require("./doctor.routes");
const appointment_routes_1 = require("./appointment.routes");
const prescription_routes_1 = require("./prescription.routes");
const emergency_routes_1 = require("./emergency.routes");
const health_record_routes_1 = require("./health_record.routes");
const notification_routes_1 = require("./notification.routes");
const review_routes_1 = require("./review.routes");
const profile_routes_1 = require("./profile.routes");
const router = (0, express_1.Router)();
// Health Check
router.use('/health', health_routes_1.healthRoutes);
// Authentication & Identity
router.use('/auth', auth_routes_1.authRoutes);
// MediTrack — Medicine Regimen & Reminders
router.use('/medicines', medicine_routes_1.medicineRoutes);
// CareConnect — Doctor Directory & Search
router.use('/doctors', doctor_routes_1.doctorRoutes);
// CareConnect — Appointments Management
router.use('/appointments', appointment_routes_1.appointmentRoutes);
// CareConnect — Digital Prescriptions
router.use('/prescriptions', prescription_routes_1.prescriptionRoutes);
// Emergency & SOS Health Vault
router.use('/emergency', emergency_routes_1.emergencyRoutes);
// Health Records & Medical History Timeline
router.use('/health-records', health_record_routes_1.healthRecordRoutes);
// Notifications & Adherence Reminders
router.use('/notifications', notification_routes_1.notificationRoutes);
// Doctor Ratings & Patient Reviews
router.use('/reviews', review_routes_1.reviewRoutes);
// User Profile, Settings & Preferences
router.use('/profile', profile_routes_1.profileRoutes);
router.use('/users', profile_routes_1.profileRoutes);
exports.apiRouter = router;
