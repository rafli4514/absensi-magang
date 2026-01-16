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
// FIX: Import requireAdminOrPembimbing
import { authenticateToken, requireAdmin, requireAdminOrPembimbing } from '../middleware/auth';

const router = Router();

// Protected routes - require authentication
router.use(authenticateToken);

// Routes accessible to all authenticated users
router.get('/', getAllPengajuanIzin);
router.get('/statistics', getStatistics);
router.get('/:id', getPengajuanIzinById);
router.post('/', createPengajuanIzin);

// Admin only routes (Update & Delete tetap Admin only jika diinginkan)
router.put('/:id', requireAdmin, updatePengajuanIzin);
router.delete('/:id', requireAdmin, deletePengajuanIzin);

// FIX: Gunakan requireAdminOrPembimbing agar Mentor bisa Approve/Reject
router.patch('/:id/approve', requireAdminOrPembimbing, approvePengajuanIzin);
router.patch('/:id/reject', requireAdminOrPembimbing, rejectPengajuanIzin);

export default router;