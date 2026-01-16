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

// Routes for creating attendance (students can create their own)
router.post('/', createAbsensi);

// Admin only routes
router.put('/:id', requireAdmin, updateAbsensi);
router.delete('/:id', requireAdmin, deleteAbsensi);

export default router;