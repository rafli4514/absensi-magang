const { Router } = require('express');
import {
  getAllLogbook,
  getLogbookById,
  createLogbook,
  updateLogbook,
  deleteLogbook,
  getStatistics,
} from '../controllers/logbookController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Protected routes - require authentication
router.use(authenticateToken);

// Routes accessible to all authenticated users
router.get('/', getAllLogbook);
router.get('/statistics', getStatistics);
router.get('/:id', getLogbookById);
router.post('/', createLogbook); // Peserta magang can create their own logbook
router.put('/:id', updateLogbook); // Peserta magang can update their own logbook
router.delete('/:id', deleteLogbook); // Peserta magang can delete their own logbook

module.exports = router;
