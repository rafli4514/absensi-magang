import { type Request, type Response } from 'express';
import { prisma } from '../lib/prisma';
import { sendSuccess, sendError, sendPaginatedSuccess } from '../utils/response';

export const getAllPengajuanIzin = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;
    const status = req.query.status as string;
    const tipe = req.query.tipe as string;
    const pesertaMagangId = req.query.pesertaMagangId as string;

    const where: any = {};
    if (status && status !== 'Semua') {
      where.status = status.toUpperCase();
    }
    if (tipe && tipe !== 'Semua') {
      where.tipe = tipe.toUpperCase();
    }
    if (pesertaMagangId) {
      where.pesertaMagangId = pesertaMagangId;
    }

    const [pengajuanIzin, total] = await Promise.all([
      prisma.pengajuanIzin.findMany({
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
      prisma.pengajuanIzin.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limit);

    sendPaginatedSuccess(
      res,
      'Pengajuan izin retrieved successfully',
      pengajuanIzin,
      { page, limit, total, totalPages }
    );
  } catch (error) {
    console.error('Get all pengajuan izin error:', error);
    sendError(res, 'Failed to retrieve pengajuan izin');
  }
};

export const getPengajuanIzinById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pengajuanIzin = await prisma.pengajuanIzin.findUnique({
      where: { id },
      include: {
        pesertaMagang: {
          select: {
            id: true,
            nama: true,
            username: true,
            divisi: true,
            universitas: true,
            avatar: true,
          },
        },
      },
    });

    if (!pengajuanIzin) {
      return sendError(res, 'Pengajuan izin not found', 404);
    }

    sendSuccess(res, 'Pengajuan izin retrieved successfully', pengajuanIzin);
  } catch (error) {
    console.error('Get pengajuan izin by ID error:', error);
    sendError(res, 'Failed to retrieve pengajuan izin');
  }
};

export const createPengajuanIzin = async (req: Request, res: Response) => {
  try {
    const { pesertaMagangId, tipe, tanggalMulai, tanggalSelesai, alasan, dokumenPendukung } = req.body;

    if (!pesertaMagangId || !tipe || !tanggalMulai || !tanggalSelesai || !alasan) {
      return sendError(res, 'Missing required fields', 400);
    }

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

    const pengajuanIzin = await prisma.pengajuanIzin.create({
      data: {
        pesertaMagangId,
        tipe: tipe.toUpperCase(),
        tanggalMulai,
        tanggalSelesai,
        alasan,
        status: 'PENDING',
        dokumenPendukung,
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

    sendSuccess(res, 'Pengajuan izin created successfully', pengajuanIzin, 201);
  } catch (error) {
    console.error('Create pengajuan izin error:', error);
    sendError(res, 'Failed to create pengajuan izin', 400);
  }
};

export const updatePengajuanIzin = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { tipe, tanggalMulai, tanggalSelesai, alasan, dokumenPendukung } = req.body;

    // Check if pengajuan izin exists
    const existingPengajuan = await prisma.pengajuanIzin.findUnique({
      where: { id },
    });

    if (!existingPengajuan) {
      return sendError(res, 'Pengajuan izin not found', 404);
    }

    // Only allow updates if status is still pending
    if (existingPengajuan.status !== 'PENDING') {
      return sendError(res, 'Cannot update processed pengajuan izin', 400);
    }

    const updateData: any = {};
    if (tipe) updateData.tipe = tipe.toUpperCase();
    if (tanggalMulai) updateData.tanggalMulai = tanggalMulai;
    if (tanggalSelesai) updateData.tanggalSelesai = tanggalSelesai;
    if (alasan) updateData.alasan = alasan;
    if (dokumenPendukung !== undefined) updateData.dokumenPendukung = dokumenPendukung;

    const updatedPengajuan = await prisma.pengajuanIzin.update({
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

    sendSuccess(res, 'Pengajuan izin updated successfully', updatedPengajuan);
  } catch (error) {
    console.error('Update pengajuan izin error:', error);
    sendError(res, 'Failed to update pengajuan izin', 400);
  }
};

export const deletePengajuanIzin = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if pengajuan izin exists
    const pengajuanIzin = await prisma.pengajuanIzin.findUnique({
      where: { id },
    });

    if (!pengajuanIzin) {
      return sendError(res, 'Pengajuan izin not found', 404);
    }

    await prisma.pengajuanIzin.delete({
      where: { id },
    });

    sendSuccess(res, 'Pengajuan izin deleted successfully');
  } catch (error) {
    console.error('Delete pengajuan izin error:', error);
    sendError(res, 'Failed to delete pengajuan izin');
  }
};

export const approvePengajuanIzin = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { catatan = '' } = req.body;
    const adminId = req.user?.id || 'Admin';

    // Check if pengajuan izin exists
    const pengajuanIzin = await prisma.pengajuanIzin.findUnique({
      where: { id },
    });

    if (!pengajuanIzin) {
      return sendError(res, 'Pengajuan izin not found', 404);
    }

    if (pengajuanIzin.status !== 'PENDING') {
      return sendError(res, 'Pengajuan izin has already been processed', 400);
    }

    const updatedPengajuan = await prisma.pengajuanIzin.update({
      where: { id },
      data: {
        status: 'DISETUJUI',
        disetujuiOleh: adminId,
        disetujuiPada: new Date().toISOString(),
        catatan,
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

    sendSuccess(res, 'Pengajuan izin approved successfully', updatedPengajuan);
  } catch (error) {
    console.error('Approve pengajuan izin error:', error);
    sendError(res, 'Failed to approve pengajuan izin');
  }
};

export const rejectPengajuanIzin = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { catatan = '' } = req.body;
    const adminId = req.user?.id || 'Admin';

    // Check if pengajuan izin exists
    const pengajuanIzin = await prisma.pengajuanIzin.findUnique({
      where: { id },
    });

    if (!pengajuanIzin) {
      return sendError(res, 'Pengajuan izin not found', 404);
    }

    if (pengajuanIzin.status !== 'PENDING') {
      return sendError(res, 'Pengajuan izin has already been processed', 400);
    }

    const updatedPengajuan = await prisma.pengajuanIzin.update({
      where: { id },
      data: {
        status: 'DITOLAK',
        disetujuiOleh: adminId,
        disetujuiPada: new Date().toISOString(),
        catatan,
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

    sendSuccess(res, 'Pengajuan izin rejected successfully', updatedPengajuan);
  } catch (error) {
    console.error('Reject pengajuan izin error:', error);
    sendError(res, 'Failed to reject pengajuan izin');
  }
};

export const getStatistics = async (req: Request, res: Response) => {
  try {
    const [total, pending, disetujui, ditolak] = await Promise.all([
      prisma.pengajuanIzin.count(),
      prisma.pengajuanIzin.count({ where: { status: 'PENDING' } }),
      prisma.pengajuanIzin.count({ where: { status: 'DISETUJUI' } }),
      prisma.pengajuanIzin.count({ where: { status: 'DITOLAK' } }),
    ]);

    const statistics = {
      total,
      pending,
      disetujui,
      ditolak,
    };

    sendSuccess(res, 'Statistics retrieved successfully', statistics);
  } catch (error) {
    console.error('Get statistics error:', error);
    sendError(res, 'Failed to retrieve statistics');
  }
};