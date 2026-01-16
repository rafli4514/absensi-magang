import { Prisma, PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export type ActivityAction =
    | 'LOGIN'
    | 'LOGBOOK_CREATE'
    | 'LOGBOOK_UPDATE'
    | 'LOGBOOK_DELETE'
    | 'ABSENSI_IN'
    | 'ABSENSI_OUT'
    | 'IZIN_REQ'
    | 'IZIN_APPROVE'
    | 'IZIN_REJECT';

export type EntityType =
    | 'LOGBOOK'
    | 'ABSENSI'
    | 'PENGAJUAN_IZIN'
    | 'USER';

export class ActivityService {

    /**
     * Log a new activity event
     */
    static async log(
        userId: string,
        action: ActivityAction,
        entityType: EntityType,
        entityId: string | null,
        description: string,
        metadata?: any
    ) {
        try {
            await prisma.activityLog.create({
                data: {
                    userId,
                    action,
                    entityType,
                    entityId,
                    description,
                    metadata: metadata ? (metadata as Prisma.InputJsonValue) : undefined,
                },
            });
            // console.log(`[Activity] Logged: ${action} by ${userId}`);
        } catch (error) {
            console.error('[Activity] Failed to log activity:', error);
            // We do not throw here to prevent disrupting the main flow
        }
    }

    /**
     * Get activities (timeline) for a user
     */
    static async getTimeline(userId: string, limit = 20, offset = 0) {
        return prisma.activityLog.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: limit,
            skip: offset,
            include: {
                user: {
                    select: {
                        username: true,
                        avatar: true,
                        role: true
                    }
                }
            }
        });
    }

    /**
     * Get all activities (Admin/Mentor view - filtered by supervised students if needed)
     */
    static async getAllActivities(userIds: string[], limit = 50, offset = 0) {
        return prisma.activityLog.findMany({
            where: {
                userId: { in: userIds }
            },
            orderBy: { createdAt: 'desc' },
            take: limit,
            skip: offset,
            include: {
                user: {
                    select: {
                        username: true,
                        avatar: true,
                        role: true
                    }
                }
            }
        });
    }
}
