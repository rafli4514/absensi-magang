const { Router } = require('express');
import {
  getAllPesertaMagang,
  getPesertaMagangById,
  createPesertaMagang,
  updatePesertaMagang,
  deletePesertaMagang,
} from '../controllers/pesertaMagangController';
import { authenticateToken, requireAdmin } from '../middleware/auth';

const router = Router();

// Public routes (if needed)
// router.get('/', getAllPesertaMagang);

// Protected routes
router.use(authenticateToken); // All routes below require authentication

router.get('/', getAllPesertaMagang);
router.get('/:id', getPesertaMagangById);

// Admin only routes
router.post('/', requireAdmin, createPesertaMagang);
router.put('/:id', requireAdmin, updatePesertaMagang);
router.delete('/:id', requireAdmin, deletePesertaMagang);

module.exports = router;
