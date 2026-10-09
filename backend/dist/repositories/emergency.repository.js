"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.emergencyRepository = exports.EmergencyRepository = void 0;
const database_1 = require("../config/database");
class EmergencyRepository {
    async findPatientProfileByUserId(userId) {
        return database_1.prisma.patientProfile.findUnique({
            where: { userId },
        });
    }
    async getEmergencyProfile(patientId) {
        return database_1.prisma.patientProfile.findUnique({
            where: { id: patientId },
            select: {
                id: true,
                fullName: true,
                bloodGroup: true,
                allergies: true,
                chronicDiseases: true,
                emergencyContacts: {
                    orderBy: [{ isPrimary: 'desc' }, { createdAt: 'asc' }],
                },
            },
        });
    }
    async getEmergencyContacts(patientId) {
        return database_1.prisma.emergencyContact.findMany({
            where: { patientId },
            orderBy: [{ isPrimary: 'desc' }, { createdAt: 'asc' }],
        });
    }
    async addEmergencyContact(patientId, input) {
        if (input.isPrimary) {
            // Demote existing primary contacts if this one is primary
            await database_1.prisma.emergencyContact.updateMany({
                where: { patientId, isPrimary: true },
                data: { isPrimary: false },
            });
        }
        return database_1.prisma.emergencyContact.create({
            data: {
                patientId,
                name: input.name,
                relationship: input.relationship,
                phone: input.phone,
                isPrimary: input.isPrimary ?? false,
            },
        });
    }
    async updateEmergencyContact(patientId, contactId, input) {
        if (input.isPrimary) {
            await database_1.prisma.emergencyContact.updateMany({
                where: { patientId, isPrimary: true },
                data: { isPrimary: false },
            });
        }
        return database_1.prisma.emergencyContact.update({
            where: { id: contactId },
            data: input,
        });
    }
    async deleteEmergencyContact(patientId, contactId) {
        await database_1.prisma.emergencyContact.deleteMany({
            where: { id: contactId, patientId },
        });
    }
    async updateMedicalProfile(patientId, input) {
        return database_1.prisma.patientProfile.update({
            where: { id: patientId },
            data: input,
        });
    }
}
exports.EmergencyRepository = EmergencyRepository;
exports.emergencyRepository = new EmergencyRepository();
