import { type Request, type Response } from 'express';
import { prisma } from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response';

export const getDashboardStats = async (req: Request, res: Response) => {
  try {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);

    // Get counts in parallel for better performance
    const [
      totalPesertaMagang,
      pesertaMagangAktif,
      absensiMasukHariIni,
      absensiKeluarHariIni,
      aktivitasBaruBaruIni,
    ] = await Promise.all([
      // Get total peserta magang
      prisma.pesertaMagang.count(),

      // Get active peserta magang
      prisma.pesertaMagang.count({
        where: { status: 'AKTIF' },
      }),

      // Get today's attendance - masuk
      prisma.absensi.count({
        where: {
          tipe: 'MASUK',
          createdAt: {
            gte: startOfDay,
            lt: endOfDay,
          },
        },
      }),

      // Get today's attendance - keluar
      prisma.absensi.count({
        where: {
          tipe: 'KELUAR',
          createdAt: {
            gte: startOfDay,
            lt: endOfDay,
          },
        },
      }),

      // Get recent activities (last 10 attendance records)
      prisma.absensi.findMany({
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
        orderBy: { createdAt: 'desc' },
        take: 10,
      }),
    ]);

    // Calculate attendance rate (simplified calculation)
    const tingkatKehadiran = pesertaMagangAktif > 0 
      ? Math.round((absensiMasukHariIni / pesertaMagangAktif) * 100) 
      : 0;

    const dashboardStats = {
      totalPesertaMagang,
      pesertaMagangAktif,
      absensiMasukHariIni,
      absensiKeluarHariIni,
      tingkatKehadiran,
      aktivitasBaruBaruIni: aktivitasBaruBaruIni.map(item => ({
        id: item.id,
        pesertaMagangId: item.pesertaMagangId,
        pesertaMagang: item.pesertaMagang,
        tipe: item.tipe,
        timestamp: item.timestamp,
        status: item.status,
        createdAt: item.createdAt,
      })),
    };

    sendSuccess(res, 'Dashboard stats retrieved successfully', dashboardStats);
  } catch (error) {
    console.error('Dashboard stats error:', error);
    sendError(res, 'Failed to retrieve dashboard stats');
  }
};

export const getAttendanceReport = async (req: Request, res: Response) => {
  try {
    const { startDate, endDate, pesertaMagangId } = req.query;

    const where: any = {};
    
    // Date range filter
    if (startDate && endDate) {
      where.createdAt = {
        gte: new Date(startDate as string),
        lte: new Date(endDate as string),
      };
    }

    // Peserta magang filter
    if (pesertaMagangId) {
      where.pesertaMagangId = pesertaMagangId;
    }

    const attendanceData = await prisma.absensi.findMany({
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
      orderBy: { createdAt: 'desc' },
    });

    // Process data for report
    const reportData = attendanceData.reduce((acc: any, item: any) => {
      const pesertaId = item.pesertaMagangId;
      const pesertaNama = item.pesertaMagang?.nama || 'Unknown';

      if (!acc[pesertaId]) {
        acc[pesertaId] = {
          pesertaMagangId: pesertaId,
          pesertaMagangName: pesertaNama,
          totalHari: 0,
          hadir: 0,
          tidakHadir: 0,
          terlambat: 0,
          tingkatKehadiran: 0,
          periode: {
            mulai: startDate || '',
          },
        };
      }

      if (item.tipe === 'MASUK') {
        acc[pesertaId].hadir += 1;
        if (item.status === 'TERLAMBAT') {
          acc[pesertaId].terlambat += 1;
        }
      }

      return acc;
    }, {});

    // Calculate attendance rate for each peserta
    Object.values(reportData).forEach((item: any) => {
      const totalWorkDays = 30; // Simplified - should calculate actual work days
      item.totalHari = totalWorkDays;
      item.tidakHadir = totalWorkDays - item.hadir;
      item.tingkatKehadiran = totalWorkDays > 0 
        ? Math.round((item.hadir / totalWorkDays) * 100) 
        : 0;
    });

    sendSuccess(res, 'Attendance report retrieved successfully', Object.values(reportData));
  } catch (error) {
    console.error('Attendance report error:', error);
    sendError(res, 'Failed to retrieve attendance report');
  }
};

export const getMonthlyStats = async (req: Request, res: Response) => {
  try {
    const { year, month } = req.query;
    const currentYear = year ? parseInt(year as string) : new Date().getFullYear();
    const currentMonth = month ? parseInt(month as string) : new Date().getMonth() + 1;

    const startDate = new Date(currentYear, currentMonth - 1, 1);
    const endDate = new Date(currentYear, currentMonth, 0);

    // Get monthly attendance stats
    const monthlyAttendance = await prisma.absensi.findMany({
      where: {
        createdAt: {
          gte: startDate,
          lte: endDate,
        },
      },
      include: {
        pesertaMagang: {
          select: {
            id: true,
            nama: true,
            divisi: true,
          },
        },
      },
    });

    // Process monthly stats
    const stats = {
      totalAbsensi: monthlyAttendance.length,
      masuk: monthlyAttendance.filter(a => a.tipe === 'MASUK').length,
      keluar: monthlyAttendance.filter(a => a.tipe === 'KELUAR').length,
      izin: monthlyAttendance.filter(a => a.tipe === 'IZIN').length,
      sakit: monthlyAttendance.filter(a => a.tipe === 'SAKIT').length,
      terlambat: monthlyAttendance.filter(a => a.status === 'TERLAMBAT').length,
      periode: {
        year: currentYear,
        month: currentMonth,
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString(),
      }
    };

    sendSuccess(res, 'Monthly stats retrieved successfully', stats);
  } catch (error) {
    console.error('Monthly stats error:', error);
    sendError(res, 'Failed to retrieve monthly stats');
  }
};