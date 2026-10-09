"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.healthRecordRepository = exports.HealthRecordRepository = void 0;
const database_1 = require("../config/database");
class HealthRecordRepository {
    async findPatientProfileByUserId(userId) {
        return database_1.prisma.patientProfile.findUnique({
            where: { userId },
        });
    }
    async findDoctorProfileByUserId(userId) {
        return database_1.prisma.doctorProfile.findUnique({
            where: { userId },
        });
    }
    async getRecordsByPatient(patientId, category, search) {
        const where = { patientId };
        if (category) {
            where.category = category;
        }
        if (search && search.trim().length > 0) {
            where.OR = [
                { title: { contains: search, mode: 'insensitive' } },
                { description: { contains: search, mode: 'insensitive' } },
            ];
        }
        return database_1.prisma.healthRecord.findMany({
            where,
            orderBy: { uploadedAt: 'desc' },
            include: {
                patient: {
                    select: {
                        fullName: true,
                        bloodGroup: true,
                    },
                },
            },
        });
    }
    async getRecordById(recordId) {
        return database_1.prisma.healthRecord.findUnique({
            where: { id: recordId },
            include: {
                patient: {
                    select: {
                        fullName: true,
                        bloodGroup: true,
                    },
                },
            },
        });
    }
    async createRecord(patientId, input) {
        return database_1.prisma.healthRecord.create({
            data: {
                patientId,
                title: input.title,
                category: input.category,
                description: input.description,
                fileUrl: input.fileUrl,
                fileSize: input.fileSize,
                mimeType: input.mimeType,
                uploadedAt: input.uploadedAt ? new Date(input.uploadedAt) : new Date(),
            },
        });
    }
    async updateRecord(recordId, input) {
        const data = { ...input };
        if (input.uploadedAt) {
            data.uploadedAt = new Date(input.uploadedAt);
        }
        return database_1.prisma.healthRecord.update({
            where: { id: recordId },
            data,
        });
    }
    async deleteRecord(recordId) {
        await database_1.prisma.healthRecord.delete({
            where: { id: recordId },
        });
    }
}
exports.HealthRecordRepository = HealthRecordRepository;
exports.healthRecordRepository = new HealthRecordRepository();
