import { prisma } from '../config/database';

export interface AuditLogParams {
  userId?: string | null;
  action: string;
  resource: string;
  details?: string;
  ipAddress?: string;
}

export class AuditService {
  /**
   * Log a security, clinical, or lifecycle event to the audit_logs table
   */
  async log(params: AuditLogParams): Promise<void> {
    try {
      await prisma.auditLog.create({
        data: {
          userId: params.userId || undefined,
          action: params.action,
          resource: params.resource,
          details: params.details,
          ipAddress: params.ipAddress,
        },
      });
    } catch (error) {
      // Non-blocking: audit failure should not crash core application transactions
      console.error('AuditLog writing failed:', error);
    }
  }

  /**
   * Query recent audit logs for an account or administrative review
   */
  async getLogsForUser(userId: string, limit: number = 50) {
    return prisma.auditLog.findMany({
      where: { userId },
      orderBy: { timestamp: 'desc' },
      take: limit,
    });
  }
}

export const auditService = new AuditService();
