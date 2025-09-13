const { Router } = require('express');
import pesertaMagangRoutes = require('./pesertaMagangRoutes');
import absensiRoutes = require('./absensiRoutes');

const router = Router();

// API Routes
router.use('/peserta-magang', pesertaMagangRoutes);
router.use('/absensi', absensiRoutes);

// Health check (public)
router.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

module.exports = router;
