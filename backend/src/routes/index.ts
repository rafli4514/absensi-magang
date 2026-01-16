import { Router } from 'express';
import pesertaMagangRoutes from './pesertaMagangRoutes';
import absensiRoutes from './absensiRoutes';
import userRoutes from './userRoutes';
import authRoutes from './authRoutes';
import pengajuanIzinRoutes from './pengajuanIzinRoutes';
import logbookRoutes from './logbookRoutes';
import dashboardRoutes from './dashboardRoutes';
import settingsRoutes from './settingsRoutes';
import serverMonitorRoutes from './serverMonitorRoutes';
import pembimbingRoutes from './pembimbingRoutes';

const router = Router();

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// Authentication routes (public)
router.use('/auth', authRoutes);

// Protected routes
router.use('/users', userRoutes);
router.use('/peserta-magang', pesertaMagangRoutes);
router.use('/absensi', absensiRoutes);
router.use('/pengajuan-izin', pengajuanIzinRoutes);
router.use('/logbook', logbookRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/settings', settingsRoutes);

// [BARU] Daftarkan route pembimbing
router.use('/pembimbing', pembimbingRoutes);

// [BARU] Daftarkan route server monitor
// [BARU] Daftarkan route server monitor
// Ini akan membuat endpoint: /api/server/specs dan /api/server/stats
router.use('/server', serverMonitorRoutes);

// [BARU] Route Upload
import uploadRoutes from './uploadRoutes';
router.use('/upload', uploadRoutes);

// [BARU] Route Export
import exportRoutes from './exportRoutes';
router.use('/export', exportRoutes);

// [BARU] Route Activity Timeline
import activityRoutes from './activityRoutes';
router.use('/activity', activityRoutes);

export default router;
