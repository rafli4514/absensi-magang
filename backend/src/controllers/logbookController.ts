import { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import {
  sendSuccess,
  sendError,
  sendPaginatedSuccess,
} from "../utils/response";

export const getAllLogbook = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;
    const pesertaMagangId = req.query.pesertaMagangId as string;
    const tanggal = req.query.tanggal as string;

    const where: any = {};
    
    if (pesertaMagangId) {
      where.pesertaMagangId = pesertaMagangId;
    }
    
    if (tanggal) {
      where.tanggal = tanggal;
    }

    // If user is not admin or pembimbing, only show their own logbook
    if (req.user?.role !== "ADMIN" && req.user?.role !== "PEMBIMBING_MAGANG") {
      // Get peserta magang by user id
      const pesertaMagang = await prisma.pesertaMagang.findFirst({
        where: { userId: req.user?.id },
      });
      if (pesertaMagang) {
        where.pesertaMagangId = pesertaMagang.id;
      } else {
        // If no peserta magang found, return empty
        return sendPaginatedSuccess(
          res,
          "Logbook retrieved successfully",
          [],
          { page, limit, total: 0, totalPages: 0 }
        );
      }
    }

    const [logbook, total] = await Promise.all([
      prisma.logbook.findMany({
        where,
        include: {
          pesertaMagang: {
            select: {
              id: true,
              nama: true,
              username: true,
              divisi: true,
              instansi: true,
            },
          },
        },
        skip,
        take: limit,
        orderBy: { tanggal: "desc" },
      }),
      prisma.logbook.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limit);

    sendPaginatedSuccess(
      res,
      "Logbook retrieved successfully",
      logbook,
      { page, limit, total, totalPages }
    );
  } catch (error) {
    console.error("Get all logbook error:", error);
    sendError(res, "Failed to retrieve logbook");
  }
};

export const getLogbookById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const logbook = await prisma.logbook.findUnique({
      where: { id },
      include: {
        pesertaMagang: {
          select: {
            id: true,
            nama: true,
            username: true,
            divisi: true,
            instansi: true,
            avatar: true,
          },
        },
      },
    });

    if (!logbook) {
      return sendError(res, "Logbook not found", 404);
    }

    // Check if user has access to this logbook
    if (req.user?.role !== "ADMIN" && req.user?.role !== "PEMBIMBING_MAGANG") {
      const pesertaMagang = await prisma.pesertaMagang.findFirst({
        where: { userId: req.user?.id },
      });
      if (pesertaMagang?.id !== logbook.pesertaMagangId) {
        return sendError(res, "Access denied", 403);
      }
    }

    sendSuccess(res, "Logbook retrieved successfully", logbook);
  } catch (error) {
    console.error("Get logbook by ID error:", error);
    sendError(res, "Failed to retrieve logbook");
  }
};

export const createLogbook = async (req: Request, res: Response) => {
  try {
    const { pesertaMagangId, tanggal, kegiatan, deskripsi, durasi, type, status } = req.body;

    if (!pesertaMagangId || !tanggal || !kegiatan || !deskripsi) {
      return sendError(res, "Missing required fields", 400);
    }

    // Validate peserta magang exists
    const pesertaMagang = await prisma.pesertaMagang.findUnique({
      where: { id: pesertaMagangId },
    });

    if (!pesertaMagang) {
      return sendError(res, "Peserta magang not found", 400);
    }

    // Check if peserta magang is active
    if (pesertaMagang.status !== "AKTIF") {
      return sendError(res, "Peserta magang is not active", 400);
    }

    // If user is not admin, check if they own this peserta magang
    if (req.user?.role !== "ADMIN") {
      const userPesertaMagang = await prisma.pesertaMagang.findFirst({
        where: { userId: req.user?.id },
      });
      if (userPesertaMagang?.id !== pesertaMagangId) {
        return sendError(res, "Access denied", 403);
      }
    }

    // Validate date format
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(tanggal)) {
      return sendError(res, "Invalid date format. Use YYYY-MM-DD", 400);
    }

    const logbook = await prisma.logbook.create({
      data: {
        pesertaMagangId,
        tanggal,
        kegiatan,
        deskripsi,
        durasi: durasi || null,
        type: type ? (type.toUpperCase() as any) : null,
        status: status ? (status.toUpperCase().replace(/-/g, '_') as any) : null,
      },
      include: {
        pesertaMagang: {
          select: {
            id: true,
            nama: true,
            username: true,
            divisi: true,
          },
        },
      },
    });

    sendSuccess(res, "Logbook created successfully", logbook, 201);
  } catch (error) {
    console.error("Create logbook error:", error);
    sendError(res, "Failed to create logbook", 400);
  }
};

