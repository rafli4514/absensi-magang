import { type Request, type Response } from 'express';
import { prisma } from '../lib/prisma';
import { sendSuccess, sendError, sendPaginatedSuccess } from '../utils/response';

export const getAllAbsensi = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;
    const pesertaMagangId = req.query.pesertaMagangId as string;
    const tipe = req.query.tipe as string;
    const status = req.query.status as string;

    const where: any = {};
    if (pesertaMagangId) {
      where.pesertaMagangId = pesertaMagangId;
    }
    if (tipe && tipe !== 'Semua') {
      where.tipe = tipe.toUpperCase();
    }
    if (status && status !== 'Semua') {
      where.status = status.toUpperCase();
    }

    const [absensi, total] = await Promise.all([
      prisma.absensi.findMany({
        where,
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
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.absensi.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limit);

    sendPaginatedSuccess(
      res,
      'Absensi retrieved successfully',
      absensi,
      { page, limit, total, totalPages }
    );
  } catch (error) {
    console.error('Get all absensi error:', error);
    sendError(res, 'Failed to retrieve absensi');
  }
};

export const getAbsensiById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const absensi = await prisma.absensi.findUnique({
      where: { id },
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

    if (!absensi) {
      return sendError(res, 'Absensi not found', 404);
    }

    sendSuccess(res, 'Absensi retrieved successfully', absensi);
  } catch (error) {
    console.error('Get absensi by ID error:', error);
    sendError(res, 'Failed to retrieve absensi');
  }
};

export const createAbsensi = async (req: Request, res: Response) => {
  try {
    const {
      pesertaMagangId,
      tipe,
      timestamp,
      lokasi,
      selfieUrl,
      qrCodeData,
      status = 'VALID',
      catatan,
      ipAddress,
      device,
    } = req.body;

    // Validate peserta magang exists
    const pesertaMagang = await prisma.pesertaMagang.findUnique({
      where: { id: pesertaMagangId },
    });

    if (!pesertaMagang) {
      return sendError(res, 'Peserta magang not found', 400);
    }

    // Check if peserta magang is active
    if (pesertaMagang.status !== 'AKTIF') {
      return sendError(res, 'Peserta magang is not active', 400);
    }

    const absensi = await prisma.absensi.create({
      data: {
        pesertaMagangId,
        tipe: tipe.toUpperCase(),
        timestamp: timestamp || new Date().toISOString(),
        lokasi,
        selfieUrl,
        qrCodeData,
        status: status.toUpperCase(),
        catatan,
        ipAddress,
        device,
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

    sendSuccess(res, 'Absensi created successfully', absensi, 201);
  } catch (error) {
    console.error('Create absensi error:', error);
    sendError(res, 'Failed to create absensi', 400);
  }
};

export const updateAbsensi = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const {
      tipe,
      timestamp,
      lokasi,
      selfieUrl,
      qrCodeData,
      status,
      catatan,
      ipAddress,
      device,
    } = req.body;

    // Check if absensi exists
    const existingAbsensi = await prisma.absensi.findUnique({
      where: { id },
    });

    if (!existingAbsensi) {
      return sendError(res, 'Absensi not found', 404);
    }

    const updateData: any = {};
    if (tipe) updateData.tipe = tipe.toUpperCase();
    if (timestamp) updateData.timestamp = timestamp;
    if (lokasi !== undefined) updateData.lokasi = lokasi;
    if (selfieUrl !== undefined) updateData.selfieUrl = selfieUrl;
    if (qrCodeData !== undefined) updateData.qrCodeData = qrCodeData;
    if (status) updateData.status = status.toUpperCase();
    if (catatan !== undefined) updateData.catatan = catatan;
    if (ipAddress !== undefined) updateData.ipAddress = ipAddress;
    if (device !== undefined) updateData.device = device;

    const updatedAbsensi = await prisma.absensi.update({
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

    sendSuccess(res, 'Absensi updated successfully', updatedAbsensi);
  } catch (error) {
    console.error('Update absensi error:', error);
    sendError(res, 'Failed to update absensi', 400);
  }
};

export const deleteAbsensi = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if absensi exists
    const absensi = await prisma.absensi.findUnique({
      where: { id },
    });

    if (!absensi) {
      return sendError(res, 'Absensi not found', 404);
    }

    await prisma.absensi.delete({
      where: { id },
    });

    sendSuccess(res, 'Absensi deleted successfully');
  } catch (error) {
    console.error('Delete absensi error:', error);
    sendError(res, 'Failed to delete absensi');
  }
};