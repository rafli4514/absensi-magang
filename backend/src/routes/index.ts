const { Router } = require('express');
import pesertaMagangRoutes = require('./pesertaMagangRoutes');
import absensiRoutes = require('./absensiRoutes');
import userRoutes = require('./userRoutes');
import authRoutes = require('./authRoutes');
import pengajuanIzinRoutes = require('./pengajuanIzinRoutes');
import logbookRoutes = require('./logbookRoutes');
import dashboardRoutes = require('./dashboardRoutes');
import settingsRoutes = require('./settingsRoutes');

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

export = router;
