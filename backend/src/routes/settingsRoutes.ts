const { Router } = require('express');
import {
  getSettings,
  updateSettings,
  generateQRCode,
  validateQRCode,
  resetSettings,
  getSettingsByCategory,
  exportSettings,
  importSettings,
} from '../controllers/settingsController';
import { authenticateToken, requireAdmin } from '../middleware/auth';

const router = Router();

// Protected routes - require authentication
router.use(authenticateToken);

// Routes accessible to authenticated users
router.get('/', getSettings);
router.get('/category/:category', getSettingsByCategory);
router.post('/qr/validate', validateQRCode);

// QR Code generation - accessible to authenticated users
router.post('/qr/generate', generateQRCode);

// Admin only routes
router.put('/', requireAdmin, updateSettings);
router.post('/reset', requireAdmin, resetSettings);
router.get('/export', requireAdmin, exportSettings);
router.post('/import', requireAdmin, importSettings);

module.exports = router;
