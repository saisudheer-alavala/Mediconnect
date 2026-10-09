import { UserRole } from '@prisma/client';
import { prescriptionRepository, PrescriptionWithDetails } from '../repositories/prescription.repository';
import { AuthUserPayload } from '../types/express';
import { CreatePrescriptionInput } from '../validators/prescription.validator';

export class PrescriptionService {
  async issuePrescription(userId: string, input: CreatePrescriptionInput): Promise<PrescriptionWithDetails> {
    const doctor = await prescriptionRepository.findDoctorProfileByUserId(userId);
    if (!doctor) {
      throw new Error('Only registered medical practitioners can issue digital prescriptions.');
    }

    const patient = await prescriptionRepository.findPatientProfileById(input.patientId);
    if (!patient) {
      throw new Error('Patient record not found.');
    }

    if (input.appointmentId) {
      const appointment = await prescriptionRepository.findAppointmentById(input.appointmentId);
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

    return prescriptionRepository.createPrescription(doctor.id, input);
  }

  async getMyPrescriptions(user: AuthUserPayload): Promise<PrescriptionWithDetails[]> {
    if (user.role === UserRole.DOCTOR) {
      const doctor = await prescriptionRepository.findDoctorProfileByUserId(user.userId);
      if (!doctor) throw new Error('Doctor profile not found.');
      return prescriptionRepository.getPrescriptionsByDoctorId(doctor.id);
    } else {
      const patient = await prescriptionRepository.findPatientProfileByUserId(user.userId);
      if (!patient) throw new Error('Patient profile not found.');
      return prescriptionRepository.getPrescriptionsByPatientId(patient.id);
    }
  }

  async getPrescriptionById(user: AuthUserPayload, prescriptionId: string): Promise<PrescriptionWithDetails> {
    const prescription = await prescriptionRepository.getPrescriptionById(prescriptionId);
    if (!prescription) {
      throw new Error('Prescription not found.');
    }

    if (user.role === UserRole.PATIENT) {
      const patient = await prescriptionRepository.findPatientProfileByUserId(user.userId);
      if (!patient || prescription.patientId !== patient.id) {
        throw new Error('Unauthorized access to this medical prescription.');
      }
    } else if (user.role === UserRole.DOCTOR) {
      const doctor = await prescriptionRepository.findDoctorProfileByUserId(user.userId);
      if (!doctor || prescription.doctorId !== doctor.id) {
        throw new Error('Unauthorized access to this medical prescription.');
      }
    }

    return prescription;
  }

  async getPrescriptionByAppointmentId(user: AuthUserPayload, appointmentId: string): Promise<PrescriptionWithDetails> {
    const prescription = await prescriptionRepository.getPrescriptionByAppointmentId(appointmentId);
    if (!prescription) {
      throw new Error('No digital prescription found for this appointment.');
    }

    if (user.role === UserRole.PATIENT) {
      const patient = await prescriptionRepository.findPatientProfileByUserId(user.userId);
      if (!patient || prescription.patientId !== patient.id) {
        throw new Error('Unauthorized access to this prescription.');
      }
    } else if (user.role === UserRole.DOCTOR) {
      const doctor = await prescriptionRepository.findDoctorProfileByUserId(user.userId);
      if (!doctor || prescription.doctorId !== doctor.id) {
        throw new Error('Unauthorized access to this prescription.');
      }
    }

    return prescription;
  }
}

export const prescriptionService = new PrescriptionService();