export const updateLogbook = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { tanggal, kegiatan, deskripsi, durasi, type, status } = req.body;

    // Check if logbook exists
    const existingLogbook = await prisma.logbook.findUnique({
      where: { id },
    });

    if (!existingLogbook) {
      return sendError(res, "Logbook not found", 404);
    }

    // Check if user has access
    if (req.user?.role !== "ADMIN") {
      const userPesertaMagang = await prisma.pesertaMagang.findFirst({
        where: { userId: req.user?.id },
      });
      if (userPesertaMagang?.id !== existingLogbook.pesertaMagangId) {
        return sendError(res, "Access denied", 403);
      }
    }

    const updateData: any = {};
    if (tanggal) {
      // Validate date format
      const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
      if (!dateRegex.test(tanggal)) {
        return sendError(res, "Invalid date format. Use YYYY-MM-DD", 400);
      }
      updateData.tanggal = tanggal;
    }
    if (kegiatan) updateData.kegiatan = kegiatan;
    if (deskripsi) updateData.deskripsi = deskripsi;
    if (durasi !== undefined) updateData.durasi = durasi || null;
    if (type !== undefined) updateData.type = type ? (type.toUpperCase() as any) : null;
    if (status !== undefined) updateData.status = status ? (status.toUpperCase().replace(/-/g, '_') as any) : null;

    const updatedLogbook = await prisma.logbook.update({
      where: { id },
      data: updateData,
      include: {
        pesertaMagang: {
          select: {
            id: true,
            nama: true,
            username: true,
            divisi: true,
          },
        },
      },
    });

    sendSuccess(res, "Logbook updated successfully", updatedLogbook);
  } catch (error) {
    console.error("Update logbook error:", error);
    sendError(res, "Failed to update logbook", 400);
  }
};

export const deleteLogbook = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if logbook exists
    const logbook = await prisma.logbook.findUnique({
      where: { id },
    });

    if (!logbook) {
      return sendError(res, "Logbook not found", 404);
    }

    // Check if user has access
    if (req.user?.role !== "ADMIN") {
      const userPesertaMagang = await prisma.pesertaMagang.findFirst({
        where: { userId: req.user?.id },
      });
      if (userPesertaMagang?.id !== logbook.pesertaMagangId) {
        return sendError(res, "Access denied", 403);
      }
    }

    await prisma.logbook.delete({
      where: { id },
    });

    sendSuccess(res, "Logbook deleted successfully");
  } catch (error) {
    console.error("Delete logbook error:", error);
    sendError(res, "Failed to delete logbook");
  }
};

export const getStatistics = async (req: Request, res: Response) => {
  try {
    const pesertaMagangId = req.query.pesertaMagangId as string;
    
    const where: any = {};
    if (pesertaMagangId) {
      where.pesertaMagangId = pesertaMagangId;
    }

    // If user is not admin or pembimbing, only show their own statistics
    if (req.user?.role !== "ADMIN" && req.user?.role !== "PEMBIMBING_MAGANG") {
      const pesertaMagang = await prisma.pesertaMagang.findFirst({
        where: { userId: req.user?.id },
      });
      if (pesertaMagang) {
        where.pesertaMagangId = pesertaMagang.id;
      }
    }

    const [total, thisMonth, thisWeek] = await Promise.all([
      prisma.logbook.count({ where }),
      prisma.logbook.count({
        where: {
          ...where,
          createdAt: {
            gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
          },
        },
      }),
      prisma.logbook.count({
        where: {
          ...where,
          createdAt: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
          },
        },
      }),
    ]);

    const statistics = {
      total,
      thisMonth,
      thisWeek,
    };

    sendSuccess(res, "Statistics retrieved successfully", statistics);
  } catch (error) {
    console.error("Get statistics error:", error);
    sendError(res, "Failed to retrieve statistics");
  }
};