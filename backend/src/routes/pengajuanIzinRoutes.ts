const { Router } = require('express');
import {
  getAllPengajuanIzin,
  getPengajuanIzinById,
  createPengajuanIzin,
  updatePengajuanIzin,
  deletePengajuanIzin,
  approvePengajuanIzin,
  rejectPengajuanIzin,
  getStatistics,
} from '../controllers/pengajuanIzinController';
import { authenticateToken, requireAdmin } from '../middleware/auth';

const router = Router();

// Protected routes - require authentication
router.use(authenticateToken);

// Routes accessible to all authenticated users
router.get('/', getAllPengajuanIzin);
router.get('/statistics', getStatistics);
router.get('/:id', getPengajuanIzinById);
router.post('/', createPengajuanIzin); // Students can create their own requests

// Admin only routes
router.put('/:id', requireAdmin, updatePengajuanIzin);
router.delete('/:id', requireAdmin, deletePengajuanIzin);
router.patch('/:id/approve', requireAdmin, approvePengajuanIzin);
router.patch('/:id/reject', requireAdmin, rejectPengajuanIzin);

module.exports = router;
