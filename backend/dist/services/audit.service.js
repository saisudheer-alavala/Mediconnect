"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.auditService = exports.AuditService = void 0;
const database_1 = require("../config/database");
class AuditService {
    /**
     * Log a security, clinical, or lifecycle event to the audit_logs table
     */
    async log(params) {
        try {
            await database_1.prisma.auditLog.create({
                data: {
                    userId: params.userId || undefined,
                    action: params.action,
                    resource: params.resource,
                    details: params.details,
                    ipAddress: params.ipAddress,
                },
            });
        }
        catch (error) {
            // Non-blocking: audit failure should not crash core application transactions
            console.error('AuditLog writing failed:', error);
        }
    }
    /**
     * Query recent audit logs for an account or administrative review
     */
    async getLogsForUser(userId, limit = 50) {
        return database_1.prisma.auditLog.findMany({
            where: { userId },
            orderBy: { timestamp: 'desc' },
            take: limit,
        });
    }
}
exports.AuditService = AuditService;
exports.auditService = new AuditService();
