const { Router } = require('express');
import {
  getDashboardStats,
  getDailyStats,
  getAttendanceReport,
  getMonthlyStats,
} from '../controllers/dashboardController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Protected routes - require authentication
router.use(authenticateToken);

router.get('/stats', getDashboardStats);
router.get('/daily-stats', getDailyStats);
router.get('/attendance-report', getAttendanceReport);
router.get('/monthly-stats', getMonthlyStats);

module.exports = router;
