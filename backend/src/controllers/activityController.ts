import { type Request, type Response } from "express";
import { sendSuccess, sendError, sendPaginatedSuccess } from "../utils/response";
import { ActivityService } from "../services/activityService";
import { prisma } from "../lib/prisma";

export const getTimeline = async (req: Request, res: Response) => {
    try {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 20;
        const offset = (page - 1) * limit;

        let activities;
        let total;

        // Roles: 
        // Admin: See all (optional filter by userId)
        // Mentor: See all supervised students
        // Peserta: See own

        if (req.user?.role === "ADMIN") {
            total = await prisma.activityLog.count();
            activities = await ActivityService.getAllActivities([], limit, offset); // We need to update service to handle empty array = all?
            // Actually ActivityService.getAllActivities takes userIds.
            // Let's implement custom logic here or update Service. Service is simpler.

            // Re-implementing specific query here for flexibility
            const where: any = {};
            if (req.query.userId) where.userId = req.query.userId as string;

            const [data, count] = await Promise.all([
                prisma.activityLog.findMany({
                    where,
                    include: { user: { select: { username: true, avatar: true, role: true } } },
                    orderBy: { createdAt: 'desc' },
                    take: limit,
                    skip: offset
                }),
                prisma.activityLog.count({ where })
            ]);
            activities = data;
            total = count;

        } else if (req.user?.role === "PEMBIMBING_MAGANG") {
            // Fetch supervised students
            const participants = await prisma.pesertaMagang.findMany({
                where: { pembimbing: { userId: req.user.id } },
                select: { userId: true }
            });
            const supervisedUserIds = participants.map(p => p.userId).filter(Boolean) as string[];

            // Also include the mentor's own actions? Maybe. Let's stick to students + self.
            supervisedUserIds.push(req.user.id);

            const where = { userId: { in: supervisedUserIds } };

            const [data, count] = await Promise.all([
                prisma.activityLog.findMany({
                    where,
                    include: { user: { select: { username: true, avatar: true, role: true } } },
                    orderBy: { createdAt: 'desc' },
                    take: limit,
                    skip: offset
                }),
                prisma.activityLog.count({ where })
            ]);
            activities = data;
            total = count;

        } else {
            // Peserta
            const where = { userId: req.user?.id };
            const [data, count] = await Promise.all([
                prisma.activityLog.findMany({
                    where,
                    include: { user: { select: { username: true, avatar: true, role: true } } },
                    orderBy: { createdAt: 'desc' },
                    take: limit,
                    skip: offset
                }),
                prisma.activityLog.count({ where })
            ]);
            activities = data;
            total = count;
        }

        const totalPages = Math.ceil(total / limit);
        sendPaginatedSuccess(res, "Activity Timeline retrieved", activities, { page, limit, total, totalPages });

    } catch (error) {
        console.error("Get Timeline Error:", error);
        sendError(res, "Failed to fetch timeline");
    }
};
