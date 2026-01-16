import { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import { sendError } from "../utils/response";
import { ExportService } from "../services/exportService";

export const exportLogbook = async (req: Request, res: Response) => {
    try {
        const { format = "pdf", startDate, endDate, pesertaMagangId } = req.query;

        const where: any = {};

        // -- Role Access Control --
        let requestedBy = req.user?.username || "Unknown";
        let role = req.user?.role || "Unknown";

        if (req.user?.role !== "ADMIN") {
            // If mentor, check if they supervise the requested ID, OR if no ID requested, fetch all their students' logs
            if (req.user?.role === "PEMBIMBING_MAGANG") {
                // If a specific ID is requested, verify supervision
                if (pesertaMagangId) {
                    const participant = await prisma.pesertaMagang.findFirst({
                        where: { id: pesertaMagangId as string, pembimbing: { userId: req.user.id } }
                    });
                    if (!participant) return sendError(res, "Access denied to this participant", 403);
                    where.pesertaMagangId = pesertaMagangId;
                } else {
                    // Fetch all supervised participants
                    where.pesertaMagang = { pembimbing: { userId: req.user.id } };
                }
            } else {
                // Peserta can only see their own
                const pesertaMagang = await prisma.pesertaMagang.findFirst({
                    where: { userId: req.user?.id },
                });
                if (!pesertaMagang) return sendError(res, "Peserta account not found", 404);
                where.pesertaMagangId = pesertaMagang.id;

                // If they tried to request someone else's ID, ignore or error. 
                // (Current logic overrides their input by force setting accessing only their own ID)
            }
        } else {
            // Admin
            if (pesertaMagangId) where.pesertaMagangId = pesertaMagangId;
        }

        // -- Date Filter --
        if (startDate && endDate) {
            where.tanggal = {
                gte: startDate as string,
                lte: endDate as string,
            };
        }

        // -- Fetch Data --
        const logbooks = await prisma.logbook.findMany({
            where,
            include: {
                pesertaMagang: {
                    select: { nama: true, divisi: true, instansi: true }
                }
            },
            orderBy: { tanggal: "asc" }
        });

        if (format === "csv") {
            const fields = ["tanggal", "kegiatan", "deskripsi", "durasi", "status", "pesertaMagang.nama", "pesertaMagang.divisi"];
            return ExportService.generateCSV(logbooks, fields, "Logbook_Export", res);
        } else {
            return ExportService.generateLogbookPDF(logbooks, {
                startDate: startDate as string,
                endDate: endDate as string,
                requestedBy,
                role
            }, res);
        }

    } catch (error) {
        console.error("Export Logbook Error:", error);
        sendError(res, "Failed to export data");
    }
};

export const exportActivity = async (req: Request, res: Response) => {
    try {
        // Activity Log is mostly for Admins or Mentors audit
        if (req.user?.role === "PESERTA_MAGANG") {
            return sendError(res, "Access denied", 403);
        }

        const { startDate, endDate } = req.query;
        const where: any = {};

        if (startDate && endDate) {
            where.createdAt = {
                gte: new Date(startDate as string),
                lte: new Date(endDate as string)
            };
        }

        // Mentors only see their students' activities
        if (req.user?.role === "PEMBIMBING_MAGANG") {
            const participants = await prisma.pesertaMagang.findMany({
                where: { pembimbing: { userId: req.user.id } },
                select: { userId: true }
            });
            const userIds = participants.map(p => p.userId).filter(Boolean) as string[];
            where.userId = { in: userIds };
        }

        const activities = await prisma.activityLog.findMany({
            where,
            include: {
                user: { select: { username: true, role: true } }
            },
            orderBy: { createdAt: "desc" }
        });

        const flattened = activities.map(a => ({
            timestamp: a.createdAt,
            user: a.user.username,
            role: a.user.role,
            action: a.action,
            entity: a.entityType,
            description: a.description
        }));

        const fields = ["timestamp", "user", "role", "action", "entity", "description"];
        return ExportService.generateCSV(flattened, fields, "Activity_Audit", res);

    } catch (error) {
        console.error("Export Activity Error:", error);
        sendError(res, "Failed to export activities");
    }
};
