import { AppointmentStatus, UserRole } from '@prisma/client';
import { appointmentRepository, AppointmentWithDetails } from '../repositories/appointment.repository';
import { AuthUserPayload } from '../types/express';
import {
  CreateAppointmentInput,
  QueryAppointmentsInput,
  UpdateAppointmentStatusInput,
} from '../validators/appointment.validator';

export class AppointmentService {
  /**
   * Book a consultation appointment with slot conflict protection
   */
  async createAppointment(userId: string, input: CreateAppointmentInput): Promise<AppointmentWithDetails> {
    const patient = await appointmentRepository.findPatientProfileByUserId(userId);
    if (!patient) {
      throw new Error('Patient profile not found for this account.');
    }

    const appointmentDate = new Date(input.appointmentDate + 'T00:00:00.000Z');

    // Prevent past bookings
    const today = new Date();
    today.setUTCHours(0, 0, 0, 0);
    if (appointmentDate < today) {
      throw new Error('Cannot book an appointment for a past date.');
    }

    // Check for double-booking conflict
    const isConflict = await appointmentRepository.checkSlotConflict(
      input.doctorId,
      appointmentDate,
      input.startTime
    );
    if (isConflict) {
      throw new Error('This time slot is already booked. Please choose an alternative slot.');
    }

    // Calculate endTime (+30 minutes)
    const [h, m] = input.startTime.split(':').map(Number);
    const endMinutes = h * 60 + m + 30;
    const endH = Math.floor(endMinutes / 60).toString().padStart(2, '0');
    const endM = (endMinutes % 60).toString().padStart(2, '0');
    const endTime = `${endH}:${endM}`;

    return appointmentRepository.createAppointment({
      patientId: patient.id,
      doctorId: input.doctorId,
      appointmentDate,
      startTime: input.startTime,
      endTime,
      patientNotes: input.patientNotes,
    });
  }

  /**
   * Get appointments for the authenticated patient or doctor
   */
  async getAppointments(user: AuthUserPayload, filters: QueryAppointmentsInput): Promise<AppointmentWithDetails[]> {
    if (user.role === UserRole.PATIENT) {
      const patient = await appointmentRepository.findPatientProfileByUserId(user.userId);
      if (!patient) throw new Error('Patient profile not found.');
      return appointmentRepository.findAppointmentsByPatient(patient.id, filters);
    } else if (user.role === UserRole.DOCTOR) {
      const doctor = await appointmentRepository.findDoctorProfileByUserId(user.userId);
      if (!doctor) throw new Error('Doctor profile not found.');
      return appointmentRepository.findAppointmentsByDoctor(doctor.id, filters);
    } else {
      // Admin / other
      return [];
    }
  }

  /**
   * Get appointment details by ID
   */
  async getAppointmentById(id: string, user: AuthUserPayload): Promise<AppointmentWithDetails> {
    const appointment = await appointmentRepository.findAppointmentById(id);
    if (!appointment) {
      throw new Error('Appointment not found.');
    }

    // Access control: Ensure user owns or is the doctor for this appointment
    if (user.role === UserRole.PATIENT && appointment.patient.userId !== user.userId) {
      throw new Error('Access denied to this appointment record.');
    }
    if (user.role === UserRole.DOCTOR && appointment.doctor.userId !== user.userId) {
      throw new Error('Access denied to this appointment record.');
    }

    return appointment;
  }

  /**
   * Transition appointment status
   */
  async updateStatus(
    id: string,
    user: AuthUserPayload,
    input: UpdateAppointmentStatusInput
  ): Promise<AppointmentWithDetails> {
    const appointment = await this.getAppointmentById(id, user);

    // Business validation on transitions
    if (appointment.status === AppointmentStatus.CANCELLED) {
      throw new Error('Cannot change status of an already cancelled appointment.');
    }
    if (appointment.status === AppointmentStatus.COMPLETED) {
      throw new Error('Cannot change status of a completed appointment.');
    }

    // Role-specific action validation
    if (user.role === UserRole.PATIENT) {
      if (input.status !== AppointmentStatus.CANCELLED) {
        throw new Error('Patients can only cancel upcoming appointments.');
      }
    }

    return appointmentRepository.updateAppointmentStatus(id, input.status, input.cancellationReason);
  }

  /**
   * Generate or retrieve teleconsultation session metadata
   */
  async getTeleconsultationSession(id: string, user: AuthUserPayload) {
    const appointment = await this.getAppointmentById(id, user);

    if (appointment.status === AppointmentStatus.CANCELLED) {
      throw new Error('Cannot initiate teleconsultation for a cancelled appointment.');
    }

    const channelName = `consultation-${appointment.id}`;
    const token = `rtc-token-${appointment.id}-${user.userId.substring(0, 8)}`;

    return {
      appointmentId: appointment.id,
      channelName,
      token,
      doctorName: appointment.doctor.fullName,
      doctorSpecialization: appointment.doctor.specialization?.name || 'General Practice',
      patientName: appointment.patient.fullName,
      appointmentDate: appointment.appointmentDate,
      startTime: appointment.startTime,
      endTime: appointment.endTime,
      isDoctorJoined: user.role === UserRole.DOCTOR,
      isPatientJoined: user.role === UserRole.PATIENT,
      status: appointment.status,
    };
  }
}

export const appointmentService = new AppointmentService();
