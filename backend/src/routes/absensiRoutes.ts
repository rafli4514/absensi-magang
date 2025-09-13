const { Router } = require('express');
import {
  getAllAbsensi,
  getAbsensiById,
  createAbsensi,
  updateAbsensi,
  deleteAbsensi,
} from '../controllers/absensiController';
import { authenticateToken, requireAdmin } from '../middleware/auth';

const router = Router();

// Protected routes
router.use(authenticateToken); // All routes below require authentication

router.get('/', getAllAbsensi);
router.get('/:id', getAbsensiById);

// Admin only routes
router.post('/', requireAdmin, createAbsensi);
router.put('/:id', requireAdmin, updateAbsensi);
router.delete('/:id', requireAdmin, deleteAbsensi);

module.exports = router