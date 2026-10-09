import { doctorRepository } from '../repositories/doctor.repository';
import { SearchDoctorInput } from '../validators/doctor.validator';

export interface DoctorSlot {
  startTime: string; // e.g. "09:00"
  endTime: string;   // e.g. "09:30"
  isAvailable: boolean;
}

export class DoctorService {
  async getSpecializations() {
    return doctorRepository.findSpecializations();
  }

  async searchDoctors(filters: SearchDoctorInput) {
    return doctorRepository.searchDoctors(filters);
  }

  async getDoctorById(id: string) {
    const doctor = await doctorRepository.findDoctorById(id);
    if (!doctor) {
      throw new Error('Doctor profile not found.');
    }
    return doctor;
  }

  /**
   * Calculate available appointment time slots for a specific calendar date
   */
  async getAvailableSlots(doctorId: string, dateStr: string): Promise<DoctorSlot[]> {
    const targetDate = new Date(dateStr + 'T00:00:00.000Z');
    const dayOfWeek = targetDate.getUTCDay();

    const doctor = await this.getDoctorById(doctorId);

    // Find availability template for this day of week
    const availability = doctor.availabilities.find(
      (a) => a.dayOfWeek === dayOfWeek && a.isActive
    );

    if (!availability) {
      return []; // Doctor has no practice hours on this day
    }

    // Fetch existing booked appointments on this date
    const bookedAppointments = await doctorRepository.findBookedAppointmentsForDate(
      doctorId,
      targetDate
    );
    const bookedTimes = new Set(bookedAppointments.map((a) => a.startTime));

    // Generate slots
    const slots: DoctorSlot[] = [];
    const duration = availability.slotDurationMinutes || 30;

    const [startH, startM] = availability.startTime.split(':').map(Number);
    const [endH, endM] = availability.endTime.split(':').map(Number);

    let currentMinutes = startH * 60 + startM;
    const endMinutes = endH * 60 + endM;

    let breakStartMinutes = -1;
    let breakEndMinutes = -1;

    if (availability.breakStartTime && availability.breakEndTime) {
      const [bStartH, bStartM] = availability.breakStartTime.split(':').map(Number);
      const [bEndH, bEndM] = availability.breakEndTime.split(':').map(Number);
      breakStartMinutes = bStartH * 60 + bStartM;
      breakEndMinutes = bEndH * 60 + bEndM;
    }

    while (currentMinutes + duration <= endMinutes) {
      const slotStartH = Math.floor(currentMinutes / 60).toString().padStart(2, '0');
      const slotStartM = (currentMinutes % 60).toString().padStart(2, '0');
      const slotStartTime = `${slotStartH}:${slotStartM}`;

      const nextMinutes = currentMinutes + duration;
      const slotEndH = Math.floor(nextMinutes / 60).toString().padStart(2, '0');
      const slotEndM = (nextMinutes % 60).toString().padStart(2, '0');
      const slotEndTime = `${slotEndH}:${slotEndM}`;

      // Check if slot falls in break
      const isDuringBreak =
        breakStartMinutes !== -1 &&
        currentMinutes >= breakStartMinutes &&
        currentMinutes < breakEndMinutes;

      if (!isDuringBreak) {
        const isBooked = bookedTimes.has(slotStartTime);
        slots.push({
          startTime: slotStartTime,
          endTime: slotEndTime,
          isAvailable: !isBooked,
        });
      }

      currentMinutes += duration;
    }

    return slots;
  }
}

export const doctorService = new DoctorService();
