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

type AttendanceValidationResult = {
  allowed: boolean;
  status: StatusAbsensi;
  errorCode?: string;
  errorMessage?: string;
  httpStatus?: number;
};

/**
 * Konsolidasi logika aturan kerja (hari kerja, jam kerja, keterlambatan) di satu tempat.
 * Semua endpoint absensi yang butuh aturan ini harus menggunakan helper ini.
 */
function evaluateAttendanceRules(
  now: Date,
  rawTipe: string | undefined,
  appSettings: any,
): AttendanceValidationResult {
  const tipeUpper = (rawTipe || '').toUpperCase();

  // Default fallback jika belum ada pengaturan di DB
  const workDays: string[] =
    appSettings?.schedule?.workDays ?? ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
  const dayNames = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  const dayLabels: Record<string, string> = {
    sunday: 'Minggu',
    monday: 'Senin',
    tuesday: 'Selasa',
    wednesday: 'Rabu',
    thursday: 'Kamis',
    friday: 'Jumat',
    saturday: 'Sabtu',
  };

  // now sudah merepresentasikan waktu Indonesia (UTC+7) di level "value".
  // Karena JavaScript Date menyimpan waktu sebagai UTC timestamp, kita pakai
  // UTC getter supaya tidak "offset dua kali".
  const currentDay = dayNames[now.getUTCDay()];
  const currentDayLabel = dayLabels[currentDay] ?? currentDay;
  const workDaysLabel = workDays.map((d: string) => dayLabels[d] ?? d).join(', ');

  // 1) Validasi hari kerja
  if (!workDays.includes(currentDay)) {
    return {
      allowed: false,
      status: 'INVALID',
      errorCode: 'INVALID_WORK_DAY',
      httpStatus: 400,
      errorMessage: `Hari ini (${currentDayLabel}) bukan hari kerja sesuai pengaturan. Hari kerja: ${workDaysLabel}`,
    };
  }

  // 2) Validasi jam kerja & status keterlambatan
  const workStart: string = appSettings?.schedule?.workStartTime ?? '08:00';
  const workEnd: string = appSettings?.schedule?.workEndTime ?? '17:00';
  const allowLateCheckIn: boolean = appSettings?.attendance?.allowLateCheckIn ?? true;
  const lateThreshold: number = appSettings?.attendance?.lateThreshold ?? 15; // minutes

  const currentTime = `${now.getUTCHours().toString().padStart(2, '0')}:${now
    .getUTCMinutes()
    .toString()
    .padStart(2, '0')}`;

  // Untuk MASUK: hanya dibatasi oleh jam mulai kerja.
  // Setelah lewat jam mulai, aturan keterlambatan diatur oleh allowLateCheckIn & lateThreshold.
  if (tipeUpper === 'MASUK') {
    if (currentTime < workStart) {
      // Terlalu pagi sebelum jam mulai kerja → tolak
      return {
        allowed: false,
        status: 'INVALID',
        errorCode: 'OUT_OF_WORK_HOURS',
        httpStatus: 400,
        errorMessage: `Absen masuk hanya tersedia setelah jam mulai kerja (${workStart}) sesuai pengaturan admin. Waktu saat ini: ${currentTime}`,
      };
    }
  }

  // Hitung status absensi (VALID / TERLAMBAT / INVALID)
  let computedStatus: StatusAbsensi = 'VALID';

  if (tipeUpper === 'MASUK') {
    const { hours, minutes } = parseTimeHHmm(workStart);
    const startToday = new Date(now);
    // Gunakan UTC methods karena now sudah merepresentasikan waktu Indonesia
    startToday.setUTCHours(hours, minutes, 0, 0);

    const diffMin = diffMinutes(now, startToday); // positive jika after start
    if (diffMin > (lateThreshold || 0)) {
      computedStatus = allowLateCheckIn ? 'TERLAMBAT' : 'INVALID';
    } else {
      computedStatus = 'VALID';
    }
  }

  // Untuk KELUAR: sesuai requirement, bisa kapan saja (tidak ada pembatasan jam di sini).

  return {
    allowed: true,
    status: computedStatus,
  };
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
      return sendError(res, 'Peserta magang tidak ditemukan', 400, 'PARTICIPANT_NOT_FOUND');
    }

    // Check if peserta magang is active
    if (pesertaMagang.status !== 'AKTIF') {
      return sendError(res, 'Status peserta magang tidak aktif', 400, 'PARTICIPANT_NOT_ACTIVE');
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
    const requestIp =
      (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || req.ip || ipAddress;
    if (ipWhitelistEnabled) {
      if (!Array.isArray(allowedIps) || allowedIps.length === 0) {
        return sendError(
          res,
          'IP whitelist diaktifkan, namun daftar IP belum dikonfigurasi oleh admin',
          403,
          'IP_WHITELIST_NOT_CONFIGURED',
        );
      }
      if (!allowedIps.includes(requestIp)) {
        return sendError(
          res,
          `IP ${requestIp} tidak diizinkan untuk absensi sesuai pengaturan admin`,
          403,
          'IP_NOT_WHITELISTED',
        );
      }
    }

    // Tentukan timestamp yang dipakai
    // Mobile mengirim timestamp yang sudah dalam waktu Indonesia (UTC+7)
    // JavaScript Date akan menginterpretasikan ISO string sebagai UTC
    // Jadi kita perlu menggunakan UTC methods untuk mendapatkan waktu Indonesia yang benar
    let now: Date;
    if (timestamp) {
      // Parse timestamp dari mobile (sudah dalam waktu Indonesia)
      now = new Date(timestamp);
    } else {
      // Jika tidak ada timestamp, gunakan waktu sekarang dan konversi ke waktu Indonesia (UTC+7)
      const utcNow = new Date();
      const indonesianOffset = 7 * 60 * 60 * 1000; // 7 jam dalam milliseconds
      now = new Date(utcNow.getTime() + indonesianOffset);
    }

    // Konsolidasi logika aturan kerja (hari kerja, jam kerja, terlambat)
    const rulesResult = evaluateAttendanceRules(now, tipe, appSettings);
    if (!rulesResult.allowed) {
      return sendError(
        res,
        rulesResult.errorMessage || 'Absensi tidak memenuhi aturan kerja',
        rulesResult.httpStatus ?? 400,
        rulesResult.errorCode,
      );
    }
    const computedStatus: StatusAbsensi = rulesResult.status;

    // Enforce lokasi (tanpa pengecualian untuk QR) jika required
    if (requireLocation) {
      if (!lokasi || typeof lokasi?.latitude !== 'number' || typeof lokasi?.longitude !== 'number') {
        return sendError(res, 'Lokasi diperlukan untuk absensi sesuai pengaturan admin', 400, 'LOCATION_REQUIRED');
      }

      if (useRadius) {
        if (typeof officeLat !== 'number' || typeof officeLng !== 'number') {
          return sendError(
            res,
            'Koordinat kantor belum dikonfigurasi oleh admin. Silakan hubungi admin sebelum melakukan absensi.',
            500,
            'OFFICE_LOCATION_NOT_CONFIGURED',
          );
        }
        const distance = haversineDistanceMeters(lokasi.latitude, lokasi.longitude, officeLat, officeLng);
        if (distance > radiusMeters) {
          // STRICT: di luar jangkauan ditolak
          return sendError(
            res,
            `Di luar jangkauan kantor. Jarak Anda ${distance}m, melebihi radius ${radiusMeters}m dari kantor.`,
            400,
            'LOCATION_OUT_OF_RANGE',
          );
        }
        (req as any)._absenDistance = distance;
      }
    }

    // Cegah duplikasi MASUK / KELUAR di hari yang sama.
    // Jika admin menghapus record hari ini, user boleh absen lagi karena record lama sudah tidak ada.
    const tipeUpper = (tipe || '').toUpperCase();
    const startOfDay = new Date(now);
    startOfDay.setUTCHours(0, 0, 0, 0);
    const endOfDay = new Date(now);
    endOfDay.setUTCHours(23, 59, 59, 999);

    const existingToday = await prisma.absensi.findFirst({
      where: {
        pesertaMagangId,
        tipe: tipeUpper as TipeAbsensi,
        // timestamp disimpan sebagai string ISO, sehingga perbandingan range masih valid
        timestamp: {
          gte: startOfDay.toISOString(),
          lte: endOfDay.toISOString(),
        },
      },
    });

    if (existingToday) {
      if (tipeUpper === 'MASUK') {
        return sendError(
          res,
          'Anda sudah melakukan absen masuk hari ini. Tidak dapat absen masuk dua kali di hari yang sama.',
          400,
          'ALREADY_CHECKED_IN',
        );
      }
      if (tipeUpper === 'KELUAR') {
        return sendError(
          res,
          'Anda sudah melakukan absen keluar hari ini. Tidak dapat absen keluar dua kali di hari yang sama.',
          400,
          'ALREADY_CHECKED_OUT',
        );
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

    sendSuccess(res, 'Absensi berhasil dibuat', { ...absensi, meta }, 201);
  } catch (error) {
    console.error('Create absensi error:', error);
    sendError(res, 'Gagal membuat absensi. Silakan coba lagi atau hubungi admin.', 400, 'CREATE_ATTENDANCE_FAILED');
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