import { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import { sendSuccess, sendError } from "../utils/response";

export const getPembimbings = async (req: Request, res: Response) => {
    try {
        const { bidang } = req.query;

        const whereClause: any = {};
        if (bidang) {
            whereClause.bidang = bidang as string;
        }

        const pembimbings = await prisma.pembimbing.findMany({
            where: whereClause,
            select: {
                id: true,
                nama: true,
                bidang: true,
                kuota: true,
                _count: {
                    select: { peserta: true },
                },
            },
        });

        // Calculate remaining quota if necessary, or just return list
        // Implementation plan says "menampilkan daftar pembimbing aktif dan memiliki kuota"

        const availablePembimbings = pembimbings.filter(p => p._count.peserta < p.kuota);

        sendSuccess(res, "Pembimbings retrieved successfully", availablePembimbings);
    } catch (error) {
        console.error("Get pembimbings error:", error);
        sendError(res, "Failed to get pembimbings", 500);
    }
};

export const getAllBidang = async (req: Request, res: Response) => {
    try {
        const pembimbings = await prisma.pembimbing.findMany({
            select: { bidang: true },
            distinct: ['bidang'],
        });

        const bidangs = pembimbings.map(p => p.bidang);
        sendSuccess(res, "Bidang list retrieved", bidangs);
    } catch (error) {
        console.error("Get bidang error", error);
        sendError(res, "Failed to get bidang list", 500);
    }
}
