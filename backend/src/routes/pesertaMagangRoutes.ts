const { Router } = require('express');
import {
  getAllPesertaMagang,
  getPesertaMagangById,
  createPesertaMagang,
  updatePesertaMagang,
  deletePesertaMagang,
  uploadAvatar,
  removeAvatar,
} from '../controllers/pesertaMagangController';
import { authenticateToken, requireAdmin } from '../middleware/auth';
import { upload } from '../middleware/upload';

const router = Router();

// Protected routes
router.use(authenticateToken); // All routes below require authentication

// Routes accessible to authenticated users
router.get('/', getAllPesertaMagang);
router.get('/:id', getPesertaMagangById);

// Admin only routes
router.post('/', requireAdmin, createPesertaMagang);
router.put('/:id', requireAdmin, updatePesertaMagang);
router.delete('/:id', requireAdmin, deletePesertaMagang);
router.post('/:id/upload-avatar', requireAdmin, (req, res, next) => {
  upload.single('avatar')(req, res, (err) => {
    if (err) {
      console.error('Multer error:', err);
      return res.status(400).json({
        success: false,
        message: err.message || 'File upload error'
      });
    }
    next();
  });
}, uploadAvatar);
router.delete('/:id/avatar', requireAdmin, removeAvatar);

module.exports = router;
