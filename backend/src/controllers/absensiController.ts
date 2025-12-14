import { type Request, type Response } from 'express';
import { prisma } from '../lib/prisma';
import { sendSuccess, sendError, sendPaginatedSuccess } from '../utils/response';
import { StatusAbsensi, TipeAbsensi } from '@prisma/client';

function toRadians(deg: number): number {
  return (deg * Math.PI) / 180;
}

function haversineDistanceMeters(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371000; // meters
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c);
}

function parseTimeHHmm(time: string): { hours: number; minutes: number } {
  const [hh, mm] = time.split(':').map((x) => parseInt(x, 10));
  return { hours: isNaN(hh) ? 0 : hh, minutes: isNaN(mm) ? 0 : mm };
}

function diffMinutes(a: Date, b: Date): number {
  return Math.round((a.getTime() - b.getTime()) / 60000);
}

async function loadAppSettings() {
  const records = await prisma.settings.findMany();
  const settings: any = {};
  for (const record of records) {
    const keys = record.key.split('.');
    let current = settings;
    for (let i = 0; i < keys.length - 1; i++) {
      if (!current[keys[i]]) current[keys[i]] = {};
      current = current[keys[i]];
    }
    current[keys[keys.length - 1]] = record.value;
  }
  return settings;
}

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

    // Load settings for validation
    const appSettings = await loadAppSettings();

    const requireLocation = appSettings?.attendance?.requireLocation ?? true;
    const useRadius = appSettings?.location?.useRadius ?? true;
    const officeLat = appSettings?.location?.latitude;
    const officeLng = appSettings?.location?.longitude;
    const radiusMeters = appSettings?.location?.radius ?? 100;

    // IP whitelist (opsional jika dikonfigurasi)
    const ipWhitelistEnabled = appSettings?.security?.ipWhitelist ?? false;
    const allowedIps: string[] = appSettings?.security?.allowedIps ?? [];
    const requestIp = (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || req.ip || ipAddress;
    if (ipWhitelistEnabled) {
      if (!Array.isArray(allowedIps) || allowedIps.length === 0) {
        return sendError(res, 'IP whitelist diaktifkan, namun daftar IP belum dikonfigurasi', 403);
      }
      if (!allowedIps.includes(requestIp)) {
        return sendError(res, `IP ${requestIp} tidak diizinkan untuk absensi`, 403, 'IP_NOT_WHITELISTED');
      }
    }

    // Tentukan timestamp yang dipakai
    const now = timestamp ? new Date(timestamp) : new Date();

    // Validasi hari kerja
    const workDays = appSettings?.schedule?.workDays ?? ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    const dayNames = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const currentDay = dayNames[now.getDay()];
    
    if (!workDays.includes(currentDay)) {
      return sendError(res, `Hari ini (${currentDay}) bukan hari kerja. Hari kerja: ${workDays.join(', ')}`, 400, 'INVALID_WORK_DAY');
    }

    // Validasi jam operasional
    const workStart = appSettings?.schedule?.workStartTime ?? '08:00';
    const workEnd = appSettings?.schedule?.workEndTime ?? '17:00';
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    const tipeUpper = (tipe || '').toUpperCase();
    
    // Untuk MASUK: hanya boleh antara workStart dan workEnd
    // Untuk KELUAR: boleh setelah workStart (tidak ada batasan maksimal)
    if (tipeUpper === 'MASUK') {
      if (currentTime < workStart || currentTime > workEnd) {
        return sendError(res, `Absen masuk hanya tersedia antara ${workStart} - ${workEnd}. Waktu saat ini: ${currentTime}`, 400, 'OUTSIDE_WORK_HOURS');
      }
    } else if (tipeUpper === 'KELUAR') {
      // KELUAR harus setelah jam mulai kerja
      if (currentTime < workStart) {
        return sendError(res, `Absen keluar hanya tersedia setelah ${workStart}. Waktu saat ini: ${currentTime}`, 400, 'OUTSIDE_WORK_HOURS');
      }
    }

    // Penentuan status keterlambatan
    const allowLateCheckIn = appSettings?.attendance?.allowLateCheckIn ?? true;
    const lateThreshold = appSettings?.attendance?.lateThreshold ?? 15; // minutes
    const { hours, minutes } = parseTimeHHmm(workStart);
    const startToday = new Date(now);
    startToday.setHours(hours, minutes, 0, 0);

    let computedStatus: StatusAbsensi = 'VALID';

    if ((tipe || '').toUpperCase() === 'MASUK') {
      const diffMin = diffMinutes(now, startToday); // positive if after start
      if (diffMin > (lateThreshold || 0)) {
        computedStatus = allowLateCheckIn ? 'TERLAMBAT' : 'INVALID';
      } else {
        computedStatus = 'VALID';
      }
    }

    // Enforce lokasi (tanpa pengecualian untuk QR) jika required
    if (requireLocation) {
      if (!lokasi || typeof lokasi?.latitude !== 'number' || typeof lokasi?.longitude !== 'number') {
        return sendError(res, 'Lokasi diperlukan untuk absensi', 400);
      }

      if (useRadius) {
        if (typeof officeLat !== 'number' || typeof officeLng !== 'number') {
          return sendError(res, 'Koordinat kantor belum dikonfigurasi oleh admin', 500);
        }
        const distance = haversineDistanceMeters(lokasi.latitude, lokasi.longitude, officeLat, officeLng);
        if (distance > radiusMeters) {
          // STRICT: di luar jangkauan ditolak
          return sendError(res, `Di luar jangkauan. Jarak ${distance}m melebihi radius ${radiusMeters}m dari kantor.`, 400, 'LOCATION_OUT_OF_RANGE');
        }
        (req as any)._absenDistance = distance;
      }
    }

    const absensi = await prisma.absensi.create({
      data: {
        pesertaMagangId,
        tipe: (tipe || '').toUpperCase() as TipeAbsensi,
        timestamp: now.toISOString(),
        lokasi,
        selfieUrl,
        qrCodeData,
        status: computedStatus,
        catatan,
        ipAddress: requestIp,
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

    const meta: any = {};
    if (requireLocation && useRadius && (req as any)._absenDistance !== undefined) {
      meta.distance = (req as any)._absenDistance;
      meta.radius = radiusMeters;
    }

    sendSuccess(res, 'Absensi created successfully', { ...absensi, meta }, 201);
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