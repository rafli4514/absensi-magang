const { Router } = require('express');
import {
  login,
  loginPesertaMagang,
  register,
  registerPesertaMagang,
  getProfile,
  updateProfile,
  uploadAvatar,
  removeAvatar,
  refreshToken,
} from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';
import { upload } from '../middleware/upload';

const router = Router();

// Public routes
router.post('/login', login);
router.post('/login-peserta', loginPesertaMagang);
router.post('/register', register);
router.post('/register-peserta-magang', registerPesertaMagang);

router.post('/refresh-token', refreshToken);

// Protected routes
router.use(authenticateToken);
router.get('/profile', getProfile);
router.put('/profile', updateProfile);
router.post('/upload-avatar', (req, res, next) => {
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
router.delete('/avatar', removeAvatar);

module.exports = router;
