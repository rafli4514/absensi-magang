const { Router } = require('express');
import {
  getDashboardStats,
  getDailyStats,
  getAttendanceReport,
  getMonthlyStats,
  getCurrentMonthPerformance,
} from '../controllers/dashboardController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Protected routes - require authentication
router.use(authenticateToken);

router.get('/stats', getDashboardStats);
router.get('/daily-stats', getDailyStats);
router.get('/attendance-report', getAttendanceReport);
router.get('/monthly-stats', getMonthlyStats);
router.get('/current-month-performance', getCurrentMonthPerformance);

module.exports = router;
