const { Router } = require('express');
import {
  getSettings,
  updateSettings,
  generateQRCode,
  validateQRCode,
  resetSettings,
  getSettingsByCategory,
  getLocationSettings,
  exportSettings,
  importSettings,
} from '../controllers/settingsController';
import { authenticateToken, requireAdmin } from '../middleware/auth';

const router = Router();

// Protected routes - require authentication
router.use(authenticateToken);

// Routes accessible to authenticated users (including pembimbing magang for read)
router.get('/', getSettings);
router.get('/category/:category', getSettingsByCategory);
router.get('/location', getLocationSettings);
router.post('/qr/validate', validateQRCode);

// QR Code generation - accessible to authenticated users
router.post('/qr/generate', generateQRCode);

// Admin only routes
router.put('/', requireAdmin, updateSettings);
router.post('/reset', requireAdmin, resetSettings);
router.get('/export', requireAdmin, exportSettings);
router.post('/import', requireAdmin, importSettings);

module.exports = router;
