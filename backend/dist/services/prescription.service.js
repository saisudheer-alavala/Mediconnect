"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prescriptionService = exports.PrescriptionService = void 0;
const client_1 = require("@prisma/client");
const prescription_repository_1 = require("../repositories/prescription.repository");
class PrescriptionService {
    async issuePrescription(userId, input) {
        const doctor = await prescription_repository_1.prescriptionRepository.findDoctorProfileByUserId(userId);
        if (!doctor) {
            throw new Error('Only registered medical practitioners can issue digital prescriptions.');
        }
        const patient = await prescription_repository_1.prescriptionRepository.findPatientProfileById(input.patientId);
        if (!patient) {
            throw new Error('Patient record not found.');
        }
        if (input.appointmentId) {
            const appointment = await prescription_repository_1.prescriptionRepository.findAppointmentById(input.appointmentId);
            if (!appointment) {
                throw new Error('Appointment not found.');
            }
            if (appointment.doctorId !== doctor.id) {
                throw new Error('You cannot issue a prescription for an appointment assigned to another practitioner.');
            }
            if (appointment.patientId !== input.patientId) {
                throw new Error('Appointment patient mismatch.');
            }
        }
        return prescription_repository_1.prescriptionRepository.createPrescription(doctor.id, input);
    }
    async getMyPrescriptions(user) {
        if (user.role === client_1.UserRole.DOCTOR) {
            const doctor = await prescription_repository_1.prescriptionRepository.findDoctorProfileByUserId(user.userId);
            if (!doctor)
                throw new Error('Doctor profile not found.');
            return prescription_repository_1.prescriptionRepository.getPrescriptionsByDoctorId(doctor.id);
        }
        else {
            const patient = await prescription_repository_1.prescriptionRepository.findPatientProfileByUserId(user.userId);
            if (!patient)
                throw new Error('Patient profile not found.');
            return prescription_repository_1.prescriptionRepository.getPrescriptionsByPatientId(patient.id);
        }
    }
    async getPrescriptionById(user, prescriptionId) {
        const prescription = await prescription_repository_1.prescriptionRepository.getPrescriptionById(prescriptionId);
        if (!prescription) {
            throw new Error('Prescription not found.');
        }
        if (user.role === client_1.UserRole.PATIENT) {
            const patient = await prescription_repository_1.prescriptionRepository.findPatientProfileByUserId(user.userId);
            if (!patient || prescription.patientId !== patient.id) {
                throw new Error('Unauthorized access to this medical prescription.');
            }
        }
        else if (user.role === client_1.UserRole.DOCTOR) {
            const doctor = await prescription_repository_1.prescriptionRepository.findDoctorProfileByUserId(user.userId);
            if (!doctor || prescription.doctorId !== doctor.id) {
                throw new Error('Unauthorized access to this medical prescription.');
            }
        }
        return prescription;
    }
    async getPrescriptionByAppointmentId(user, appointmentId) {
        const prescription = await prescription_repository_1.prescriptionRepository.getPrescriptionByAppointmentId(appointmentId);
        if (!prescription) {
            throw new Error('No digital prescription found for this appointment.');
        }
        if (user.role === client_1.UserRole.PATIENT) {
            const patient = await prescription_repository_1.prescriptionRepository.findPatientProfileByUserId(user.userId);
            if (!patient || prescription.patientId !== patient.id) {
                throw new Error('Unauthorized access to this prescription.');
            }
        }
        else if (user.role === client_1.UserRole.DOCTOR) {
            const doctor = await prescription_repository_1.prescriptionRepository.findDoctorProfileByUserId(user.userId);
            if (!doctor || prescription.doctorId !== doctor.id) {
                throw new Error('Unauthorized access to this prescription.');
            }
        }
        return prescription;
    }
}
exports.PrescriptionService = PrescriptionService;
exports.prescriptionService = new PrescriptionService();
