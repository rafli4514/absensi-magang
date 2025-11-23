const { Router } = require('express');
import {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  toggleUserStatus,
} from '../controllers/userController';
import { authenticateToken, requireAdmin, requireAdminOrPembimbing } from '../middleware/auth';

const router = Router();

// Protected routes - require authentication
router.use(authenticateToken);

// Routes accessible to admin and pembimbing magang (read-only for pembimbing)
router.get('/', requireAdminOrPembimbing, getAllUsers);
router.get('/:id', requireAdminOrPembimbing, getUserById);
router.post('/', requireAdmin, createUser);
router.put('/:id', requireAdmin, updateUser);
router.delete('/:id', requireAdmin, deleteUser);
router.patch('/:id/toggle-status', requireAdmin, toggleUserStatus);

module.exports = router;
